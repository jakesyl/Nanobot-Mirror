#!/usr/bin/env ruby

# Plugin to demonstrate the working of plugins
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
			if( message =~ /(https?:\/\/)?([\da-z\.-]+)\.([a-z\.]{2,6})([\/\w\.\-=\?]*)*\/?/ )
				response = getTitle( $&, false )
				@irc.message( from, response )
			end
		end
	end

	# Function to send help about this plugin (Can also be called by the help plugin.)
	def help( nick, user, host, from, msg, arguments, con )
		help = [
			"This plugin grabs the title for a URL."
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
		agent.user_agent = 'Mozilla5 AppleWebKit535 KHTML like Gecko Chrome 13 Safari535' # To prevent any use agent based denails.
		agent.max_file_buffer = 1024

		noerror = false

		begin
			head = agent.head( url )
			size = head['Content-Length']

			if( size.to_i < 5000000 )
				response.gsub!( /\r/, "" )
				response.gsub!( /\n/, "" )
				puts "TITLE:#{response}:"
				noerror = true
			else
				response = "Error: Page seems unreasonably large."
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
			response = "Error: Page doesn't seem to have a title."
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
