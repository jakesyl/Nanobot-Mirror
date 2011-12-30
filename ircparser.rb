#!/usr/bin/ruby

# Class to parse IRC input
require './ircparser_suroutines.rb'

class IRCParser
	def initialize( status, config, output, irc, timer )
		@status		= status
		@config		= config
		@output		= output
		@irc		= irc
		@timer		= timer

		@sub		= IRCSubs.new( status, config, output, irc, timer )
	end

	def start
		@irc.sendinit

		if( !@config.waitforping && !@status.login )
			@irc.login
			autoload
			@status.login( 1 )
		end

		while line = @irc.socket.gets
			if( @status.threads && @config.threads )
				spawn_parser( line.chomp )
			else
				parser( line.chomp )
			end
		end
	end

	def spawn_parser( line )
		if(@status.debug == 3)
			puts Thread.new { parser( line ) }.join
		else
			Thread.new { parser( line )	}
		end
	end

	def parser( line )
		@output.debug_extra( "==> " + line + "\n" )

		# (Raw data hook)

		# PING
		if( line =~ /^PING \:(.+)/ )
			@output.debug( "Received ping\n" )
			@irc.pong( $1 )

			if( @config.waitforping && !@status.login )
				@irc.login
				autoload
			end

		# KICK
		elsif( line =~ /^\:(.+?)!(.+?)@(.+?) KICK (.+?) (.+?) \:(.+)/ )
			@output.debug( "Received kick\n" )
			@sub.kick( $1, $2, $3, $4, $5, $6 )

		# NOTICE
		elsif( line =~ /^\:(.+?)!(.+?)@(.+?) NOTICE (.+?) \:(.+)/ )
			@output.debug( "Received notice\n" )
			@sub.notice( $1, $2, $3, $4, $5 )

		# JOIN
		elsif( line =~ /^\:(.+?)!(.+?)@(.+?) JOIN \:(.+)/ )
			@output.debug( "Received join\n" )
			@sub.join( $1, $2, $3, $4 )

		# PART
		elsif( line =~ /^\:(.+?)!(.+?)@(.+?) PART (.+)/ )
			@output.debug( "Received part\n" )
			@sub.part( $1, $2, $3, $4 )

		# QUIT
		elsif( line =~ /^\:(.+?)!(.+?)@(.+?) QUIT \:(.+)/ )
			@output.debug( "Received quit\n" )
			@sub.quit( $1, $2, $3, $4 )

		# PRIVMSG
		elsif( line =~ /^\:(.+?)!(.+?)@(.+?) PRIVMSG (.+?) \:(.+)/ )
			@output.debug( "Received message\n" )
			@sub.privmsg( $1, $2, $3, $4, $5 )

		# Other stuff
		else
			@sub.misc( line )
		end
	end
	
	# Function to start module autoloading
	def autoload
		if( @status.threads && @config.threads )
			spawn_parser( "autoload" )
		else
			parser( "autoload" )
		end
	end
end
		
