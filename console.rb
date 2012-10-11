#!/usr/bin/env ruby

require './commands.rb'

# Class to handle console input
class Console
	def initialize( status, config, output, irc, timer )
		@status		= status
		@config		= config
		@output		= output
		@irc		= irc
		@timer		= timer

		@cmd		= Commands.new( status, config, output, irc, timer, 1 )
	end

	# Start up console
	def start
		@output.std( "Commandline input parsing ........ " )

		if( @config.threads && @status.threads )
			@output.good( "[OK]\n" )

			Thread.new{ parse }
		else
			@output.bad( "[NO]\n" )
			@output.debug( "Not parsing user input, threading disabled.\n" )
		end
	end

	# Parser function
	def parse
		@output.cspecial( @config.version + " console" )

		# Use readline lib if possible
		if( @status.readline )

			# Load tabcomplete items if possible
			if( @status.tabcomplete )
				comp = proc do |s|
					if( Readline.line_buffer =~ /^(#{@status.getBaseComplete.join("|")})/ )
						@status.getPluginComplete( Readline.line_buffer ).grep(/^#{Regexp.escape(s)}/)
					else
						@status.getBaseComplete.grep(/^#{Regexp.escape(s)}/)
					end
				end

				Readline.completion_append_character = " "
				Readline.completion_proc = comp
			end

			# Read lines
			while buf = Readline.readline("#{@config.nick}# ", true)
				@cmd.process( "", "", "", "", buf )
			end
		else
			# Fallback to STDIO console
			while true do
				print( "#{@config.nick}# " )
				STDOUT.flush
				@cmd.process( "", "", "", "", STDIN.gets.chomp )
			end
		end
	end
end
