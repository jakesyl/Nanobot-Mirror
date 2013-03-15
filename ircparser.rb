#!/usr/bin/env ruby

require './ircparser_suroutines.rb'

# Class to parse IRC input
class IRCParser
	def initialize( status, config, output, irc, timer )
		@status		= status
		@config		= config
		@output		= output
		@irc		= irc
		@timer		= timer

		@sub		= IRCSubs.new( status, config, output, irc, timer )
	end

	# Connection loop
	def start
		while( @status.reconnect )
			@irc.sendinit

			# We don't need to wait for the server ping.
			if( !@config.waitforping && !@status.login )
				autoload
				@irc.login
				@status.login( 1 )
			end

			# Main parser loop
			begin
				while( true )

					# Set IRC timeout
					Timeout::timeout( @config.pingtimeout ) do

						# Get a line from the socket
						line = @irc.socket.gets

						# Send line to the parser routine
						if( @status.threads && @config.threads )
							spawn_parser( line.chomp )
						else
							parser( line.chomp )
						end
					end
				end

			# Notify of error and reconnect
			rescue Timeout::Error
				@output.debug( "IRC timeout, trying to reconnect.\n" )
				@irc.reconnect
			rescue IOError
				@output.debug( "Socket was closed.\n" )
				@irc.reconnect
			rescue Exception => e
				@output.debug( "Socket error: " + e.to_s + "\n" )
				@irc.reconnect
			end
		end
	end

	# Wrapper function for starting threads
	def spawn_parser( line )

		# Join threads and print results when running at the highest debug level
		if( @status.debug == 3 )
			puts Thread.new { parser( line ) }.join
		else
			Thread.new { parser( line ) }
		end
	end

	# Main parser subroutine
	def parser( line )
		@output.debug_extra( "==> " + line + "\n" )

		# Regular and server messages
		if( line =~ /^:/ )

			# Regular message
			if( line =~ /^\:(.+?)!(.+?)@(.+?) (.+?) / )

				# Regular message
				if( $4 == "PRIVMSG" )
					@output.debug( "Received message\n" )
					if( line =~ /^\:(.+?)!(.+?)@(.+?) PRIVMSG (.+?) \:(.+)/ )
						@sub.privmsg( $1, $2, $3, $4, $5 )
					else
						unparsable( "PRIVMSG", line )
					end

				# Join & part messages
				elsif( $4 == "JOIN" )
					@output.debug( "Received join\n" )
					if( line =~ /^\:(.+?)!(.+?)@(.+?) JOIN \:?(.+)/ )
						@sub.join( $1, $2, $3, $4 )
					else
						unparsable( "JOIN", line )
					end

				elsif( $4 == "PART" )
					@output.debug( "Received part\n" )
					if( line =~ /^\:(.+?)!(.+?)@(.+?) PART (.+)/ )
						@sub.part( $1, $2, $3, $4 )
					else
						unparsable( "PART", line )
					end

				# Quit message
				elsif( $4 == "QUIT" )
					@output.debug( "Received quit\n" )
					if( line =~ /^\:(.+?)!(.+?)@(.+?) QUIT \:(.+)/ )
						@sub.quit( $1, $2, $3, $4 )
					else
						unparsable( "QUIT", line )
					end

				# Notices
				elsif( $4 == "NOTICE" )
					@output.debug( "Received notice\n" )
					if( line =~ /^\:(.+?)!(.+?)@(.+?) NOTICE (.+?) \:(.+)/ )
						@sub.notice( $1, $2, $3, $4, $5 )
					else
						unparsable( "NOTICE", line )
					end

				# Kicks
				elsif( $4 == "KICK" )
					@output.debug( "Received kick\n" )
					if( line =~ /^\:(.+?)!(.+?)@(.+?) KICK (.+?) (.+?) \:(.+)/ )
						@sub.kick( $1, $2, $3, $4, $5, $6 )
					else
						unparsable( "KICK", line )
					end

				# Unknown messages
				else
					unparsable( "UNKNOWN MESSAGE TYPE", line )
				end

			# Server message
			else
				if( line =~ /^\:(.+?) (.+?) (.+)/ )
					servername = $1
					messagenumber = $2
					message = $3
					servermsg( servername, messagenumber, message )
				else
					unparsableserver( "UNKNOWN SERVER MESSAGE", line )
				end
			end

		# PING from server
		elsif( line =~ /^PING \:(.+)/ )
			@output.debug( "Received ping\n" )

			# Send reply to server
			@irc.pong( $1 )

			# Send login stuff if we need to wait for a ping on this server
			if( @config.waitforping && !@status.login )
				@irc.login
				autoload
				@status.login( 1 )
			end

		# Error from server
		elsif( line =~ /^ERROR \:(.+)/ )
			@output.debug( "Received error #{$1}\n" )
			@sub.misc( line )
			

		# Internal message to load modules on startup
		elsif( line =~ /^autoload$/ )
			@output.debug( "Received autoload\n" )
			@sub.autoload

		# Unknown statement
		else
			unparsable( "UNKNOWN STATEMENT", line )
		end
	end

	# 
	def servermsg( servername, messagenumber, message )
		@output.debug( "Numbered server message #{messagenumber} received.\n" )
		@sub.servermsg( servername, messagenumber, message )
	end

	# Methods for unparsable lines
	def unparsable( type, line )
		@output.debug( "Unparsable '#{type}' received.\n" )
		@sub.misc( line )
	end

	def unparsableserver( type, line )
		@output.debug( "Unparsable '#{type}' received.\n" )
		@sub.miscservermsg( line )
	end	

	# Kickstart module autoloading
	def autoload
		if( @status.threads && @config.threads )
			spawn_parser( "autoload" )
		else
			parser( "autoload" )
		end
	end
end
		
