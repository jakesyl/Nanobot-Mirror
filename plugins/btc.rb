#!/usr/bin/env ruby

# Plugin to get bitcoin value
class Btc

	require 'rubygems'
	require 'json'
	
	# This method is called when the plugin is first loaded
	def initialize( status, config, output, irc, timer )
		@status   = status
		@config   = config
		@output   = output
		@irc      = irc
		@timer    = timer
		
		@api_host = 'data.mtgox.com'
		@api_path = '/api/2/BTCUSD/money/ticker'
		@last     = 0.0

		@bits_host = 'www.bitstamp.net'
		@bits_path = '/api/ticker/'
		@bits_last = 0.0
	end

	def main( nick, user, host, from, msg, arguments, con )
		uri = URI.parse( "https://#{@bits_host}#{@bits_path}" )
		
		http = Net::HTTP.new(uri.host, uri.port)
		http.use_ssl = true
		http.verify_mode = OpenSSL::SSL::VERIFY_NONE
		
		request = Net::HTTP::Get.new(uri.request_uri)
		response = http.request(request)
		
		result = JSON.parse( response.body )

		# Calculate diff between last and ask
		diff = result[ 'ask' ].to_f - result[ 'last' ].to_f
		diff = ( diff * 1000 ).round / 1000.0
		if( diff > 0 )
			diff = "+#{diff.to_s}"
		else
			diff = "#{diff.to_s}"
		end

		# Calculate delta from last !btc
		ldiff = result[ 'ask' ].to_f - @bits_last
		ldiff = ( ldiff * 1000 ).round / 1000.0
		if( ldiff > 0 )
			ldiff = "+#{ldiff.to_s}"
		else
			ldiff = "#{ldiff.to_s}"
		end
		@bits_last = result[ 'ask' ].to_f
		
		line = "Bitstamp rate: $#{result[ 'ask' ]} #{diff.to_s} (#{ldiff} since last !btc)"

		if( con )
			@output.c( line + "\n" )
		else
			@irc.message( from, line )
		end
	end

	# Get current value
	def mtgox( nick, user, host, from, msg, arguments, con )
		uri = URI.parse( "https://#{@api_host}#{@api_path}" )
		
		http = Net::HTTP.new(uri.host, uri.port)
		http.use_ssl = true
		http.verify_mode = OpenSSL::SSL::VERIFY_NONE
		
		request = Net::HTTP::Get.new(uri.request_uri)
		response = http.request(request)
		
		result = JSON.parse( response.body )
		
		if( result[ "result" ] != "success" )
			line = "Mtgox API error."
		else
			# Calculate delta from API 'last'
			diff = result[ 'data' ][ 'sell' ][ 'value' ].to_f - result[ 'data' ][ 'last' ][ 'value' ].to_f
			diff = ( diff * 1000 ).round / 1000.0
			if( diff > 0 )
				diff = "+#{diff.to_s}"
			else
				diff = "#{diff.to_s}"
			end

			# Calculate delta from last !btc
			ldiff = result[ 'data' ][ 'sell' ][ 'value' ].to_f - @last
			ldiff = ( ldiff * 1000 ).round / 1000.0
			if( ldiff > 0 )
				ldiff = "+#{ldiff.to_s}"
			else
				ldiff = "#{ldiff.to_s}"
			end
			@last = result[ 'data' ][ 'sell' ][ 'value' ].to_f
			
			line = "Mtgox rate: #{result[ 'data' ][ 'sell' ][ 'display' ]} (#{result[ 'data' ][ 'sell' ][ 'value' ]}) #{diff.to_s} (#{ldiff} since last !btc mtgox)"
		end
		
		if( con )
			@output.c( line + "\n" )
		else
			@irc.message( from, line )
		end
	end
	
	# Function to chain BTC and LTC lookup
	def ltc( nick, user, host, from, msg, arguments, con )
		
		# Run main value lookup
		main( nick, user, host, from, msg, arguments, con )
		
		# Check if ltc plugin is loaded
		ratio = ""
		ltcv = nil
		if( @status.checkplugin( "ltc" ) )
			plugin = @status.getplugin( "ltc" )
			ltcv = plugin.main( nick, user, host, from, nil, nil, false )
			btcv = @bits_last
			
			ltctobtc = ltcv / btcv
			ltctobtc = ( ltctobtc * 1000 ).round / 1000.0
			btctoltc = btcv / ltcv
			btctoltc = ( btctoltc * 1000 ).round / 1000.0
			
			ratio = "Ratios: BTC to LTC #{btctoltc} | LTC to BTC #{ltctobtc}"
			
			
		else
			ratio = "Litecoin plugin not loaded."
		end
		
		if( con )
			@output.c( ratio + "\n" )
		else
			@irc.message( from, ratio )
		end
	end
	# Get last value
	def last( nick, user, host, from, msg, arguments, con )
		result = JSON.parse( Net::HTTP.get( @bits_host, @bits_path ) )
		
		line = "#{result[ 'last' ]}"
		
		if( con )
			@output.c( line + "\n" )
		else
			@irc.message( from, line )
		end
	end
	
	# Get buy price
	def buy( nick, user, host, from, msg, arguments, con )
		result = JSON.parse( Net::HTTP.get( @bits_host, @bits_path ) )
		
		line = "Bitstamp will buy your bitcoins for #{result[ 'bid' ]}"
		
		if( con )
			@output.c( line + "\n" )
		else
			@irc.message( from, line )
		end
	end
	
	# Get sell price
	def sell( nick, user, host, from, msg, arguments, con )
		result = JSON.parse( Net::HTTP.get( @bits_host, @bits_path ) )
		
		line = "Bitstamp will sell you bitcoins for #{result[ 'ask' ]}"
		
		if( con )
			@output.c( line + "\n" )
		else
			@irc.message( from, line )
		end
	end

	# Get last value
	def mtgoxlast( nick, user, host, from, msg, arguments, con )
		result = JSON.parse( Net::HTTP.get( @api_host, @api_path ) )
		
		if( result[ "result" ] != "success" )
			line = "Mtgox API error."
		else
			line = "#{result[ 'data' ][ 'last' ][ 'display' ]} (#{result[ 'data' ][ 'last' ][ 'value' ]})"
		end
		
		
		if( con )
			@output.c( line + "\n" )
		else
			@irc.message( from, line )
		end
	end
	
	# Get buy price
	def mtgoxbuy( nick, user, host, from, msg, arguments, con )
		result = JSON.parse( Net::HTTP.get( @api_host, @api_path ) )
		
		if( result[ "result" ] != "success" )
			line = "Mtgox API error."
		else
			line = "Mtgox will buy your bitcoins for #{result[ 'data' ][ 'buy' ][ 'display' ]} (#{result[ 'data' ][ 'buy' ][ 'value' ]})"
		end
		
		
		if( con )
			@output.c( line + "\n" )
		else
			@irc.message( from, line )
		end
	end
	
	# Get sell price
	def mtgoxsell( nick, user, host, from, msg, arguments, con )
		result = JSON.parse( Net::HTTP.get( @api_host, @api_path ) )
		
		if( result[ "result" ] != "success" )
			line = "Mtgox API error."
		else
			line = "Mtgox will sell you bitcoins for #{result[ 'data' ][ 'sell' ][ 'display' ]} (#{result[ 'data' ][ 'sell' ][ 'value' ]})"
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
			"  btc            - Get bitstamp exchange rate (buying rate)",
			"  btc ltc        - Get bitcoin & litecoin exchange rates",
			"  btc last       - Last reported value for bitcoins on  bitstamp",
			"  btc buy        - What price bitstamp will buy your bitcoins for",
			"  btc sell       - What price bitstamp will sell you bitcoins for",
			"  btc mtgoxlast  - Last reported value for bitcoins on mtgox",
			"  btc mtgoxbuy   - What price mtgox will buy your bitcoins for",
			"  btc mtgoxsell  - What price mtgox will sell you bitcoins for"
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
