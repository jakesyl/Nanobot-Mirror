#!/usr/bin/env ruby

# Plugin to get litecoin value
class Dogecoin

	require 'rubygems'
	require 'json'
	
	# This method is called when the plugin is first loaded
	def initialize( status, config, output, irc, timer )
		@status   = status
		@config   = config
		@output   = output
		@irc      = irc
		@timer    = timer
		
		@api_host = 'pubapi.cryptsy.com'
		@api_path = '/api.php?method=singlemarketdata&marketid=132'
		
		@last     = 0.0
	end

	# Alias for last
	def main( nick, user, host, from, msg, arguments, con )
		uri = URI.parse( "http://#{@api_host}#{@api_path}" )
		
		http = Net::HTTP.new(uri.host, uri.port)
		
		request = Net::HTTP::Get.new(uri.request_uri)
		response = http.request(request)
		
		result = JSON.parse( response.body )
		

		# Calculate delta from last !btc
		ldiff = result[ 'return' ][ 'markets' ][ 'DOGE' ][ 'lasttradeprice' ].to_f - @last
		ldiff = ( ldiff * 1000 ).round / 1000.0
		if( ldiff > 0 )
			ldiff = "+#{ldiff.to_s}"
		else
			ldiff = "#{ldiff.to_s}"
		end
		@last = result[ 'return' ][ 'markets' ][ 'DOGE' ][ 'lasttradeprice' ].to_f
		
		rounded = "#{( result[ 'return' ][ 'markets' ][ 'DOGE' ][ 'lasttradeprice' ].to_f * 100 ).round / 100.0}"
		
		line = "Cryptsy DOGE/BTC rate: #{rounded} (#{result[ 'return' ][ 'markets' ][ 'DOGE' ][ 'lasttradeprice' ]}) (#{ldiff} since last !dogecoin)"
		
		if( con )
			@output.c( line + "\n" )
		else
			@irc.message( from, line )
		end
	end
	
	# Function to send help about this plugin (Can also be called by the help plugin.)
	def help( nick, user, host, from, msg, arguments, con )
		help = [
			"Gets current litecoin values from Btc-e",
			"  dogecoin          - Get DOGE/BTC exchange rate"
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
