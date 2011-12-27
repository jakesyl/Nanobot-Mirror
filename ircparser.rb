#!/usr/bin/ruby

# Class to parse IRC input

require 'ircparser_suroutines.rb'
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

		if( @config.waitforping == 0 && @status.login == 0 )
			@irc.login
		end

		while line = @irc.socket.gets
			if( @status.threads == 1 && @config.threads == 1 )
				Thread.new{ parser( line.chomp ) }
				#puts t.join # Debug line
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

			if( @config.waitforping == 1 && @status.login == 0 )
				@irc.login
			end

		# KICK
		elsif( line =~ /^\:(.+?)!(.+?)@(.+?) KICK (.+?) (.+?) \:(.+?)/ )
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
		elsif( line =~ /^\:(.+?)!(.+?)@(.+?) PART \:(.+)/ )
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
			@sub.misc( $1 )
		end
	end
end
		
