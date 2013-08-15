#!/usr/bin/env ruby

# Plugin to help with debugging
class Debug

	# This method is called when the plugin is first loaded
	def initialize( status, config, output, irc, timer )
		@status  = status
		@config  = config
		@output  = output
		@irc     = irc
		@timer   = timer
	end

	# Default method, called when no argument is given (optional, but highly recomended)
	def main( nick, user, host, from, msg, arguments, con )
		
	end
	
	# Function to send help about this plugin (Can also be called by the help plugin.)
	def help( nick, user, host, from, msg, arguments, con )
		help = [
			"Plugin to help with debugging.",
			"  debug threadlist             - Print list of threads to console.",
			"  debug level                  - Set debug level. (No input sanitsing!)"
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
		
	# Show backtrace of specific thread
	def threadtrace( nick, user, host, from, msg, arguments, con )
		Thread.list.each do |thr| 
			if( thr.to_s =~ /#{arguments}/ )
				thr.backtrace.each do |level|
					@output.info( "#{level.to_s}\n" )
				end
			end
		end
	end


	# List all threads + status
	def threadlist( nick, user, host, from, msg, arguments, con )
		Thread.list.each do |thr| 
			@output.info( "#{thr.inspect}\n" )
		end
	end

	# Set debug level
	def level( nick, user, host, from, msg, arguments, con )
		if( @config.auth( host, con ) )
			@status.debug( arguments.to_i )
			@irc.notice( nick, "Set debug level to #{arguments}" )
		else
			@irc.message( from, "Sorry " + nick + ", this is a function for admins only!" )
		end
	end
end
