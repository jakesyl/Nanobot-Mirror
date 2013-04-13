#!/usr/bin/env ruby

# Plugin to get bitcoin value
class Btc

	require 'rubygems'
	require 'json'
	
	# This method is called when the plugin is first loaded
	def initialize( status, config, output, irc, timer )
		@status		= status
		@config		= config
		@output		= output
		@irc		= irc
		@timer		= timer
		
		@api_host	= 'data.mtgox.com'
		@api_path	= '/api/2/BTCUSD/money/ticker'
	end

	# Alias for last
	def main( nick, user, host, from, msg, arguments, con )
		last( nick, user, host, from, msg, arguments, con )
	end
	
	# Get last value
	def last( nick, user, host, from, msg, arguments, con )
		result = JSON.parse( Net::HTTP.get( @api_host, @api_path ) )
		
		if( result[ "result" ] != "success" )
			line = "Mtgox API error."
		else
			line = result[ "data" ][ "last" ][ "display" ]
		end
		
		
		if( con )
			@output.c( line + "\n" )
		else
			@irc.message( from, line )
		end
	end
	
	# Get buy price
	def buy( nick, user, host, from, msg, arguments, con )
		result = JSON.parse( Net::HTTP.get( @api_host, @api_path ) )
		
		if( result[ "result" ] != "success" )
			line = "Mtgox API error."
		else
			line = "Mtgox will buy your bitcoins for #{result[ 'data' ][ 'buy' ][ 'display' ]}."
		end
		
		
		if( con )
			@output.c( line + "\n" )
		else
			@irc.message( from, line )
		end
	end
	
	# Get sell price
	def sell( nick, user, host, from, msg, arguments, con )
		result = JSON.parse( Net::HTTP.get( @api_host, @api_path ) )
		
		if( result[ "result" ] != "success" )
			line = "Mtgox API error."
		else
			line = "Mtgox will sell you bitcoins for #{result[ 'data' ][ 'sell' ][ 'display' ]}."
		end
		
		
		if( con )
			@output.c( line + "\n" )
		else
			@irc.message( from, line )
		end
	end
	
	# Function to send help about this plugin (Can also be called by the help plugin.)
	def help( nick, user, host, from, msg, arguments, con )
		help = [
			"Gets current values from mtgox",
			"  btc          - Alias for 'btc last'",
			"  btc last     - Latest reported value for bitcoins",
			"  btc buy      - What price mtgox will buy your bitcoins for",
			"  btc sell     - What price mtgox will sell you bitcoins for"
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
end
