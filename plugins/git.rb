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
			"  git pull              - Pull updates.",
			"  git status            - Show some info and state."
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
	
	# Pull updates from server
	def pull( nick, user, host, from, msg, arguments, con )
		if( @config.auth( host, con ) )
			res = %x( git pull ).gsub!( "\n", " " )
			@irc.notice( nick, "#{res}" )
		end
	end

	# Show some output and status
	def status( nick, user, host, from, msg, arguments, con )
		branch = %x( git branch | head -n 1 | awk '{print $2}' )
		status = %x( git fetch -v --dry-run 2>&1 >/dev/null | grep #{branch} )
		
		if ( status == "" )
			status = " (Local branch)"
		end

		@irc.notice( nick, "On branch #{branch}#{status}" )
	end
end