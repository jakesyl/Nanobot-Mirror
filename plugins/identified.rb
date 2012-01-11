#!/usr/bin/env ruby

# Plugin to voice users who are identified with NickServ
class Identified

	# This method is called when the plugin is first loaded
	def initialize( status, config, output, irc, timer )
		@status		= status
		@config		= config
		@output		= output
		@irc		= irc
		@timer		= timer

		@channel	= "#hackerthreads"
	end

	# Method that receives a notification when a user joins (optional)
	def joined( nick, user, host, channel )
		if( channel == @channel )
			@irc.message( "NickServ", "status " + nick )
		end
	end

	# Method that receives a notification when a notice is received (optional)
	def noticed( nick,  user,  host,  to,  message )
		nick.downcase!
		if( nick == "nickserv" )
			cmd, subject, status = message.split( ' ', 3 )

			if( status == "3" )
				@irc.mode( @channel, "+v" ,subject )
			end
		end
	end
end
