#!/usr/bin/env ruby

# Plugin to do delayed actions
# Basically just an interface to the timer class
class Delay

	# This method is called when the plugin is first loaded
	def initialize( status, config, output, irc, timer )
		@status  = status
		@config  = config
		@output  = output
		@irc     = irc
		@timer   = timer
	end

	# Default method
	def main( nick, user, host, from, msg, arguments, con )
		@irc.notice( nick, "Use 'ruby' or 'irc' as the method.")
	end
	
	# Function to send help about this plugin (Can also be called by the help plugin.)
	def help( nick, user, host, from, msg, arguments, con )
		help = [
			"This plugin to delay actions.",
			"  delay ruby [seconds] [action]    - Set ruby command to be carried out later."
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
		
	# Functions to do delayed actions
	def ruby( nick, user, host, from, msg, arguments, con )
		if( @config.auth( host, con ) )
			if( !arguments.nil? && !arguments.empty? )
				delay, action = arguments.split( ' ', 2 )

				@timer.action( delay.to_i, action.to_s )
				@irc.message( from, "Recorded ruby command '#{action}' to be executed in #{delay} seconds." )
			end
		end
	end
end