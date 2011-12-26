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

			begin
				Thread.new{ parse }
			rescue
				@output.debug( "Restarting cmd parsing" )
				retry
			end

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
			process( STDIN.gets.chomp )
		end
	end

	def process( line )
		if( line =~ /^help/ )
			help( line )
		elsif( line =~ /^config/ )
			config( line )
		elsif( line =~ /^notice/ )
			notice( line )
		elsif( line =~ /^nick/ ) # Alias for config nick
			nick( line )
		elsif( line =~ /^message/ )
			message( line )
		elsif( line =~ /^action/ )
			action( line )
		elsif( line =~ /^quit/ || line =~ /^exit/ )
			quit( line )
		else
			@output.cbad( "Command not found\n" )
		end
	end

	def help( line )
		cmd, topic = line.split(' ', 2)
		if( topic == nil )
			@output.cinfo( "Console help" )
			@output.c( "\taction\t\tDo action (/me does something)" )
			@output.c( "\tconfig\t\tChange configuration" )
			@output.c( "\tnick\t\tChange nickname" )
			@output.c( "\tmessage\t\tSend message" )
			@output.c( "\tnick\t\tChange nickname" )
			@output.c( "\tnotice\t\tSend notice" )
			@output.c( "\texit\t\tStop bot" )
		elsif( topic == "nick" )
			@output.c( "\t'nick' displays current nickname" )
			@output.c( "\t'nick newnick' changes nickname to newnick" )
		elsif(topic == "action" )
			@output.c( "action user/channel message" )
			@output.c( "Send ACTION message." )
			@output.c( "In IRC clients this is usually done with /me." )
		elsif(topic == "notice" )
			@output.c( "notice user/channel message" )
			@output.c( "Send notice to user or channel." )
		elsif(topic == "message" )
			@output.c( "message user/channel message" )
			@output.c( "Send message to user or channel." )
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

	def notice( line )
		cmd, to, message = line.split( ' ', 3 )
		if( to != nil && message != nil )
			@irc.notice( to, message )
		else
			@output.cinfo( "Usage: notice send_to message to send" )
		end
	end

	def nick( line )
		config( "config " + line )
	end

	def message( line )
		cmd, to, message = line.split( ' ', 3 )
		if( to != nil && message != nil )
			@irc.message( to, message )
		else
			@output.cinfo( "Usage: message send_to message to send" )
		end
	end

	def action( line )
		cmd, to, action = line.split( ' ', 3 )
		if( to != nil && action != nil )
			@irc.action( to, action )
		else
			@output.cinfo( "Usage: action send_to message to send" )
		end
	end

	def quit( line )
		@output.cbad( "This will also stop the bot, are you sure? [y/N]: " )
		STDOUT.flush
		ans = STDIN.gets.chomp
		if( ans =~ /^y$/i )
			cmd, message = line.split( ' ', 2 )

			if( message == nil )
				@irc.quit( "Stopped from console." )
			else
				@irc.quit( message )
			end

			@irc.disconnect
			Process.exit
		else
			@output.cinfo( "Continuing" )
		end
	end
end
