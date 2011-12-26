#!/usr/bin/ruby

# Class to handle console input
require 'commands.rb'
class Console
	def initialize( status, config, output, irc, timer )
		@status		= status
		@config		= config
		@output		= output
		@irc		= irc
		@timer		= timer

		@cmd		= Commands.new( status, config, output, irc, timer, 1 )
	end

	def start
		@output.std( "Commandline input parsing ........ " )

		if( @config.threads == 1 && @status.threads == 1 )
			@output.good( "[OK]\n" )

			Thread.new{ parse }
			#puts t.join # For debugging
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
			@cmd.process( nil, nil, nil, nil, STDIN.gets.chomp )
		end
	end
end
