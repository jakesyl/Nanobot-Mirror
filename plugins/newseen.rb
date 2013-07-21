#!/usr/bin/env ruby
require 'sqlite3'

# Plugin to keep track of when users were last seen.
# If you want to keep using the old version of the seen plugin rename or remove this file and
# replace it with seen.old.rb.
class Newseen
	
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
		@inram      = 0
		
		# Variables used to keep track of statistics
		@startdate  = 0
		@writes     = 0
		@records    = 0
		@events     = 0
		
		# Listing of database queries
		# Create tables
		@createdatatable =
			"CREATE TABLE IF NOT EXISTS logdata(
			 nickname     VARCHAR(10) UNIQUE,
			 timestamp    INTEGER,
			 last         VARCHAR(512),
			 lastdate     INTEGER,
			 blast        VARCHAR(512),
			 blastdate    INTEGER,
			 lastntext     VARCHAR(512),
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

				# Check for nil fields
				# Only one item available
				if( data[ :blast ].nil? && data[ :lastntext ].nil? )
					item1  = data[ :last ]
					item1d = data[ :lastdate ]

				elsif( data[ :last ].nil? && data[ :blast ].nil? )
					item1  = data[ :lastntext ]
					item1d = data[ :lastntextdate ]

				# No Only two available
				elsif( data[ :blast ].nil? )
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
				elsif( data[ :lastntext ].nil? )
					item1  = data[ :blast ]
					item1d = data[ :blastdate ]
					item2  = data[ :last ]
					item2d = data[ :lastdate ]
				
				# Check normal odering
				elsif( data[ :lastntextdate ].to_i > data[ :lastdate ].to_i )
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
				lines[0] = "No log for #{arguments}. Log goes back #{logtime}."
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
		@records = rows[0][0].to_i + @inram

		line = "RAM usage: #{@inram}/#{@inrammax} | Events logged: #{@events} | Unique nicks: #{@records} | Database writes: #{@writes}"

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
	
	# Function to send help about this plugin (Can also be called by the help plugin.)
	def help( nick, user, host, from, msg, arguments, con )
		help = [
			"This plugin provides data on the last seen times and actions of users.",
			"  seen [user]            - Provides the last seen action from a user.",
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
		
		return true
	end
	
	# Data gathering functions
	def messaged( nick, user, host, from, message )
		@output.debug("messaged\n")
		update_data( Datastore.new( nick, nil, "(#{from}) #{message}", Time.now.to_i, nil, nil, nil, nil ) )
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
		@startdate = rows[0][0]
		@writes    = rows[0][1]
		@records   = rows[0][2]
		@events    = rows[0][3]
	end
	
	def db_write
		# Write everything to db
		@output.debug("db_write\n")
		
		@list.each do |nick, i|
			@insert.execute( 
				"nickname"      => i[ :nickname ],
				"timestamp"     => i[ :timestamp ].to_i,
				"last"          => i[ :last ],
				"lastdate"      => i[ :lastdate ].to_i,
				"blast"         => i[ :blast ],
				"blastdate"     => i[ :blastdate ].to_i,
				"lastntext"     => i[ :lastntext ],
				"lastntextdate" => i[ :lastntextdate ].to_i
			)

			@writes += 1
		end
		db_write_meta
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

		puts result.class

		row = result.next
		result = nil

		if( !row.nil? )
			data = Datastore.new(
				row[0],
				row[1],
				row[2],
				row[3],
				row[4],
				row[5],
				row[6],
				row[7]
			)

			row    = nil

			# Update objects MAC time
			data[ :timestamp ] = Time.now.to_i
			@inram += 1

			return data
		else
			return nil
		end
	end
	
	def db_update( data )
		@output.debug("db_update\n")
		@writes += 1

		@insert.execute( 
			"nickname"      => data[ :nickname ],
			"timestamp"     => data[ :timestamp ].to_i,
			"last"          => data[ :last ],
			"lastdate"      => data[ :lastdate ].to_i,
			"blast"         => data[ :blast ],
			"blastdate"     => data[ :blastdate ].to_i,
			"lastntext"     => data[ :lastntext ],
			"lastntextdate" => data[ :lastntextdate ].to_i
		)

		data = nil
	end
	
	
	# Memory management functions
	def mem_push_oldest
		@output.debug("mem_push_oldest\n")

		# Check if there's really no room in memory
		if( @inram > @inrammax )
		
			# Find oldest entry
			oldest = Time.now.to_i
			n = nil
			@list.each do |nick, data|
				puts data 
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
			@inram -= 1
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
		puts data.to_s
		
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
			@inram += 1
		end
		inram_counter
	end
	
	def inram_counter
		if( @inram > @inrammax )
			mem_push_oldest
		end
	end
	
	# Generic meta functions
	def update_data( data )
		@output.debug("update_data\n")
		
		# Make sure we always work with the lowercase
		data[ :nickname ].downcase!
		
		# Check if nick is in memory
		m = mem_retreive( data[ :nickname ] )
		if( !m.nil? )
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
		
		# Check if nickname is kept in ram
		m = mem_retreive( nickname )
		if( !m.nil? )
			return m
		else
			# Check if nick is in database
			d = db_retreive( nickname )
			if( !d.nil? )
				# Push oldest entry to database
				mem_push_oldest
				
				# Put data in memory
				@list[ nickname ] = d
				return d
			else
				return nil
			end
		end
	end
end
