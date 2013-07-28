#!/usr/bin/env ruby

# Plugin to pull updates from git
class Git

	# This method is called when the plugin is first loaded
	def initialize( status, config, output, irc, timer )
		@status  = status
		@config  = config
		@output  = output
		@irc     = irc
		@timer   = timer
	end

	# Alias to pull
	def main( nick, user, host, from, msg, arguments, con )
		pull( nick, user, host, from, msg, arguments, con )
	end
	
	# Function to send help about this plugin (Can also be called by the help plugin.)
	def help( nick, user, host, from, msg, arguments, con )
		help = [
			"This plugin allows you to pull updates from a git repo.",
			"Will only work if you cloned the bot from git.",
			"  git pull              - Pull updates."
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
	
	# Generic function that can only be called by an admin
	def pull( nick, user, host, from, msg, arguments, con )
		if( @config.auth( host, con ) )
			res = %x( git pull ).gsub!( "\n", " " )
			@irc.notice( nick, "#{res}" )
		end
	end
end