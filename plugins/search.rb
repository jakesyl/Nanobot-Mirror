#!/usr/bin/env ruby
# coding: utf-8


#Search plugin using googleapis
#
require 'rubygems'
require 'nokogiri'
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
		
		@googleapihost	= "ajax.googleapis.com"
		@goolgeapipath	= "/ajax/services/search/web?v=1.0&q="
		
		@isbndbapihost	= "isbndb.com"
		@isbndbapipath	= "/api/books.xml?access_key=%APIKEY%&index1=isbn&value1="
		@isbndbapifile	= "isbndb.apikey"
		
		loadisbndbapikey
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
			json = Net::HTTP.get( @googleapihost, @goolgeapipath + arguments )
			result = googlejsonparse( json )
			
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
	
	# Function to search book titles by ISBN number
	def isbn( nick, user, host, from, msg, arguments, con )
		if( !arguments.nil? && !arguments.empty? )
			arguments.gsub!( /[^0-9\-]/, "" ) # Sanitize ISBN number
			
			# Retreive XML
			xml = Net::HTTP.get( @isbndbapihost, @isbndbapipath + arguments )
			result = isbndbxmlparse( xml )
			
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
			"  search google [query]              - Find someting using Google",
			"  search isbn [query]                - Find book title by ISBN number",
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
	# JSON parser routine for google results
	def googlejsonparse( doc )
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
	
	# XML parser for ISBNdb results
	def isbndbxmlparse( xmldoc )
		puts xmldoc # Debug line
		xmldoc = Nokogiri::XML( xmldoc )
		
		title = xmldoc.at_xpath( "//ISBNdb/BookList/BookData/Title" )
		
		if( title.instance_of? NilClass )
			return ""
		else
			return "Book title: #{title.text}"
		end
		
		# Mark object for garbage collection
		xmldoc = nil
	end
	
	# Load API key for ISBNdb
	def loadisbndbapikey()
		# Check if a appid is stored on disk
		if File.exists?( @config.datadir + '/' + @isbndbapifile )
			
			# Make sure there's a variable instance
			apikey = ""
			
			# Read database from file
			file = File.open( @config.datadir + '/' + @isbndbapifile )
			
				file.each do |line|
				apikey << line
			end
			apikey.gsub!( /[:blank:\n\r]/, "" )
			file.close
			
			# Replace string token with actual key
			@isbndbapipath.gsub!( /%APIKEY%/, apikey )
		else
			@output.bad( "Could not load API key from #{@config.datadir}/#{@isbndbapifile} for ISBNdb search." )
		end
	end
end
