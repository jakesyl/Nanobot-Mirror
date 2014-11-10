#!/usr/bin/env ruby

require './commands.rb'

# Class to handle IRC commands
class IRCSubs
	def initialize( status, config, output, irc, timer )
		@status		= status
		@config		= config
		@output		= output
		@irc		= irc
		@timer		= timer

		@cmd		= Commands.new( status, config, output, irc, timer, 0 )
	end

	# Functions that are called when actions are detected from IRC.
	def kick( nick, user, host, channel, kicked, reason )
		@output.std( nick + " kicked " + kicked + " from " + channel + ". (" + reason + ")\n" )

		# Check if we need to resend join
		if( @config.nick == kicked && @config.rejoin )
			@timer.action( @config.rejointime, "@irc.join( '#{channel}' )" )
		end

		# Check for plugin hooks
		@status.plugins.each_key do |key|
			if( @status.getplugin( key ).respond_to?( "kicked" ) )
				@status.getplugin( key ).kicked( nick.clone, user.clone, host.clone, channel.clone, kicked.clone, reason.clone )
			end
		end
	end

	def notice( nick,  user,  host,  to,  message )
		@status.plugins.each_key do |key|
			if( @status.getplugin( key ).respond_to?( "noticed" ) )
				@status.getplugin( key ).noticed( nick.clone,  user.clone,  host.clone,  to.clone,  message.clone )
			end
		end
	end

	def join( nick, user, host, channel )
		@status.plugins.each_key do |key|
			if( @status.getplugin( key ).respond_to?( "joined" ) )
				@status.getplugin( key ).joined( nick.clone, user.clone, host.clone, channel.clone )
			end
		end
	end

	def part( nick, user, host, channel )
		@status.plugins.each_key do |key|
			if( @status.getplugin( key ).respond_to?( "parted" ) )
				@status.getplugin( key ).parted( nick.clone, user.clone, host.clone, channel.clone )
			end
		end
	end

	def quit( nick, user, host, message )
		@status.plugins.each_key do |key|
			if( @status.getplugin( key ).respond_to?( "quited" ) )
				@status.getplugin( key ).quited( nick.clone, user.clone, host.clone, message.clone )
			end
		end
	end

	def privmsg( nick, user, host, from, message )
		cmd = @config.command

		# Fall-through for !# 'do not handle' prefix
		if( message =~ /^#{cmd}#/ )
			return
		end

		# Automatically rectify 'from' field for private messages
		if( from == @config.nick )
			from = nick
		end

		# Check if the received message is a bot command
		if( message =~ /^#{cmd}/ )
			@cmd.process( nick, user, host, from, message.gsub( /^#{cmd}/, "" ) )
		else

			# Check for plugins with message hook
			message.gsub!( /^#{cmd}/, "" )
			@status.plugins.each_key do |key|
				if( @status.getplugin( key ).respond_to?( "messaged" ) )
					@status.getplugin( key ).messaged( nick.clone, user.clone, host.clone, from.clone, message.clone )
				end
			end
		end
	end

	# Function to handle autoload message
	def autoload
		if( !@status.autoload )
			tmp = Commands.new( @status, @config, @output, @irc, @timer, 1 )
			tmp.autoload
			tmp = nil
			@status.autoload( 1 )
		end
	end

	# Function for specified server messages
	def servermsg( servername, messagenumber, message )
		@status.plugins.each_key do |key|
			if( @status.getplugin( key ).respond_to?( "servermsg" ) )
				@status.getplugin( key ).servermsg( servername, messagenumber, message )
			end
		end
	end

	# Functions for unknown messages
	def misc( unknown )
		@status.plugins.each_key do |key|
			if( @status.getplugin( key ).respond_to?( "misc" ) )
				@status.getplugin( key ).misc( unknown )
			end
		end
	end

	def miscservermsg( unknown )
		@status.plugins.each_key do |key|
			if( @status.getplugin( key ).respond_to?( "miscservermsg" ) )
				@status.getplugin( key ).miscservermsg( unknown )
			end
		end
	end

	# Function to sanitize user input
	def sanitize( input, downcase = 0 )
		input.gsub!( /[^a-zA-Z0-9 -]/, "" )
		if( downcase == 1 )
			input.downcase!
		end
	end
end
