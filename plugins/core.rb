class Core
	def initialize( status, config, output, irc, timer )
		@status		= status
		@config		= config
		@output		= output
		@irc		= irc
		@timer		= timer
	end

	def message( nick, user, host, from, msg, arguments, con )
		if( @config.auth( host, con ) )
			if( arguments != nil )
				to, message = arguments.split( ' ', 2 )
			end
	
			if( to != nil && message != nil )
				@irc.message( to, message )
			else
				if( con )
					@output.cinfo( "Usage: message send_to message to send" )
				else
					@irc.notice( nick, "Usage: " + @config.command + "message send_to message to send" )
				end
			end
		end
	end

	def action( nick, user, host, from, msg, arguments, con )
		if( @config.auth( host, con ) )
			if( arguments != nil )
				to, action = arguments.split( ' ', 2 )
			end

			if( to != nil && action != nil )
				@irc.action( to, action )
			else
				if( con )
					@output.cinfo( "Usage: action send_to message to send" )
				else
					@irc.notice( nick, "Usage: " + @config.command + "action send_to message to send" )
				end
			end
		end
	end

	def notice( nick, user, host, from, msg, arguments, con )
		if( @config.auth( host, con ) )
			if( arguments != nil )
				to, message = arguments.split( ' ', 2 )
			end

			if( to != nil && message != nil )
				@irc.notice( to, message )
			else
				if( con )
					@output.cinfo( "Usage: notice send_to message to send" )
				else
					@irc.notice( nick, "Usage: " + @config.command + "notice send_to message to send" )
				end
			end
		end
	end

	def join( nick, user, host, from, msg, chan, con )
		if( @config.auth( host, con ) )
			if( chan != nil )
				@irc.join( chan )
			else
				if( con )
					@output.cinfo( "Usage: join #channel" )
				else
					@irc.notice( nick, "Usage: " + @config.command + "join #channel" )
				end
			end
		end
	end

	def part( nick, user, host, from, msg, chan, con )
		if( @config.auth( host, con ) )
			if( chan != nil )
				@irc.part( chan )
			else
				if( con )
					@output.cinfo( "Usage: part #channel" )
				else
					@irc.notice( nick, "Usage: " + @config.command + "part #channel" )
				end
			end
		end
	end

	def timeban( nick, user, host, from, msg, arguments, con )
		if( @config.auth( host, con ) )
			if( @config.threads && @status.threads )
				if( arguments != nil )
					chan, host, timeout = arguments.split( ' ', 3 )
				end

				if( chan != nil && host != nil && ( !con || timeout != nil ) )
					if( timeout == nil ) # Overload parameters when no channel is given
						timeout	= host
						host	= chan
						chan	= from
					end

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
						@irc.notice( nick, "Usage: " + @config.command + "timeban #channel host seconds" )
					end
				end
			else
				@irc.notice( nick, "Timeban not availble when threading is disabled." )
			end
		end
	end

	def nick( nick, user, host, from, msg, arguments, con )
		if( @config.auth( host, con ) )
		end
	end
end
