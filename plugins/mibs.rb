#!/usr/bin/env ruby
require 'sqlite3'

# Plugin to track webchat users
class Mibs

	# This method is called when the plugin is first loaded
	def initialize( status, config, output, irc, timer )
		@status  = status
		@config  = config
		@output  = output
		@irc     = irc
		@timer   = timer

		# Nick of person to notify
		@owner   = "Cool_Fire"

		# SQLite database config
		@dbname  = "mibs.db3"
		@db      = SQLite3::Database.new( "data/#{@dbname}" )

		# Listing of database queries
		# Create tables
		@createtable =
			"CREATE TABLE IF NOT EXISTS mibs(
			 hexip        TEXT UNIQUE,
			 counter      INTEGER,
			 timestamp    INTEGER,
			 nicks        TEXT,
			 notes        TEXT,
			 PRIMARY KEY (hexip)
			)"

		# Make sure tables exist before we start building statements that use them
		db_init

		# Get mib record by hexip
		@getrecord   = @db.prepare( "SELECT * FROM mibs WHERE hexip = :hexip" )

		# Get mib record by searching note
		@searchnote  = @db.prepare( "SELECT * FROM mibs WHERE notes LIKE :searchterm" )

		# Write or update record by hexip
		@writerecord = @db.prepare(
			"INSERT OR REPLACE INTO mibs(
			 hexip,
			 counter,
			 timestamp,
			 nicks,
			 notes
			)
			VALUES(
			 :hexip,
			 :counter,
			 :timestamp,
			 :nicks,
			 :notes
			)"
		)

		# Write a note for a user
		@writenote = @db.prepare( "UPDATE mibs SET notes = :note WHERE hexip = :hexip" )
	end

	# Check if mib has been here before on join
	def joined( nick, user, host, channel )
		# See if user looks like mib
		if( user =~ /^[0-9a-f]{8}/ )
			nick = nick.to_s.encode('utf-8')
			user = user.to_s.encode('utf-8')

			# See if this mib has been here before
			record = @getrecord.execute( :hexip => user ).next

			if( !record.nil? )
				@writerecord.execute(
					:hexip     => user,
					:counter   => record[1] + 1,
					:timestamp => Time.now.to_i,
					:nicks     => "#{record[3]},#{nick}",
					:notes     => record[4]
				)

				@irc.message( @owner, "#{nick} has been here #{record[1]} times before. (#{Time.at(record[2]).to_datetime}])" )

				if( record[4] != "" )
					@irc.message( @owner, "Notes: #{record[4]}" )
				end
			else
				@writerecord.execute(
					:hexip     => user,
					:counter   => 1,
					:timestamp => Time.now.to_i,
					:nicks     => nick,
					:notes     => ""
				)
			end
		end
	end

	# Retreive record
	def getrecord( nick, user, host, from, msg, arguments, con )
		if( @config.auth( host, con ) )
			line = @getrecord.execute( :hexip => arguments ).next.inspect

			if( con )
				@output.c( line + "\n" )
			else
				@irc.message( from, line )
			end
		end
	end

	def searchnote( nick, user, host, from, msg, arguments, con )
		if( @config.auth( host, con ) )
			line = @searchnote.execute( :searchterm => arguments ).next.inspect

			if( con )
				@output.c( line + "\n" )
			else
				@irc.message( from, line )
			end
		end
	end

	def writenote( nick, user, host, from, msg, arguments, con )
		if( @config.auth( host, con ) )
			arguments = arguments.split()

			hexip = arguments[0].downcase.to_s.encode('utf-8')
			note  = arguments[1..-1].join(' ').to_s.encode('utf-8')

			record = @getrecord.execute( :hexip => hexip ).next

			if( record[4] != "" )
				note = "#{record[4]}, #{note}"
			end

			@writenote.execute( :note => note, :hexip => hexip )
		end
	end

	# Function that gets called when the plugin is un- or reloaded.
	def unload
		# Close any prepared statements		
		@getrecord.close()
		@searchnote.close()
		@writerecord.close()
		@writenote.close()

		return true
	end

	# Function to send help about this plugin (Can also be called by the help plugin.)
	def help( nick, user, host, from, msg, arguments, con )
		help = [
			"Keep track of mibbit users",
			"  mibs getrecord [hexip]        - Get DB line.",
			"  mibs searchnote [query]       - Search notes with sqlite LIKE syntax",
			"  mibs writenote [hexip] [note] - Add a note."
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

	private

	# Create database table if needed.
	def db_init
		# Create table
		@db.execute( @createtable )
	end
end