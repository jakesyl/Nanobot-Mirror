#!/usr/bin/ruby

# Class to handle user commands
class Commands
	def initialize( status, config, output, irc, timer, console = 0 )
		@status		= status
		@config		= config
		@output		= output
		@irc		= irc
		@timer		= timer
		@console	= console
	end

	# Shorthands
	def con
		return( @console == 1 )
	end
	def cmc
		return @config.command
	end

	# Inital command parsing
	def process( nick, user, host, from, msg )
		if( msg =~ /^help/ )
			help( nick, user, host, from, msg )
		elsif( msg =~ /^message/ )
			message( nick, user, host, from, msg )
		elsif( msg =~ /^action/ )
			action( nick, user, host, from, msg )
		elsif( msg =~ /^notice/ )
			notice( nick, user, host, from, msg )
		elsif( msg =~ /^nick/ )
			nick( nick, user, host, from, msg )
		elsif( msg =~ /^quit/ || msg =~ /^exit/ )
			quit( nick, user, host, from, msg )
		elsif( msg =~ /^\w/ )
			plugin( nick, user, host, from, msg )
		else
			if( con )
				@output.cbad( "Command not found\n" )
			end
		end
	end

	def help( nick, user, host, from, msg )
		cmd, topic = msg.split(' ', 2)
		
	end

	def message( nick, user, host, from, msg )
		cmd, to, message = msg.split( ' ', 3 )
		if( to != nil && message != nil )
			@irc.message( to, message )
		else
			if( con )
				@output.cinfo( "Usage: message send_to message to send" )
			else
				@irc.notice( nick, "Usage: " + cmc + "message send_to message to send" )
			end
		end
	end

	def action( nick, user, host, from, msg )
		cmd, to, action = msg.split( ' ', 3 )
		if( to != nil && action != nil )
			@irc.action( to, action )
		else
			@output.cinfo( "Usage: action send_to message to send" )
		end
	end

	def notice( nick, user, host, from, msg )
		cmd, to, message = msg.split( ' ', 3 )
		if( to != nil && message != nil )
			@irc.notice( to, message )
		else
			@output.cinfo( "Usage: notice send_to message to send" )
		end
	end

	def nick( nick, user, host, from, msg )
		config( "config " + msg )
	end

	def quit( nick, user, host, from, msg )
		@output.cbad( "This will also stop the bot, are you sure? [y/N]: " )
		STDOUT.flush
		ans = STDIN.gets.chomp
		if( ans =~ /^y$/i )
			cmd, message = msg.split( ' ', 2 )

			if( message == nil )
				@irc.quit( "Stopped from console." )
			else
				@irc.quit( message )
			end

			@irc.disconnect
			Process.exit
		else
			@output.cinfo( "Continuing" )
		end
	end

	def plugin( nick, user, host, from, msg )
	end
end
