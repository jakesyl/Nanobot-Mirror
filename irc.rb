#!/usr/bin/ruby

# Class to make and manage connection
class IRCParser
	def initialize( status, config, output, socket )
		@status		= status
		@config		= config
		@output		= output
		@socket		= socket
	end

	def start

		sendinit

		while line = @socket.gets
			puts line
		end
	end

	def raw( line )
		@output.debug_extra( line + "\n")
		@socket.puts( line )
	end

	def sendinit
		raw( "NICK " + @config.nick )
		raw( "USER " + @config.user + " 8 *  :" + @config.version )
	end
end
		
