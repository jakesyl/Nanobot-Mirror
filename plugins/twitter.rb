#!/usr/bin/env ruby

# Plugin to grab latest message from a twitter feed
class Twitter

	# This method is called when the plugin is first loaded
	def initialize( status, config, output, irc, timer )
		@status		= status
		@config		= config
		@output		= output
		@irc		= irc
		@timer		= timer
	end

	# Meta method for getlast
	def main( nick, user, host, from, msg, arguments, con )
		getlast( nick, user, host, from, msg, arguments, con )
	end

	# Method that receives a notification when a user is kicked (optional)
	def getlast( nick, user, host, from, msg, arguments, con )
		if( !arguments.nil? && !arguments.empty? )
			arguments.gsub!( /&/, "" ) # Sanitize GET variables

			# Retreive XML
			line = Net::HTTP.get( 'twitter.com', '/statuses/user_timeline/' + arguments + '.rss' )

			# Parse out XML (needs better regex)
			if( line =~ /<item>\n    <title>(.+?)<\/title>/is )
				line = $1
			else
				line = "Error: No result."
			end
		else
			line = "Not valid input. Expecting twitter username."
		end

		if( con )
			@output.c( line + "\n" )
		else
			@irc.message( from, line )
		end
	end

	# Function to send help about this plugin (Can also be called by the help plugin.)
	def help( nick, user, host, from, msg, arguments, con )
		help = [
			"This plugin retrieves the last message from a users twitter feed.",
			"  twitter getlast [twittername]    - Public plugin function.",
			"  twitter help                     - Show this help"
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
end
