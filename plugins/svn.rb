#!/usr/bin/env ruby

# Plugin to demonstrate the working of plugins
class Svn

	# This method is called when the plugin is first loaded
	def initialize( status, config, output, irc, timer )
		@status		= status
		@config		= config
		@output		= output
		@irc		= irc
		@timer		= timer
	end

	# Default method, called when no argument is given (optional, but highly recomended)
	def main( nick, user, host, from, msg, arguments, con )
		update( nick, user, host, from, msg, arguments, con )
	end
	
	# Function to send help about this plugin (Can also be called by the help plugin.)
	def help( nick, user, host, from, msg, arguments, con )
		help = [
			"This plugin allows you to pull updates from the svn repo.",
			"Will only work if you checked the bot out from svn.",
			"  svn updates              - Public plugin function."
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
	def update( nick, user, host, from, msg, arguments, con )
		if( @config.auth( host, con ) )
			res = %x( svn up ).gsub!( "\n", " " )
			@irc.notice( nick, "#{res}" )
		end
	end
end
