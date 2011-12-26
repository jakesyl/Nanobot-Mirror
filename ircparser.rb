#!/usr/bin/ruby

# Class to make and manage connection

require 'ircparser_suroutines.rb'
class IRCParser
	def initialize( status, config, output, irc, timer )
		@status		= status
		@config		= config
		@output		= output
		@irc		= irc
		@timer		= timer
	end

	def start
		@irc.sendinit

		while line = @irc.socket.gets
			if( @status.threads == 1 && @config.threads == 1 )
				Thread.new{ parser( line.chomp ) }
			else
				parser( line.chomp )
			end
		end
	end

	def parser( line )
		@output.debug_extra( "==> " + line + "\n" )

		# (Raw data hook)

		# PING
		if( line =~ /^PING \:(.+)/ )
			@output.debug( "Received ping\n" )
			@irc.pong( $1 )

		# KICK
		elsif( line =~ /^\:(.+?)!(.+?)@(.+?) KICK (.+?) (.+?) \:(.+?)/ )
			@output.debug( "Received kick\n" )
			kick( $1, $2, $3, $4, $5, $6 )

		# NOTICE
		elsif( line =~ /^\:(.+?)!(.+?)@(.+?) NOTICE (.+?) \:(.+)/ )
			@output.debug( "Received notice\n" )
			notice( $1, $2, $3, $4, $5 )

		# JOIN
		elsif( line =~ /^\:(.+?)!(.+?)@(.+?) JOIN \:(.+)/ )
			@output.debug( "Received join\n" )
			userjoin( $1, $2, $3, $4 )

		# PART
		elsif( line =~ /^\:(.+?)!(.+?)@(.+?) PART \:(.+)/ )
			@output.debug( "Received part\n" )
			userpart( $1, $2, $3, $4 )

		# QUIT
		elsif( line =~ /^\:(.+?)!(.+?)@(.+?) QUIT \:(.+)/ )
			@output.debug( "Received quit\n" )
			userquit( $1, $2, $3, $4 )

		# PRIVMSG
		elsif( line =~ /^\:(.+?)!(.+?)@(.+?) PRIVMSG (.+?) \:(.+)/ )
			@output.debug( "Received message\n" )
			privmsg( $1, $2, $3, $4, $5 )

		# Other stuff
		else
			misc( $1 )
		end
	end
end
		
