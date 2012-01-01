#!/usr/bin/ruby

# Class handle the sending of messages to IRC
class IRC
	def initialize( status, config, output, socket )
		@status		= status
		@config		= config
		@output		= output
		@socket		= socket
	end

	def socket
		return @socket
	end

	def raw( line )
		@output.debug_extra( "<== " + line + "\n")
			@socket.puts( line )
	end

	# Send initial connect data
	def sendinit
		raw( "NICK " + @config.nick )
		raw( "USER " + @config.user + " 8 *  :" + @config.version )
	end

	def login
		# Do nickserv login
		if( @config.pass != "" )
			message( "NickServ", "IDENTIFY " + @config.pass )
		end

		# Join channels
		@config.channels.each do |channel|
			join( channel )
		end
	end

	def pong( line )
		raw( "PONG " + line )
		if( @config.waitforping && !@status.login )
			login
			@status.login( 1 )
		end
	end

	def message( to, message )
		raw( "PRIVMSG " + to + " :" + message )
	end

	def action( to, action )
		raw( "PRIVMSG " + to + " :ACTION " + action + "" )
	end

	def notice( to, message )
		raw( "NOTICE " + to + " :" + message )
	end

	def nick( nick )
		@config.nick( nick )
		raw( "NICK " + nick )
	end

	def topic( channel, topic )
		raw( "TOPIC " + channel + " :" + topic )
	end

	def join( channel )
		raw( "JOIN " + channel )
	end

	def part( channel )
		raw( "PART " + channel )
	end

	def kick( channel, user, reason )
		raw( "KICK " + channel + " " + user + " " + reason )
	end

	def mode( channel, mode, subject )
		raw( "MODE " + channel + " " + mode + " " + subject )
	end

	def quit( message )
		raw( "QUIT " + message )
		disconnect
	end

	def disconnect
		@status.login( 0 )
		@socket.close 
	end
end
		
