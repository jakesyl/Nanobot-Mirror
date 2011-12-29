#!/usr/bin/ruby

# Class to handle IRC commands

require './commands.rb'
class IRCSubs
	def initialize( status, config, output, irc, timer )
		@status		= status
		@config		= config
		@output		= output
		@irc		= irc
		@timer		= timer

		@cmd		= Commands.new( status, config, output, irc, timer, 0 )
	end

	def kick( nick, user, host, channel, kicked, reason )
		@output.std( nick + " kicked " + kicked + " from " + channel + ". (" + reason + ")\n" )

		# Check if we need to rejoin
		if( @config.nick == kicked && @config.rejoin )
			@timer.action( @config.rejointime, "JOIN " + channel )
		end
	end

	def notice( nick,  user,  host,  to,  message )
	end

	def join( nick, user, host, channel )
	end

	def part( nick, user, host, channel )
	end

	def quit( nick, user, host, message )
	end

	def privmsg( nick, user, host, from, message )
		cmd = @config.command
		if( message =~ /^#{cmd}/ )
			@cmd.process( nick, user, host, from, message.gsub( /^#{cmd}/, "" ) )
		else
			# Hook for non-command messages
		end
	end

	def misc( unknown )
		# Passing on the signal for module autoloading
		if( unknown == "autoload" )
			tmp = Commands.new( @status, @config, @output, @irc, @timer, 1 )
			tmp.autoload
			tmp = nil
		end
	end
end
