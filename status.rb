#!/usr/bin/ruby

class Status
	def initialize
		@output		= 1
		@colour		= 1
		@debug		= 0
		@login		= 0
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
end
