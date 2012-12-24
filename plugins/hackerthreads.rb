#!/usr/bin/env ruby

# Plugin to announce new posts in the channel
class Hackerthreads

	require 'rubygems'
	require 'nokogiri' # Needed for XML parsing

	# This method is called when the plugin is first loaded
	def initialize( status, config, output, irc, timer )
		@status		= status
		@config		= config
		@output		= output
		@irc		= irc
		@timer		= timer

		@channel	= "#hackerthreads"

		@rss_host	= "www.hackerthreads.org"
		@rss_path	= "/rss.php"

		@timeout	= 120
		@last		= ""

		if( @status.threads && @config.threads)
			@ftread		= Thread.new{ check_rss }
		end
	end

	# Default method
	def main( nick, user, host, from, msg, arguments, con )
		check_rss
	end
	private

	# Thread to check for new posts
	def check_rss
		while true
			# Grab rss
			xml = Net::HTTP.get( @rss_host, @rss_path )
			xml = Nokogiri::XML( xml )

			# Parse out info
			title, link = "", ""
			title = xml.xpath( '//item/title' ).first.text
			link  = xml.xpath( '//item/link' ).first.text

			# Check if this is a new post
			if( @last != link )
				@last = link
				@irc.message( @channel, "New post: #{title} #{link}" )
			end

			# Wait for a bit before fetching again
			sleep( @timeout )
		end
	end
end
