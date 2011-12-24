#!/usr/bin/ruby

class Startup
	def initialize( output, config, status )
		@output	= output
		@config	= config
		@status	= status
	end

	def checksocket
		@output.std( "Checking for socket libs ......... " )
		begin
			require 'socket'
			@output.good( "[OK]\n" )
		rescue LoadError
			@output.bad( "[NO]\n" )
			@output.info( "Ruby socket library needs to be installed.\n" )
			Process.exit
		end
	end

	def checkopenssl
		@output.std( "Checking for openssl support ..... " )
		begin
			require 'openssl'
			@output.good( "[OK]\n" )
		rescue LoadError
			@output.bad( "[NO]\n" )
		end
	end

	def checkthreads
		@output.std( "Checking for threading support ... " )
		begin
			require 'thread'
			@output.good( "[OK]\n" )
		rescue LoadError
			@output.bad( "[NO]\n" )
			@output.info( "Ruby thread library needs to be installed.\n" )
			Process.exit
		end
	end
end
