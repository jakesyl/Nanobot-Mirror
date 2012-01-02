class Help
	def initialize( status, config, output, irc, timer )
		@status		= status
		@config		= config
		@output		= output
		@irc		= irc
		@timer		= timer
	end

	def main( nick, user, host, from, msg, arguments, con )
		if( arguments.nil? || arguments.empty? )
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
				tmp = [
					"Built in commands:",
					"  quit [message]                      - Make bot quit IRC",
					"  load/unload [plugin]                - Load and unload plugins",
					"  reload [plugin]                     - Reload plugin",
					"  loaded                              - List loaded plugins",
					"  available                           - List all available plugins"
				]
			when "core"
				tmp = [
					"Available commands:",
					"  message [to] [message]              - Send regulare message",
					"  action [to] [action]                - Send action",
					"  notice [to] [message]               - Send notice",
					"  raw [command]                       - Send raw command",
					"  join [channel]                      - Make bot join channel",
					"  part [channel]                      - Make bot part channel",
					"  topic [channe] [topic]              - Set topic for channel",
					"  mode [to] [mode] [subject]          - Set modes",
					"  op/deop [channel] [nick]            - Give/take chan op",
					"  hop/dehop [channel] [nick]          - Give/take chan half-op",
					"  voice/devoice [channel] [nick]      - Give/take voice",
					"  kick [channel] [nick] [reason]      - Kick user from channel",
					"  ban/unban [channel] [host]          - Ban/unban host",
					"  timeban [channel] [host] [seconds]  - Set ban that's automatically removed",
					"  version                             - Check bot version",
					"  uptime                              - Check bot uptime",
					"  nick [nickname]                     - Change bot nickname"
				]

			when "plugins"
				tmp = [
					"Help for plugins:",
					"  To call the main function of a plugin, use the plugin name as a command.",
					"  To call a function within the plugin, use the plugin name followed by the",
					"  function name as a command, separated by a space.",
					"",
					"Examples:",
					"  help                                - Call 'help' plugins main function.",
					"  help plugins                        - Call 'plugins' function from 'help' plugin.",
					"  plugin function [arguments]         - Call 'function' from 'plugin' with 'arguments'."
				]
			when "topic"
				tmp = [ "Don't be a smartass." ]
			else
				tmp = [
					"No help for #{arguments}.",
					"If #{arguments} is a plugin, try it's help function."
				]	
			end

			# Print out help
			tmp.each do |line|
				if( con )
					@output.c( line + "\n" )
				else
					@irc.notice( nick, line )
				end
			end
			tmp = nil
		end
	end
end
