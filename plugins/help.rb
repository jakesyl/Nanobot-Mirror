class Help
	def initialize( status, config, output, irc, timer )
		@status		= status
		@config		= config
		@output		= output
		@irc		= irc
		@timer		= timer
	end


	def main( nick, user, host, from, msg, arguments, con )
		if( arguments == nil )
			# General help
			if( con )
				@output.cinfo( "Use 'help topic' for help on a specific topic." )
				@output.c( "Help topics: commands, core, plugins\n" )
			else
				@irc.notice( nick, "Use 'help topic' for help on a specific topic." )
				@irc.notice( nick, "Help topics: commands, core, plugins" )
			end
		else
			# Specific help
			case arguments
			when "commands"
			when "core"
				tmp = "Available commands: version, uptime, op, deop, hop, dehop, voice, devoice, timeban, message, action, notice, join, part"
				if( con )
					@output.c( tmp + "\n" )
				else
					@irc.notice( nick, tmp )
				end
				tmp = nil
			when "plugins"
			when "topic"
				if( con )
					@output.c( "Don't be a smartass.\n" )
				else
					@irc.notice( nick, "Don't be a smartass." )
				end
			else
				if( con )
					@output.c( "No help for #{arguments}.\n" )
				else
					@irc.notice( nick, "No help for #{arguments}." )
				end
			end
		end	
	end
end
