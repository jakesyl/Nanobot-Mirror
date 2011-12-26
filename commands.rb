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

	# Check for authorized users
	def auth( host )
		admin = 0
		if( con ) # No auth needed
			admin = 1
		else
			@config.opers.each { |adminhost|
				if( adminhost == host )
					admin = 1
				end				
			}
		end
		
		if( admin == 1 )
			return
		else
			Thread.kill
		end
	end

	# Inital command parsing
	def process( nick, user, host, from, msg )

		cmd, rest = msg.split(' ', 2)
		cmd = cmd.gsub( /[^a-zA-Z0-9 -]/, "" )
		begin
			eval( "self.#{cmd}( nick, user, host, from, msg )" )
		rescue NoMethodError
			# Plugin stuff
		end

	end

	def help( nick, user, host, from, msg )
		cmd, topic = msg.split(' ', 2)
		
	end

	def message( nick, user, host, from, msg )
		auth( host )
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
		auth( host )
		cmd, to, action = msg.split( ' ', 3 )
		if( to != nil && action != nil )
			@irc.action( to, action )
		else
			if( con )
				@output.cinfo( "Usage: action send_to message to send" )
			else
				@irc.notice( nick, "Usage: " + cmc + "action send_to message to send" )
			end
		end
	end

	def notice( nick, user, host, from, msg )
		auth( host )
		cmd, to, message = msg.split( ' ', 3 )
		if( to != nil && message != nil )
			@irc.notice( to, message )
		else
			if( con )
				@output.cinfo( "Usage: notice send_to message to send" )
			else
				@irc.notice( nick, "Usage: " + cmc + "notice send_to message to send" )
			end
		end
	end

	def join( nick, user, host, from, msg )
		auth( host )
		cmd, chan = msg.split( ' ', 2 )
		if( to != nil && message != nil )
			@irc.join( chan )
		else
			if( con )
				@output.cinfo( "Usage: join #channel" )
			else
				@irc.notice( nick, "Usage: " + cmc + "join #channel" )
			end
		end
	end

	def part( nick, user, host, from, msg )
		auth( host )
		cmd, chan = msg.split( ' ', 2 )
		if( to != nil && message != nil )
			@irc.part( chan )
		else
			if( con )
				@output.cinfo( "Usage: part #channel" )
			else
				@irc.notice( nick, "Usage: " + cmc + "part #channel" )
			end
		end
	end

	def nick( nick, user, host, from, msg )
		auth( host )
	end

	def quit( nick, user, host, from, msg )
		auth( host )
		if( con )		
			@output.cbad( "This will also stop the bot, are you sure? [y/N]: " )
			STDOUT.flush
			ans = STDIN.gets.chomp
		end
		if( ans =~ /^y$/i || !con )
			cmd, message = msg.split( ' ', 2 )

			if( message == nil )
				@irc.quit( @config.nick + " was instructed to quit." )
			else
				@irc.quit( message )
			end

			@irc.disconnect
			Process.exit
		else
			if( con )
				@output.cinfo( "Continuing" )
			end
		end
	end

	def plugin( nick, user, host, from, msg )
		# Check for public function
		auth( host )
		# Check for admin function
	end
end
