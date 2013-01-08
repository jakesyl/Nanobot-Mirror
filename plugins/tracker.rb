#!/usr/bin/env ruby

# Plugin to track my location
class Tracker

	require 'net/http'

	# This method is called when the plugin is first loaded
	def initialize( status, config, output, irc, timer )
		@status		= status
		@config		= config
		@output		= output
		@irc		= irc
		@timer		= timer

		@host		= "coolfire.insomnia247.nl"
		@path		= "/tracker/tracker.dat"

		@last_time	= Time.new
		@last_stat	= ""

		@timeout	= 300

		@channel	= "#shells"

		@blurbs		= {
						"left_home"		=> "Cool_Fire has left the vicinity of his house.",
						"entered_home"	=> "Cool_Fire has been spotted near his house.",
						"left_work"		=> "Cool_Fire seems to have left his place of work.",
						"entered_work"	=> "Cool_Fire just got into work."
					}

		if( @status.threads && @config.threads)
			@ftread	= Thread.new{ get_status }
		end
	end

	# Default method, called when no argument is given (optional, but highly recomended)
	def main( nick, user, host, from, msg, arguments, con )
		@irc.message( from, "This module will allow live tracking data to be used by nanobot." )
	end

	# Method stop data collection
	def stop( nick, user, host, from, msg, arguments, con )
		if( @config.auth( host, con ) )
			if( @status.threads && @config.threads)
				@ftread.exit
				line = "Data collection stopped."
			else
				line = "Data is not being collected. (No threading available.)"
			end
		else
			line = "You are not authorized to perform this action."
		end

		# Show output
		if( con )
			@output.c( line + "\n" )
		else
			@irc.message( from, line )
		end
	end


	# Function to send help about this plugin (Can also be called by the help plugin.)
	def help( nick, user, host, from, msg, arguments, con )
		help = [
			"This is a plugin that tracks Cool_Fire.",
			"	tracker stop	Tell it to gracfully stop the update thread."
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

	# Function that actually does the status lookup.
	def get_status
		while true

			# Grab status
			result = Net::HTTP.get( @host, @path )	
			if( result != @last_stat )
				@last_stat = result
				@last_time = Time.new

				@irc.message( @channel, @blurbs[@last_stat] )
			end

			# Wait a bit and check again.
			sleep( @timeout )
		end
	end
end
