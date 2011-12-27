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

		if( con ) # No auth needed for console
			admin = 1
		else
			@config.opers.each do |adminhost|
				if( adminhost == host )
					admin = 1
				end				
			end
		end

		return( admin == 1 )
	end

	# Inital command parsing
	def process( nick, user, host, from, msg )

		cmd, rest = msg.split(' ', 2)

		if( cmd != nil )
			cmd = cmd.gsub( /[^a-zA-Z0-9 -]/, "" )
			begin
				eval( "self.#{cmd}( nick, user, host, from, msg )" )
			rescue NoMethodError
				# Plugin stuff
				# else -> unknow command
			end
		end
	end

	def help( nick, user, host, from, msg )
		cmd, topic = msg.split(' ', 2)
		
	end

	def message( nick, user, host, from, msg )
		if( auth( host ) )
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
	end

	def action( nick, user, host, from, msg )
		if( auth( host ) )
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
	end

	def notice( nick, user, host, from, msg )
		if( auth( host ) )
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
	end

	def join( nick, user, host, from, msg )
		if( auth( host ) )
			cmd, chan = msg.split( ' ', 2 )
			if( chan != nil )
				@irc.join( chan )
			else
				if( con )
					@output.cinfo( "Usage: join #channel" )
				else
					@irc.notice( nick, "Usage: " + cmc + "join #channel" )
				end
			end
		end
	end

	def part( nick, user, host, from, msg )
		if( auth( host ) )
			cmd, chan = msg.split( ' ', 2 )
			if( chan != nil )
				@irc.part( chan )
			else
				if( con )
					@output.cinfo( "Usage: part #channel" )
				else
					@irc.notice( nick, "Usage: " + cmc + "part #channel" )
				end
			end
		end
	end

	def timeban( nick, user, host, from, msg )
		if( auth( host ) )
			if( @config.threads == 1 && @status.threads == 1 )
				cmd, chan, host, timeout = msg.split( ' ', 4 )
				if( chan != nil )
					@irc.mode( chan, "+b", host )
					@timer.action( timeout.to_i, "@irc.mode( \"#{chan}\", \"-b\", \"#{host}\" )" )

					if( con )
						@output.cinfo( "Unban set for " + timeout.to_s + " seconds from now." )
						@irc.message( chan, "Unban set for " + timeout.to_s + " seconds from now." )
					else
						@irc.message( from, "Unban set for " + timeout.to_s + " seconds from now." )
					end
				else
					if( con )
						@output.cinfo( "Usage: timeban #channel host seconds" )
					else
						@irc.notice( nick, "Usage: " + cmc + "timeban #channel host seconds" )
					end
				end
			else
				@irc.notice( nick, "Timeban not availble when threading is disabled." )
			end
		end
	end

	def nick( nick, user, host, from, msg )
		if( auth( host ) )
		end
	end

	def quit( nick, user, host, from, msg )
		if( auth( host ) )
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
	end

	def plugin( nick, user, host, from, msg )
		# Check for public function
		if( auth( host ) )
			# Check for admin function
		end
	end
end
