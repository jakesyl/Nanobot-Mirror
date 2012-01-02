#!/usr/bin/env ruby

# Class handle the sending of messages to IRC
class IRC
	def initialize( status, config, output, socket )
		@status		= status
		@config		= config
		@output		= output
		@socket		= socket
	end

	# Get raw socket.
	def socket
		return @socket
	end

	# Send raw data to IRC
	def raw( line )
		@output.debug_extra( "<== " + line + "\n")
			@socket.puts( line )
	end

	# Send initial connect data
	def sendinit
		raw( "NICK " + @config.nick )
		raw( "USER " + @config.user + " 8 *  :" + @config.version )
	end

	# Send login info
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

	# Reply to PINGs
	def pong( line )
		raw( "PONG " + line )
		if( @config.waitforping && !@status.login )
			login
			@status.login( 1 )
		end
	end

	# Send standard message
	def message( to, message )
		raw( "PRIVMSG " + to + " :" + message )
	end

	# Send ACTION message
	def action( to, action )
		raw( "PRIVMSG " + to + " :ACTION " + action + "" )
	end

	# Send notice
	def notice( to, message )
		raw( "NOTICE " + to + " :" + message )
	end

	# Change nickname
	def nick( nick )
		@config.nick( nick )
		raw( "NICK " + nick )
	end

	# Set topic
	def topic( channel, topic )
		raw( "TOPIC " + channel + " :" + topic )
	end

	# Join channel
	def join( channel )
		raw( "JOIN " + channel )
	end

	# Part channel
	def part( channel )
		raw( "PART " + channel )
	end

	# Kick user
	def kick( channel, user, reason )
		raw( "KICK " + channel + " " + user + " " + reason )
	end

	# Set modes
	def mode( channel, mode, subject )
		raw( "MODE " + channel + " " + mode + " " + subject )
	end

	# Quit IRC
	def quit( message )
		raw( "QUIT " + message )
		disconnect
	end

	# Disconnect socket
	def disconnect
		@status.login( 0 )
		@socket.close
	end
end
		
