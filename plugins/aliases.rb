#!/usr/bin/env ruby

# Plugin that allows you to alias certain methods and plugins
class Aliases

	# This method is called when the plugin is first loaded
	def initialize( status, config, output, irc, timer )
		@status  = status
		@config  = config
		@output  = output
		@irc     = irc
		@timer   = timer

		@alias   = {
			"twitter"  => "twit",
			"coins" => "btc ltc"
		}
	end

	# Grab aliasses
	def alias( current )
		@alias.each do |key, value| 
			current.gsub!( /^#{key}/, value)
		end
		return ( current )
	end
end
