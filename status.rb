#!/usr/bin/ruby

# Class bot uses to store it's status
# Do not modify variables manually
class Status
	def initialize
		@output		= 1
		@colour		= 1
		@debug		= 0
		@login		= 0
		@threads	= 0
		@ssl		= 0
		@showconf	= 0
		@console	= 1
		@startup	= Time.new
	end

	def output( output = "" )
		if( output != "" )
			@output = output
		end
		return @output
	end

	def colour( colour = "" )
		if( colour != "" )
			@colour = colour
		end
		return @colour
	end

	def debug( debug = "" )
		if( debug != "" )
			@debug = debug
		end
		return @debug
	end

	def login( login = "" )
		if( login != "" )
			@login = login
		end
		return @login
	end

	def threads( threads = "" )
		if( threads != "" )
			@threads = threads
		end
		return @threads
	end

	def ssl( ssl = "" )
		if( ssl != "" )
			@ssl = ssl
		end
		return @ssl
	end

	def console( console = "" )
		if( console != "" )
			@console = console
		end
		return @console
	end

	def showconfig( show = "" )
		if( show != "" )
			@showconf = show
		end
		return @showconf
	end

	def startup
		return @startup
	end
end
