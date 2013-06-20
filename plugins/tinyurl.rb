#!/usr/bin/env ruby

# Plugin to make tinyurls
class Tinyurl

	require 'rubygems'
	
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
		if( !arguments.nil? && !arguments.empty? )
			if( arguments !~ /tinyurl/ )
				line = Net::HTTP.get( 'tinyurl.com', '/api-create.php?url=' + arguments )
				
				# Check for chained calling
				if( caller[ 0 ][ /([a-zA-Z0-9]+)(\.rb)/, 1 ] != "commands" )
					return line
				else
					if( con )
						@output.c( line + "\n" )
					else
						@irc.message( from, line )
					end
				end
			end
		end
	end
end
