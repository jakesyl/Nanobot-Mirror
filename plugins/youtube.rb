#!/usr/bin/env ruby

# Plugin to retreive information about a video trough the youtube API
class Youtube

	require 'rubygems'
	require 'nokogiri' # Needed for XML parsing

	# This method is called when the plugin is first loaded
	def initialize( status, config, output, irc, timer )
		@status		= status
		@config		= config
		@output		= output
		@irc		= irc
		@timer		= timer

		@api_host	= "gdata.youtube.com"
		@api_path	= "/feeds/api/videos/video_id?v=2"
	end

	# Default method
	def main( nick, user, host, from, msg, arguments, con )
		if( arguments =~ /v=([a-zA-Z0-9\-_]{11})/ )
			video_id = $1

			# Build request string
			path = @api_path.gsub( /video_id/, video_id )

			# Retreive xml from Youtube API host
			xml = Net::HTTP.get( @api_host, path )

			# Create Nokogiri object for xml object
			xml = Nokogiri::XML( xml )

			# Parse info
			cat, duration, rating, views, likes, dislikes = "Unknown", 0, 0.0, 0, 0, 0
			xml.xpath('//media:category').each { |node| cat = node['label'].to_s }
			xml.xpath('//yt:duration').each { |node| duration = node['seconds'] }
			xml.xpath('//gd:rating').each { |node| rating = node['average'].to_s }
			xml.xpath('//yt:statistics').each { |node| views = node['viewCount'].to_s }
			xml.xpath('//yt:rating').each { |node|
							likes = node['numLikes'].to_s
							dislikes = node['numDislikes'].to_s }

			# Truncate rating
			if( rating =~ /([0-9])+?\.([0-9]{1})/ )
				rating = $&
			end

			# Format duration
			if( duration.to_i < 3600 )
				duration = Time.at(duration.to_i).gmtime.strftime('%M:%S')
			else
				duration = Time.at(duration.to_i).gmtime.strftime('%R:%S')
			end

			# Build string
			result = "Type: #{cat} | Lenght: #{duration} | Views: #{views} | Rating: #{rating}/5 | Like/dislike: #{likes}/#{dislikes}"

			@irc.message( from, result )
		end
	end

	# Function to send help about this plugin (Can also be called by the help plugin.)
	def help( nick, user, host, from, msg, arguments, con )
		help = [
			"Plugin to retreive data from youtube videos",
			"  youtube url                 - Grab data for youtube video."
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
