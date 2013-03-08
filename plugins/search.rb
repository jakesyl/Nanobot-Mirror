#!/usr/bin/env ruby
# coding: utf-8


#Search plugin using googleapis
#
require 'rubygems'
require 'json'
require 'cgi'

class Search

	# This method is called when the plugin is first loaded
	def initialize( status, config, output, irc, timer )
		@status		= status
		@config		= config
		@output		= output
		@irc	  	= irc
		@timer		= timer
		
		@apihost	= "ajax.googleapis.com"
		@apipath	= "/ajax/services/search/web?v=1.0&q="
	end

	#default method
	def main( nick, user, host, from, msg, arguments, con )
		google( nick, user, host, from, msg, arguments, con )
	end

	#This method searches google for given arguments and returns a result if found.
	def google( nick, user, host, from, msg, arguments, con )
		if( !arguments.nil? && !arguments.empty? )
			arguments.gsub!( / /, "+" ) # Sanitize search request
			# Retreive JSON
			json = Net::HTTP.get( @apihost, @apipath + arguments )
			puts "#{json}"
			result = jsonparse( json )
			
			if( result.empty? )
				result = "Error: No result."
			end
		else
			result = "Invalid input. Expecting search query."
		end

		if( con )
			@output.c( result + "\n" )
		else
			@irc.message( from, result )
		end
	end

	# Function to send help about this plugin (Can also be called by the help plugin.)
	def help( nick, user, host, from, msg, arguments, con )
		help = [
			"This plugin searches something",
			"  search google [query]     					- Find someting using Google",
			"  search help                        - Show this help"
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
	# JSON parser routine
	def jsonparse( doc )
		doc = JSON.parse( doc )
		
		doc = doc[ "responseData" ][ "results" ]
		
		if( doc.instance_of? NilClass )
			return ""
		else
			title = doc[ 0 ] [ "titleNoFormatting" ]
			url =  CGI::unescape( doc[ 0 ] [ "url" ])

			result = "Result: #{title} - #{url}"
			return result
		end
		
		# Mark object for garbage collection
		doc = nil
	end
end
