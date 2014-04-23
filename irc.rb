#!/usr/bin/env ruby

# Class handle the sending of messages to IRC
class IRC
	def initialize( status, config, output, connection )
		@status		= status
		@config		= config
		@output		= output
		@connection	= connection

		@socket = connect()

		if( usequeue )
			@high	= Queue.new
			@low	= Queue.new
			@proc	= Thread.new{ processqueues }
			@signal	= Queue.new
		end
	end

	# Get raw socket.
	def socket
		return @socket
	end

	# Send raw data to IRC
	def raw( line, high = false )

		# Final check on output before sending data
		line = check( line )

		if( usequeue )
			enqueue( line, high )
		else
			@output.debug_extra( "<== " + line + "\n")
			@socket.puts( line )
		end
	end

	# Send initial connect data
	def sendinit
		if( @config.serverpass != "" )
			raw( "PASS #{@config.serverpass}")
		end

		if( @config.connectoptions != "" )
			raw( "#{@config.connectoptions}")
		end

		raw( "NICK #{@config.nick}" )
		raw( "USER #{@config.user} 8 *  :#{@config.version}" )
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
		raw( "PONG " + line, true )
	end

	# Send standard message
	def message( to, message, high = false )
		raw( "PRIVMSG " + to + " :" + message, high )
	end

	# Send ACTION message
	def action( to, action, high = false )
		raw( "PRIVMSG " + to + " :ACTION " + action + "", high )
	end

	# Send notice
	def notice( to, message, high = false )
		raw( "NOTICE " + to + " :" + message, high )
	end

	# Change nickname
	def nick( nick, high = false )
		@config.nick( nick )
		raw( "NICK " + nick, high )
	end

	# Set topic
	def topic( channel, topic, high = false )
		raw( "TOPIC " + channel + " :" + topic, high )
	end

	# Join channel
	def join( channel, high = false )
		raw( "JOIN " + channel, high )
	end

	# Part channel
	def part( channel, high = false )
		raw( "PART " + channel, high )
	end

	# Kick user
	def kick( channel, user, reason, high = false )
		raw( "KICK " + channel + " " + user + " " + reason, high )
	end

	# Set modes
	def mode( channel, mode, subject, high = false )
		raw( "MODE " + channel + " " + mode + " " + subject, high )
	end

	# Quit IRC
	def quit( message, high = false )
		raw( "QUIT " + message, high )
		disconnect
	end

	# Function to connect to the server	
	def connect
		if( @status.reconnect )
			while( !@connection.start )
				@output.info( "Trying reconnect in #{@config.connecttimeout} seconds.\n" )
				sleep( @config.connecttimeout )
			end
		else
			if( !@connection.start )
				@output.bad( "Could not connect to server.\n" )
				Process.exit
			end
		end

		return @connection.socket
	end

	# Reconnect when something went wrong upstream
	def reconnect
		# Wait for high priority queue to empty
		if( usequeue )
			while( !@high.empty? )
				sleep( 1 )
			end
		end

		@status.login( 0 )
		@socket.close
		@socket = connect()
	end

	# Disconnect socket
	def disconnect
		# Wait for high priority queue to empty
		if( usequeue )
			while( !@high.empty? )
				sleep( 1 )
			end
		end

		@status.login( 0 )
		@status.reconnect( 0 )
		@socket.close
	end

	private

	# Method to determine the use of queues.
	def usequeue
		return( @status.threads && @config.threads && @config.throttleoutput )
	end

	# Function for queued sending thread
	def processqueues
		while true do
			line = nil
			@signal.pop
			if( !@high.empty? )
				# Process high priority
				line = @high.pop
				@output.debug_extra( "<==+ " + line + "\n")
			elsif( !@low.empty? )
				# Process low priority
				line = @low.pop
				@output.debug_extra( "<==- " + line + "\n")
			end

			# Send output
			if( !line.nil? )
				@socket.puts( line )
				sleep( 1 )
			end
		end
	end
	
	# Function to add stuff to queues ( Low priority unless specified otherwise. )
	def enqueue( line, high = false )
		if( high )
			@high.push( line )
		else
			@low.push( line )
		end

		# Tell the processing thread data is ready.
		@signal.push( "" )
	end

	# Check if output is acceptable for IRC.
	def check( line )

		# Must not contain any line breaks
		line.gsub!( /[\r\n]/, "" )

		# Max length for IRC message is 512 (including CR-LF)
		if( line.length > 510 )
			line = line[ 0 .. 510 ]
		end

		return line
	end
end
