#!/usr/bin/env ruby

# Plugin to work with channel topics
class Topic

	# This method is called when the plugin is first loaded
	def initialize( status, config, output, irc, timer )
		@status  = status
		@config  = config
		@output  = output
		@irc     = irc
		@timer   = timer

		@separator = " || "
		@addition  = ""
		@channel   = ""
	end

	# Default method, called when no argument is given (optional, but highly recomended)
	def main( nick, user, host, from, msg, arguments, con )
		settopic( nick, user, host, from, msg, arguments, con )
	end

	# Settopic command
	def settopic( nick, user, host, from, msg, arguments, con )
		if( @config.auth( host, con ) )
			if( !arguments.nil? && !arguments.empty? )
				chan, topic = arguments.split( ' ', 2 )
				if( chan !~ /^#/ && !con )
					topic = arguments
					chan = from
				end
				if( !chan.nil? && !chan.empty? )
					@irc.topic( chan, topic )
				end
			else
				if( con )
					@output.cinfo( "Usage: topic #channel new topic" )
				else
					@irc.notice( nick, "Usage: " + @config.command + "topic #channel new topic" )
				end
			end
		end
	end

	# Append to topic command
	def append( nick, user, host, from, msg, arguments, con )
		if( @config.auth( host, con ) )
			if( !arguments.nil? && !arguments.empty? )
				chan, topic = arguments.split( ' ', 2 )
				if( chan !~ /^#/ && !con )
					topic = arguments
					chan = from
				end
				if( !chan.nil? && !chan.empty? )
					@addition = topic
					@channel  = chan
					gettopic
				end
			else
				if( con )
					@output.cinfo( "Usage: topic append #channel added topic" )
				else
					@irc.notice( nick, "Usage: " + @config.command + "topic append #channel added topic" )
				end
			end
		end
	end

	# Method that receives numbered server messages like MOTD, rules, names etc. (optional)
	def servermsg( servername, messagenumber, message )
		# Topic reply
		if( messagenumber == "332" )
			if( message =~ /^#{@config.nick} #{@channel} :(.+)$/ )
				@irc.topic( @channel, "#{$1}#{@separator}#{@addition}" )
			end
		end
	end
	
	# Function to send help about this plugin (Can also be called by the help plugin.)
	def help( nick, user, host, from, msg, arguments, con )
		help = [
			"Plugin to handle topics.",
			"  topic [#chan] New topic              - Set completely new topic.",
			"  topic append [#chan] updated topic   - Append something to current topic."
		]

		# Print out help
		help.each do |line|
			if( con )
				@output.c( line + "\n" )
			else
				@irc.notice( nick, line )
			end
		end
	end

	private

	# Function to request current topic from IRC server
	def gettopic
		@irc.raw( "TOPIC #{@channel}" )
	end
end
