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
			@timer.action( @config.rejointime, "@irc.join( '#{channel}' )" )
		end

		@status.plugins.each_key do |key|
			if( @status.getplugin( key ).respond_to?( "kicked" ) )
				@status.getplugin( key ).kicked( nick, user, host, channel, kicked, reason )
			end
		end
	end

	def notice( nick,  user,  host,  to,  message )
		@status.plugins.each_key do |key|
			if( key != "core" )
				if( @status.getplugin( key ).respond_to?( "noticed" ) )
					@status.getplugin( key ).noticed( nick,  user,  host,  to,  message )
				end
			end
		end
	end

	def join( nick, user, host, channel )
		@status.plugins.each_key do |key|
			if( @status.getplugin( key ).respond_to?( "joined" ) )
				@status.getplugin( key ).joined( nick, user, host, channel )
			end
		end
	end

	def part( nick, user, host, channel )
		@status.plugins.each_key do |key|
			if( @status.getplugin( key ).respond_to?( "parted" ) )
				@status.getplugin( key ).parted( nick, user, host, channel )
			end
		end

	end

	def quit( nick, user, host, message )
		@status.plugins.each_key do |key|
			if( @status.getplugin( key ).respond_to?( "quited" ) )
				@status.getplugin( key ).quited( nick, user, host, message )
			end
		end
	end

	def privmsg( nick, user, host, from, message )
		cmd = @config.command
		if( message =~ /^#{cmd}/ )
			@cmd.process( nick, user, host, from, message.gsub( /^#{cmd}/, "" ) )
		else
			@status.plugins.each_key do |key|
			if( key != "core" )
				if( @status.getplugin( key ).respond_to?( "messaged" ) )
					@status.getplugin( key ).messaged( nick, user, host, from, message )
				end
			end
		end

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

	def sanitize( input, downcase = 0 )
		input.gsub!( /[^a-zA-Z0-9 -]/, "" )
		if( downcase == 1 )
			input.downcase!
		end
	end
end
