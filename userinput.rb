#!/usr/bin/ruby

# Class to parse user input
class UserInputParser
	def initialize( status, config, output, irc, timer )
		@status		= status
		@config		= config
		@output		= output
		@irc		= irc
		@timer		= timer
	end

	def start
		@output.std( "Commandline input parsing ........ " )

		if( @config.threads == 1 && @status.threads == 1 )
			@output.good( "[OK]\n" )
			Thread.new{ parse }
		else
			@output.bad( "[NO]\n" )
			@output.debug( "Not parsing user input, threading disabled.\n" )
		end
	end

	def parse
		@output.cspecial( @config.version + " console" )


		while true do
			print( @config.nick + "# " )
			STDOUT.flush
			process( gets.chomp )
		end
	end

	def process( line )
		if( line =~ /^help/ )
			help( line )
		elsif( line =~ /^config/ )
			config( line )
		elsif( line =~ /^nick/ ) # Alias for config nick
			nick( line )
		elsif( line =~ /^quit$/ || line =~ /^exit$/ )
			quit
		else
			@output.cbad( "Command not found\n" )
		end
	end

	def help( line )
		cmd, topic = line.split(' ', 2)
		if( topic == nil )
			@output.cinfo( "Console help" )
			@output.c( "\tnick\t\tChange nickname" )
			@output.c( "\tconfig\t\tChange configuration" )
			@output.c( "\texit\t\tStop bot" )
		elsif( topic == "nick" )
			@output.c( "\t'nick' displays current nickname" )
			@output.c( "\t'nick newnick' changes nickname to newnick" )
		elsif(topic == "config" )
			@output.c( "'config setting' displays current setting" )
			@output.c( "'config setting new' changes setting to new" )
			@output.cinfo( "Available settings:" )
			@output.c( "\tcolour: 1/0 turn colour on/off" )
			@output.c( "\tdebug: 0/1/2 set debug level" )
			@output.c( "\tnick: bot nickname" )
			@output.c( "\toutput: 1/0 turn output on/off" )
		else
			@output.cbad( "No help for " + topic + "\n" )
		end
	end

	def config( line )
		cmd, setting, value = line.split(' ', 3)
		if( setting == nil )
			@output.cinfo( "Usage: config setting (value)" )

		elsif( setting == "colour" || setting == "color" )
			if( value != nil )
				@status.colour( value.to_i )
			end
			@output.c( setting + ": " + @status.colour.to_s )

		elsif( setting == "debug" )
			if( value != nil )
				@status.debug( value.to_i )
			end
			@output.c( setting + ": " + @status.debug.to_s )

		elsif( setting == "output" )
			if( value != nil )
				@status.output( value.to_i )
			end
			@output.c( setting + ": " + @status.output.to_s )

		elsif( setting == "nick" )
			if( value != nil )
				@irc.nick( value )
				@config.nick( value )
			else
				@output.c( setting + ": " + @config.nick )
			end
		else
			@output.cbad( "config " + setting + " not found\n" )
		end
	end

	def nick( line )
		config( "config " + line )
	end

	def quit
		@output.bad( "This will also stop the bot, are you sure? [y/N]: " )
		STDOUT.flush
		ans = gets.chomp
		if( ans =~ /^y$/i )
			@irc.quit( "Stopped from console." )
			@irc.disconnect
			Process.exit
		else
			@output.cinfo( "Continuing" )
		end
	end
end
