#!/usr/bin/env ruby

# Plugin to get litecoin value
class Ltc

	require 'rubygems'
	require 'json'
	
	# This method is called when the plugin is first loaded
	def initialize( status, config, output, irc, timer )
		@status		= status
		@config		= config
		@output		= output
		@irc		= irc
		@timer		= timer
		
		@api_host	= 'btc-e.com'
		@api_path	= '/api/2/ltc_usd/ticker'
		
		@last		= 0.0
	end

	# Alias for last
	def main( nick, user, host, from, msg, arguments, con )
		uri = URI.parse( "https://#{@api_host}#{@api_path}" )
		
		puts "past uri #{uri.to_s}"
		
		http = Net::HTTP.new(uri.host, uri.port)
		http.use_ssl = true
		http.verify_mode = OpenSSL::SSL::VERIFY_NONE
		
		request = Net::HTTP::Get.new(uri.request_uri)
		response = http.request(request)
		
		result = JSON.parse( response.body )
		
		# Calculate delta from API 'last'
		diff = result[ 'ticker' ][ 'sell' ].to_f - result[ 'ticker' ][ 'last' ].to_f
		diff = ( diff * 1000 ).round / 1000.0
		if( diff > 0 )
			diff = "+#{diff.to_s}"
		else
			diff = "#{diff.to_s}"
		end

		# Calculate delta from last !btc
		ldiff = result[ 'ticker' ][ 'sell' ].to_f - @last
		ldiff = ( ldiff * 1000 ).round / 1000.0
		if( ldiff > 0 )
			ldiff = "+#{ldiff.to_s}"
		else
			ldiff = "#{ldiff.to_s}"
		end
		@last = result[ 'ticker' ][ 'sell' ].to_f
		
		rounded = "$#{( result[ 'ticker' ][ 'sell' ].to_f * 100 ).round / 100.0}"
		
		line = "Btc-e rate: #{rounded} (#{result[ 'ticker' ][ 'sell' ]}) #{diff.to_s} (#{ldiff} since last !ltc)"
		
		if( con )
			@output.c( line + "\n" )
		else
			@irc.message( from, line )
		end
		
		# Check for chained calling
		if( caller[ 0 ][ /([a-zA-Z0-9]+)(\.rb)/, 1 ] == "btc" )
			return result[ 'ticker' ][ 'sell' ].to_f
		end
	end
	
	# Function to send help about this plugin (Can also be called by the help plugin.)
	def help( nick, user, host, from, msg, arguments, con )
		help = [
			"Gets current litecoin values from Btc-e",
			"  btc          - Get Btc-e exchange rat rate (buying rate)"
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
