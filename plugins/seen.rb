#!/usr/bin/env ruby
require 'sqlite3'

# Plugin to keep track of when users were last seen.
# If you want to keep using the old version of the seen plugin rename or remove this file and
# replace it with seen.old.rb.
class Seen
	
	# Structure used to store data per user
	if( !defined? Datastore )
		Datastore = Struct.new(
			# Metadata
			:nickname,
			:timestamp,
		
			# Last and beforlast line
			:last,
			:lastdate,
			:blast,
			:blastdate,
		
			# Last non-text line (join, quit etc.)
			:lastntext,
			:lastntextdate
		)
	end
	
	# Class initializer
	def initialize( status, config, output, irc, timer )
		@status     = status
		@config     = config
		@output     = output
		@irc        = irc
		@timer      = timer
		
		# Hashtable that contains the data kept in memory
		@list       = {}
		
		# SQLite database config
		@dbname     = "seen.db3"
		@db         = SQLite3::Database.new( "data/#{@dbname}" )
		
		# How often we should update the database
		@writefreq  = 50
		@writecnt   = 0
		
		# How many users should be kept in memory
		@inrammax   = 50
		
		# Variables used to keep track of statistics
		@startdate  = 0
		@writes     = 0
		@records    = 0
		@events     = 0

		# Variables to keep track of the cache hit rate for the current session
		@cache_req  = 0
		@cache_hit  = 0
		
		# Listing of database queries
		# Create tables
		@createdatatable =
			"CREATE TABLE IF NOT EXISTS logdata(
			 nickname      TEXT UNIQUE,
			 timestamp     INTEGER,
			 last          TEXT,
			 lastdate      INTEGER,
			 blast         TEXT,
			 blastdate     INTEGER,
			 lastntext     TEXT,
			 lastntextdate INTEGER,
			 PRIMARY KEY (nickname)
			 )"
			
		@createmetatable =
			"CREATE TABLE IF NOT EXISTS metadata(
			 startdate INTEGER,
			 writes    INTEGER,
			 records   INTEGER,
			 events    INTEGER
			 )"
		
		# Start date queries
		@checkstart = "SELECT COUNT( startdate ) FROM metadata"
		@getstart   = "SELECT startdate FROM metadata"
		@setstart   = "INSERT INTO metadata( startdate, writes, records, events ) VALUES( #{Time.now.to_i}, 0, 0 ,0 )"
		
		# Record count query
		@recordcount = "SELECT COUNT( * ) FROM logdata"
		
		# Get metadata (must be available before db_init)
		@getmeta  = "SELECT * FROM metadata LIMIT 1"

		# Make sure tables exist before we start building statements that use them
		db_init
		
		# Insert or update records
		@insert = @db.prepare(
			"INSERT OR REPLACE INTO logdata(
			 nickname,
			 timestamp,
			 last, lastdate,
			 blast, blastdate,
			 lastntext, lastntextdate)
			 VALUES(
			 :nickname,
			 :timestamp,
			 :last, :lastdate,
			 :blast, :blastdate,
			 :lastntext, :lastntextdate
			 )"
		)
		
		# Retreive record
		@retreive = @db.prepare( "SELECT * FROM logdata WHERE nickname = :nickname LIMIT 1" )
		
		# Set metadata
		@setmeta  = @db.prepare( "UPDATE metadata SET writes = :writes, records = :records, events = :events" )

		# Search for nicknames in the database
		@search  = @db.prepare( "SELECT nickname FROM logdata WHERE nickname LIKE :search" )
	end

	# Main function for plugin
	def main( nick, user, host, from, msg, arguments, con )
		@output.debug("main\n")
		
		# Declare result string
		lines = []
		
		# Check if there is input
		if( !arguments.nil? && !arguments.empty? )
			arguments.gsub!( / /, "" )
			arguments.downcase!
			
			# Get record for nickname
			data = get_data( arguments )
			
			if( !data.nil? )
				# Write last active lines
				lines[0] = "#{arguments} last seen"

				last  = true
				blast = true
				ntext = true

				# Check for nil fields
				if( data[ :last ].nil? )
					last = false
				end

				if( data[ :blast ].nil? )
					blast = false
				end

				if( data[ :lastntext ].nil? )
					ntext = false
				end

				# Check for empty strings
				if( last )
					if( data[ :last ].empty? )
						last = false
					end
				end

				if( blast )
					if( data[ :blast ].empty? )
						blast = false
					end
				end

				if( ntext )
					if( data[ :lastntext ].empty? )
						ntext = false
					end
				end

				# Only one item available
				if( last && !blast && !ntext )
					item1  = data[ :last ]
					item1d = data[ :lastdate ]

				elsif( ntext && !last && !blast )
					item1  = data[ :lastntext ]
					item1d = data[ :lastntextdate ]

				# No Only two available
				elsif( last && ntext && !blast )

					# Order last & lastntext
					if( data[ :lastntextdate ].to_i > data[ :lastdate ].to_i )
						item1  = data[ :last ]
						item1d = data[ :lastdate ]
						item2  = data[ :lastntext ]
						item2d = data[ :lastntextdate ]
					else
						item1  = data[ :lastntext ]
						item1d = data[ :lastntextdate ]
						item2  = data[ :last ]
						item2d = data[ :lastdate ]
					end

				elsif( last && blast && !ntext )
					item1  = data[ :blast ]
					item1d = data[ :blastdate ]
					item2  = data[ :last ]
					item2d = data[ :lastdate ]
				
				# All available
				elsif( last && blast && ntext )

					# Check odering
					if( data[ :lastntextdate ].to_i > data[ :lastdate ].to_i )
						item1  = data[ :last ]
						item1d = data[ :lastdate ]
						item2  = data[ :lastntext ]
						item2d = data[ :lastntextdate ]
					elsif( data[ :lastntextdate ].to_i > data[ :blastdate ].to_i )
						item1  = data[ :lastntext ]
						item1d = data[ :lastntextdate ]
						item2  = data[ :last ]
						item2d = data[ :lastdate ]
					else
						item1  = data[ :blast ]
						item1d = data[ :blastdate ]
						item2  = data[ :last ]
						item2d = data[ :lastdate ]
					end
				end
				
				# Construct messages
				if( item2d.nil? )
					diff = @status.uptime( Time.now.to_i, item1d )
				else
					diff = @status.uptime( Time.now.to_i, item2d )
				end

				lines[0] = "#{lines[0]} #{diff} ago."
				lines[1] = DateTime.strptime( item1d.to_s, '%s' ).strftime("%b %-d %Y, %H:%M:%S")
				lines[1] = "#{lines[1]}: #{item1}"
				
				if( !item2.nil? )
					lines[2] = DateTime.strptime( item2d.to_s, '%s' ).strftime("%b %-d %Y, %H:%M:%S")
					lines[2] = "#{lines[2]}: #{item2}"
				end

				
				# Check if whereis plugin is loaded
				if( @status.checkplugin( "whereis" ) )
					plugin = @status.getplugin( "whereis" )
					lines[0] = "#{lines[0]} | You are most likely to find this user here: #{plugin.main( arguments )}"
					plugin = nil
				end
				
			else
				logtime = @status.uptime( Time.now.to_i, @startdate )
				suggestion = db_search( "%#{arguments}%" )
				if( suggestion.nil? )
					lines[0] = "No log for #{arguments}. (Log goes back #{logtime}.)"
				else
					lines[0] = "No log for #{arguments}. Did you mean '#{suggestion}'? (Log goes back #{logtime}.)"
				end
			end
			data = nil
		else
			lines[0] = "Error: No nickname specified."
		end
		
		# Display result
		lines.each do |line|
			if( con )
				@output.c( line + "\n" )
			else
				@irc.message( from, line )
			end
		end
		lines = nil
	end

	# Function that shows some statistics
	def stats( nick, user, host, from, msg, arguments, con )
		rows = @db.execute( @recordcount )
		@records = rows[0][0].to_i + @list.size

		if( @cache_req != 0 )
			@cache_rate = ( @cache_hit.to_f / @cache_req.to_f ) * 100
			@cache_rate = ( @cache_rate * 10 ).round / 10.0
		else
			@cache_rate = "N/A"
		end

		line = "Mem: #{@list.size}/#{@inrammax} | Events logged: #{@events} | Total records: #{@records} | Db writes: #{@writes} | Cache hit rate: #{@cache_rate}%"

		if( con )
			@output.cinfo( line )
		else
			@irc.message( from, line )
		end

		line = nil
	end
	
	# Function to force database write
	def write( nick, user, host, from, msg, arguments, con )
		if( @config.auth( host, con ) )
			db_write
			
			if( con )
				@output.cinfo( "Database is up to date." )
			else
				@irc.notice( nick, "Database is up to date." )
			end
		end
	end
	
	# Search for nicknames in the database
	def search( nick, user, host, from, msg, arguments, con )
		# Ensure all nicks are also in the database
		db_write

		result = db_search( arguments )

		if( result.nil? )
			result = "No match found."
		else
			result = "Best match: #{result}"
		end

		if( con )
			@output.cinfo( result )
		else
			@irc.message( from, result )
		end
	end

	# Function to send help about this plugin (Can also be called by the help plugin.)
	def help( nick, user, host, from, msg, arguments, con )
		help = [
			"This plugin provides data on the last seen times and actions of users.",
			"  seen [user]            - Provides the last seen action from a user.",
			"  seen search [user]     - Search database for nicknames. (* and . allowed)",
			"  seen stats             - Show some statistics from this plugin.",
			"  seen write             - Force writing of seen database NOW."
		]
		
		# Print out help
		help.each do |line|
			if( con )
				@output.c( line + "\n" )
			else
				@irc.notice( nick, line )
			end
		end
	end
	
	# Function that gets called when the plugin is un- or reloaded.
	def unload
		# Force database write
		db_write

		# Close any prepared statements		
		@insert.close()
		@retreive.close()
		@setmeta.close()
		@search.close()

		return true
	end
	
	# Data gathering functions
	def messaged( nick, user, host, from, message )
		@output.debug("messaged\n")

		# Check if it's not a private message to the bot.
		if( from != @config.nick() )
			update_data( Datastore.new( nick, nil, "(#{from}) #{message}", Time.now.to_i, nil, nil, nil, nil ) )
		end
	end

	def joined( nick, user, host, channel )
		@output.debug("joined\n")
		update_data( Datastore.new( nick, nil, nil, nil, nil, nil, "Joined #{channel}", Time.now.to_i ) )
	end
	
	def parted( nick, user, host, channel )
		@output.debug("parted\n")
		update_data( Datastore.new( nick, nil, nil, nil, nil, nil, "Parted #{channel}", Time.now.to_i ) )
	end

	def quited( nick, user, host, message )
		@output.debug("quited\n")
		update_data( Datastore.new( nick, nil, nil, nil, nil, nil, "Quit: #{message}", Time.now.to_i ) )
	end

	def kicked( nick, user, host, channel, kicked, reason )
		@output.debug("kicked\n")
		update_data( Datastore.new( nick, nil, nil, nil, nil, nil, "Kicked from #{channel}: #{reason}", Time.now.to_i ) )
	end

	private
	# Functions below this line are for the internal workings of the plugin
	
	# Database management functions
	def db_init
		@output.debug("db_init\n")
		# Create tables
		@db.execute( @createdatatable )
		@db.execute( @createmetatable )
		
		# Check if start date is set in meta data
		if( @db.execute( @checkstart )[0][0] == 0 )
			@db.execute( @setstart )
		end

		# Set metadata variables
		rows = @db.execute( @getmeta )
		@startdate = rows[0][0].to_i
		@writes    = rows[0][1].to_i
		@records   = rows[0][2].to_i
		@events    = rows[0][3].to_i
	end
	
	def db_write
		# Write everything to db
		@output.debug("db_write\n")
		
		@list.each do |nick, i|
			@insert.execute( 
				"nickname"      => i[ :nickname ].to_s.encode('utf-8'),
				"timestamp"     => i[ :timestamp ].to_i,
				"last"          => i[ :last ].to_s,
				"lastdate"      => i[ :lastdate ].to_i,
				"blast"         => i[ :blast ].to_s,
				"blastdate"     => i[ :blastdate ].to_i,
				"lastntext"     => i[ :lastntext ].to_s,
				"lastntextdate" => i[ :lastntextdate ].to_i
			)
		end
		
		db_write_meta
		@writes += 1
	end
	
	def db_write_meta
		@output.debug("db_write_meta\n")
		@setmeta.execute(
			"writes"  => @writes,
			"records" => @records,
			"events"  => @events
		)
	end

	def db_retreive( nickname )
		@output.debug("db_retreive\n")

		result = @retreive.execute( "nickname" => nickname )

		row = result.next
		result = nil

		if( !row.nil? )
			data = Datastore.new(
				row[0].to_s.encode('utf-8'),
				row[1].to_i,
				row[2].to_s,
				row[3].to_i,
				row[4].to_s,
				row[5].to_i,
				row[6].to_s,
				row[7].to_i
			)

			row    = nil

			# Update objects MAC time
			data[ :timestamp ] = Time.now.to_i

			return data
		else
			return nil
		end
	end
	
	def db_update( data )
		@output.debug("db_update\n")
		@writes += 1

		@insert.execute( 
			"nickname"      => data[ :nickname ].to_s.encode('utf-8'),
			"timestamp"     => data[ :timestamp ].to_i,
			"last"          => data[ :last ].to_s,
			"lastdate"      => data[ :lastdate ].to_i,
			"blast"         => data[ :blast ].to_s,
			"blastdate"     => data[ :blastdate ].to_i,
			"lastntext"     => data[ :lastntext ].to_s,
			"lastntextdate" => data[ :lastntextdate ].to_i
		)

		data = nil
	end

	def db_search( search )
		@output.debug("db_search\n")

		search.gsub!( /\*/, "%" )
		search.gsub!( /\./, "_" )

		result = @search.execute( "search" => search )
		row = result.next
		result = nil

		if( !row.nil? )
			return row[0].to_s
		else
			return nil
		end
	end
	
	
	# Memory management functions
	def mem_push_oldest
		@output.debug("mem_push_oldest\n")

		# Check if there's really no room in memory
		if( @list.size > @inrammax )
		
			# Find oldest entry
			oldest = Time.now.to_i
			n = nil
			@list.each do |nick, data|
				if( data[ :timestamp ] <= oldest )
					oldest = data[ :timestamp ]
					n = nick
				end
			end
		
			# Push entry into database
			db_update( @list[ n ] )

			# Mark entry for garbage collection
			@list.delete( n )
			n = nil
		end
	end
	
	def mem_retreive( nickname )
		@output.debug("mem_retreive\n")
		
		# Check if nickname is in memory
		if( @list.has_key?( nickname ) )
			
			# Update timestamp for when it was last used
			@list[ nickname ][ :timestamp ] = Time.now.to_i
			
			return @list[ nickname ]
		else
			return nil
		end
	end
	
	def mem_update( data )
		@output.debug("mem_update\n")
		
		# Update timestamp for when it was last used
		data[ :timestamp ] = Time.now.to_i
		
		# Check if already in memory
		if( @list.has_key?( data[ :nickname ] ) )
			# Update values
			data.each_pair do |key, value|
				if( !value.nil? )
					# Shift last and update
					if( key.to_s == "last" )
						@list[ data[ :nickname ] ][ :blast ] = @list[ data[ :nickname ] ][ :last ]
						@list[ data[ :nickname ] ][ :last ]  = data[ :last ]
					elsif( key.to_s == "lastdate" )
						@list[ data[ :nickname ] ][ :blastdate ] = @list[ data[ :nickname ] ][ :lastdate ]
						@list[ data[ :nickname ] ][ :lastdate ]  = data[ :lastdate ]
					elsif( key.to_s != "blast" && key.to_s != "blastdate" )
						@list[ data[ :nickname ] ][ key ] = data[ key ]
					end
				end
			end
		else
			# Put full new data struct in memory
			@list[ data[ :nickname ] ] = data
		end
		inram_counter
	end
	
	def inram_counter
		if( @list.size > @inrammax )
			mem_push_oldest
		end
	end
	
	# Generic meta functions
	def update_data( data )
		@output.debug("update_data\n")
		
		# Make sure we always work with the lowercase
		data[ :nickname ].downcase!
		
		# Keep track of cache requests
		@cache_req += 1

		# Check if nick is in memory
		m = mem_retreive( data[ :nickname ] )
		if( !m.nil? )
			# Register cache hit
			@cache_hit += 1

			# Update record in memory
			mem_update( data )
		else
			# Push oldest entry to database
			mem_push_oldest
			
			# Check if nick is in database
			d = db_retreive( data[ :nickname ] )
			if( !d.nil? )
				# Put current data from database in memory
				mem_update( d )
			else
				# Not a missed cache request if it's entirely new data
				@cache_req -= 1

				# Put previously unknown nickname in memory
				mem_update( data )
			end
		end
		@events   += 1
		@writecnt += 1

		if( @writecnt == @writefreq )
			@writecnt = 0
			db_write
		end
	end
	
	def get_data( nickname )
		@output.debug("get_data\n")
		
		# Make sure we always work with the lowercase
		nickname.downcase!
		
		# Keep track of cache requests
		@cache_req += 1

		# Check if nickname is kept in ram
		m = mem_retreive( nickname )
		if( !m.nil? )
			# Register cache hit
			@cache_hit += 1

			return m
		else
			# Check if nick is in database
			d = db_retreive( nickname )
			if( !d.nil? )
				# Push oldest entry to database
				mem_push_oldest
				
				# Put data in memory
				mem_update( d )
				return d
			else
				# Not a cache miss if requesting non-existent data
				@cache_req -= 1

				return nil
			end
		end
	end
end
