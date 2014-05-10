#!/usr/bin/env ruby
require 'sqlite3'

# Plugin to send memos to (offline) users
class Memo
	
	# Structure used to store cache data
	if( !defined? CacheItem )
		CacheItem = Struct.new(
			:status,
			:timestamp
		)
	end

	# Class initializer
	def initialize( status, config, output, irc, timer )
		@status     = status
		@config     = config
		@output     = output
		@irc        = irc
		@timer      = timer

		# User cache
		@cache    = {}
		@maxcache = 50

		# Send reminders every 15 minutes
		@reminders = 15 * 60
		
		# SQLite database config
		@dbname     = "memo.db3"
		@db         = SQLite3::Database.new( "data/#{@dbname}" )
		
		# Listing of database queries
		# Create tables
		@createtable =
			"CREATE TABLE IF NOT EXISTS memo(
			 sender        TEXT,
			 receiver      TEXT,
			 timestamp     INTEGER,
			 memo          TEXT
			 )"
				
		# Make sure tables exist before we start building statements that use them
		db_init
		
		# Memo count query per user
		@recordcount = @db.prepare( "SELECT COUNT( * ) FROM memo WHERE receiver = :receiver" )
		
		# Insert new memo
		@insert = @db.prepare(
			"INSERT INTO memo(
			 sender,
			 receiver,
			 timestamp,
			 memo)
			 VALUES(
			 :sender,
			 :receiver,
			 :timestamp,
			 :memo
			 )"
		)
		
		# Retreive n memos
		@retreiven = @db.prepare( "SELECT * FROM memo WHERE receiver = :receiver ORDER BY timestamp ASC  LIMIT :count" )
		
		# Delete n memos
		@deleten   = @db.prepare( "DELETE FROM memo WHERE receiver = :receiver AND timestamp = :timestamp" )
	end

	# Main function for plugin (alias to send)
	def main( nick, user, host, from, msg, arguments, con )
		@output.debug("main\n")
		send( nick, user, host, from, msg, arguments, con )
	end

	# Send memo to user
	def send( nick, user, host, from, msg, arguments, con )
		if( !arguments.nil? && !arguments.empty? )
			arguments = arguments.split()

			# Check if the number of arguments is correct
			if( arguments.length >= 2)

				# Split out variables
				frm = nick.downcase
				to  = arguments[0].downcase
				msg = arguments[1..-1].join(' ')

				# Write memo to database
				@insert.execute(
					"sender"    => frm.to_s.encode('utf-8'),
					"receiver"  => to.to_s.encode('utf-8'),
					"timestamp" => Time.now.to_i,
					"memo"      => msg.to_s.encode('utf-8')
				)
			else
				# Produce error for insufficient arguments.

				line = "Invalid syntax. Expecting 'memo send recipient message to send'."

				if( con )
					@output.c( line + "\n" )
				else
					@irc.notice( nick, line )
				end
			end
		end
	end

	# Read memos
	def read( nick, user, host, from, msg, arguments, con, print = true )
		nick.downcase!
		count = @recordcount.execute( :receiver => nick ).next[0]

		if ( count == 0 )
			# Report error
				line = "There are no memos for you."

				if( con )
					@output.c( line + "\n" )
				else
					@irc.message( nick, line )
				end
			@cache[ nick ] = CacheItem.new( false, Time.now.to_i )
		else
			if( !arguments.nil? )
				n = arguments.to_i
			else
				n = count
			end

			# Sanity check count
			if( n <= count )
				# Get memos
				rows = @retreiven.execute(
					:receiver => nick,
					:count    => n
				)

				while ( row = rows.next )
					# process row
					if( print )
						line = "[#{Time.at(row[2]).to_datetime}] <#{row[0]}> #{row[3]}"

						if( con )
							@output.c( line + "\n" )
						else
							@irc.message( nick, line )
						end
					end

					# Remove memos that have been read
					@deleten.execute(
						:receiver  => nick,
						:timestamp => row[2]
					)
				end

				newcount = @recordcount.execute( :receiver => nick ).next[0]
				line = ""
				if( newcount != 0 )
					line = "More memos remain. (#{newcount})"
				else
					line = "No more memos."
				end

				if( con )
					@output.c( line + "\n" )
				else
					@irc.message( nick, line )
				end

			else
				# Report error
				line = "Cannot find #{n} memos. Only #{count} available."

				if( con )
					@output.c( line + "\n" )
				else
					@irc.message( nick, line )
				end
			end
		end
	end

	# Delete memos without reading them
	def delete( nick, user, host, from, msg, arguments, con )
		read( nick, user, host, from, msg, arguments, con, false )
	end

	# Output some plugin state
	def status( nick, user, host, from, msg, arguments, con )
		warmup = ( @cache.size.to_f / @maxcache.to_f ) * 100
		warmup = ( warmup * 10 ).round / 10.0

		line = "Cache warmup: #{warmup}%"

		if( con )
			@output.c( line + "\n" )
		else
			@irc.notice( nick, line )
		end
	end

	# Function to send help about this plugin (Can also be called by the help plugin.)
	def help( nick, user, host, from, msg, arguments, con )
		help = [
			"Send and read memos",
			"  memo send [user] [message]   - Send memo to a user.",
			"  memo read {n}                - Read n number of messages. (All if no number is given.)",
			"  memo delete {n}              - Delete n messages without reading them. (All if no number is given.)",
			"  memo status                  - Get some info about the plugin state."
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
		# Close any prepared statements
		@recordcount.close()
		@insert.close()
		@retreiven.close()
		@deleten.close()

		return true
	end
	
	# Check if user is alive
	def messaged( nick, user, host, from, message )
		@output.debug("messaged\n")
		nick.downcase!

		ci = nil

		# Check if it's not a private message to the bot.
		if( from != @config.nick() )
			# Check cached nicks
			if( @cache.has_key?( nick ))
				ci = @cache.fetch( nick )
			else
				# Check database
				if( @recordcount.execute( :receiver => nick ).next[0] != 0 )
					ci = CacheItem.new( true, 0 )
				end
			end

			# Send message to user if memo exists
			if( !ci.nil? )
				# New messages exist, check if user needs reminding.
				if( Time.now.to_i - ci[ :timestamp ] >= @reminders )
					count = @recordcount.execute( :receiver => nick ).next[0]
					@irc.message( nick, "You have unread memos (#{count}). '#{@config.command}memo help' for more info.")
					@cache[ nick ] = CacheItem.new( true, Time.now.to_i )
				end
			end
		end
	end

	private
	# Functions below this line are for the internal workings of the plugin
	
	# Database management functions
	def db_init
		@output.debug("db_init\n")

		# Create table
		@db.execute( @createtable )
	end
	
	# User cache functions
	def cache_update( nick, status )

		# Check if nick is already in cache
		if( !@cache.has_key?( name ) )
		
			# Check if cache is not full
			oldestnick = ""
			oldesttime = Time.now.to_i
			if( @cache.size > @maxcache )
				# Search for oldest item
				@cache.each_pair do |name, ci|
					if( ci[ :timestamp ] <= oldesttime )
						oldesttime = ci[ :timestamp ]
						oldestnick = name
					end
				end

				# Drop oldest cache line
				@cache.delete( oldestnick )
			end
		end

		# Update/set the cache line
		@cache[ nick ] = CacheItem.new( :status => status, :timestamp => Time.now.to_i )
	end
end