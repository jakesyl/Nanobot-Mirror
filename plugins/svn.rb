#!/usr/bin/env ruby

# Plugin to pull updates from SVN
class Svn

	# This method is called when the plugin is first loaded
	def initialize( status, config, output, irc, timer )
		@status  = status
		@config  = config
		@output  = output
		@irc     = irc
		@timer   = timer
	end

	# Alias to update
	def main( nick, user, host, from, msg, arguments, con )
		update( nick, user, host, from, msg, arguments, con )
	end
	
	# Function to send help about this plugin (Can also be called by the help plugin.)
	def help( nick, user, host, from, msg, arguments, con )
		help = [
			"This plugin allows you to pull updates from the svn repo.",
			"Will only work if you checked the bot out from svn.",
			"  svn update               - Get updates.",
			"  svn version              - Check current SVN revision."
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
	
	# Function to get updates from SVN
	def update( nick, user, host, from, msg, arguments, con )
		if( @config.auth( host, con ) )
			res = %x( svn up ).gsub!( "\n", " " )
			@irc.notice( nick, "#{res}" )
		end
	end

	# Function to check revision
	def update( nick, user, host, from, msg, arguments, con )
		res = %x( svnversion ).gsub!( "\n", " " )
		@irc.notice( nick, "#{res}" )
	end
end
