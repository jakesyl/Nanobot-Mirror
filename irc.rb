#!/usr/bin/ruby

# Class to make and manage connection
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

	def sendinit
		raw( "NICK " + @config.nick )
		raw( "USER " + @config.user + " 8 *  :" + @config.version )
	end

	def pong( line )
		raw( "PONG " + line )
	end

	def message( to, message )
		raw( "PRIVMSG " + to + " :" + message )
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

	def mode( channel, mode, user )
		raw( "MODE " + channel + " " + mode + " " + user )
	end

	def quit( message )
		raw( "QUIT " + message )
		disconnect
	end

	def disconnect
		@sock.close 
	end
end
		
