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

		@mode      = 0       # 0: Nothing to do. 1: Append. 2: Search/replace
		@separator = " || "
		@channel   = ""

		@addition  = ""

		@search    = ""
		@replace   = ""
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
					@mode     = 1
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

	# Set search query
	def search( nick, user, host, from, msg, arguments, con )
		if( @config.auth( host, con ) )
			if( !arguments.nil? && !arguments.empty? )
				chan, search = arguments.split( ' ', 2 )
				if( chan !~ /^#/ && !con )
					search = arguments
					chan   = from
				end
				if( !chan.nil? && !chan.empty? )
					@search   = search
					@channel  = chan
				end
			else
				if( con )
					@output.cinfo( "Usage: topic search #channel search string" )
				else
					@irc.notice( nick, "Usage: " + @config.command + "topic search #channel search string" )
				end
			end
		end
	end

	# Do search/replace on topic
	def replace( nick, user, host, from, msg, arguments, con )
		if( @config.auth( host, con ) )
			if( !arguments.nil? && !arguments.empty? )
				chan, replace = arguments.split( ' ', 2 )
				if( chan !~ /^#/ && !con )
					replace = arguments
					chan    = from
				end
				if( !chan.nil? && !chan.empty? )
					@mode = 2
					@replace  = replace
					@channel  = chan
					gettopic
				end
			else
				if( con )
					@output.cinfo( "Usage: topic replace #channel replace string" )
				else
					@irc.notice( nick, "Usage: " + @config.command + "topic replace #channel replace string" )
				end
			end
		end
	end

	# Method that receives numbered server messages like MOTD, rules, names etc. (optional)
	def servermsg( servername, messagenumber, message )
		# Topic reply
		if( messagenumber == "332" )
			if( message =~ /^#{@config.nick} #{@channel} :(.+)$/ )
				topic = $1
				if( @mode == 1 )
					@irc.topic( @channel, "#{topic}#{@separator}#{@addition}" )
				elsif( @mode == 2 )
					topic.gsub!(@search, @replace)
					@irc.topic( @channel, topic )
				end
				@mode = 0
			end
		end
	end
	
	# Function to send help about this plugin (Can also be called by the help plugin.)
	def help( nick, user, host, from, msg, arguments, con )
		help = [
			"Plugin to handle topics.",
			"  topic [#chan] New topic              - Set completely new topic.",
			"  topic append [#chan] updated topic   - Append something to current topic.",
			"  topic search [#chan] search string   - Set string to search for. Used along with 'replace'.",
			"  topic replace [#chan] new string     - Replace the part of the topic set by 'search'."
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
