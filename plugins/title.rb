#!/usr/bin/env ruby

# Plugin to grab the title of an HTML page to which a link is posted.
class Title

	require 'rubygems'
	require 'mechanize'

	# This method is called when the plugin is first loaded
	def initialize( status, config, output, irc, timer )
		@status		= status
		@config		= config
		@output		= output
		@irc		= irc
		@timer		= timer
	end

	# Default method, called when no argument is given (optional, but highly recomended)
	def main( nick, user, host, from, msg, arguments, con )
		response = getTitle( arguments, true )
		@irc.message( from, response )
	end

	# Method that receives a notification when a message is received, that is not a command (optional)
	def messaged( nick, user, host, from, message )
		if( @config.nick != nick )

			# Parse out URL
			if( message =~ /(https?:\/\/)?([\da-z\.-]+)\.([a-z\.]{2,6})([\/\w\.\-&_=~\?]*)*\/?/ )
				url = $&

				# Look for a title
				response = getTitle( url, false )
				@irc.message( from, response )

				# In case of a youtube link, see if we can get some more info
				if( url =~ /youtube\.com/ )

					# Check if youtube plugin is loaded
					if( @status.checkplugin( "youtube" ) )
						plugin = @status.getplugin( "youtube" )

						plugin.main( nick, user, host, from, nil, url, false )
					end
				end
			end
		end
	end

	# Function to send help about this plugin (Can also be called by the help plugin.)
	def help( nick, user, host, from, msg, arguments, con )
		help = [
			"This plugin grabs the title for any URL in the channel.",
			"  title url gives more verbose output in case of errors."
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

	# Function to do the actual lookup
	def getTitle( url, verbose )
		agent = Mechanize.new
		agent.user_agent = 'Mozilla5 AppleWebKit535 KHTML like Gecko Chrome 13 Safari535' # To prevent any user agent based denails.
		agent.max_file_buffer = 1024

		noerror = false

		begin
			head = agent.head( url )
			size = head['Content-Length']
			type = head['Content-Type']

			if( size.to_i < 5000000 && type =~ /html/ )
				title = agent.get( url ).title

				response = "Title: #{title}"

				# Truncate absurdly long titles to fit IRC.
				response = response[ 0 .. 400 ]

				# Parse out unwanted characters
				response.gsub!( /\r/, "" )
				response.gsub!( /\n/, "" )
				response.gsub!( /\t/, "" )
				response.gsub!( / +/, " " )

				# See if URL itself isn't enough information already.
				words = title.split

				matches = 0
				words.each do |w|
					if( url.match( /#{Regexp.escape( w )}/i ) )
						matches = matches + 1
					end
				end
				matchlevel = matches.to_f / words.length.to_f

				if( matchlevel < 0.75 )
					noerror = true
				end
			else
				if( size.to_i > 1000000000000 )
					size = size.to_f / 1000000000000.0
					unit = "TB"
				elsif( size.to_i > 1000000000 )
					size = size.to_f / 1000000000.0
					unit = "GB"
				elsif( size.to_i > 1000000 )
					size = size.to_f / 1000000.0
					unit = "MB"
				elsif( size.to_i > 1000 )
					size = size.to_f / 1000.0
					unit = "KB"
				else
					unit = "bytes"
				end

				if( size.to_s =~ /([0-9])?\.([0-9]{2})/ )
					size = $&
				else
					size = size.to_s
				end

				response = "File type: #{type} | Size: #{size.to_s} #{unit}."
				noerror = true
			end
		
		rescue Mechanize::RedirectLimitReachedError => e
			response = "Error: Too many redirects."
		rescue Mechanize::RedirectNotGetOrHeadError => e
			response = "Error: Broken redirect header."
		rescue Mechanize::ResponseCodeError => e
			response = "Error: Invalid response code."
		rescue Mechanize::ResponseReadError => e
			response = "Error: Unable to read response."
		rescue Mechanize::RobotsDisallowedError => e
			response = "Error: Disallowed by robots.txt."
		rescue NoMethodError => e
			response = "Error: Page doesn't seem to have a title. #{e.message}"
		rescue Exception => e
			response = "Error: #{e.message}"
		end

		if( noerror )
			return response
		elsif( verbose )
			return response
		end
	end
end
