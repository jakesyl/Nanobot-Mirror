#!/usr/bin/ruby

# Class used to send output to terminal
class Output
	def initialize( status )
		@status		= status

		@RED		= "\033[31m";
		@GREEN		= "\033[32m";
		@YELLOW		= "\033[33m";
		@BLUE		= "\033[34m";
		@END		= "\033[0m";
	end

	def std( string )
		if( @status.output == 1 )
			$stdout.print(string)
		end
	end

	def info( string )
		if( @status.output == 1 )
			if( @status.colour == 1 )
				$stdout.print(@YELLOW + string + @END)
			else
				$stdout.print(string)
			end
		end
	end

	def special( string )
		if( @status.output == 1 )
			if( @status.colour == 1 )
				$stdout.print(@BLUE + string + @END)
			else
				$stdout.print(string)
			end
		end
	end

	def good( string )
		if( @status.output == 1 )
			if( @status.colour == 1 )
				$stdout.print(@GREEN + string + @END)
			else
				$stdout.print(string)
			end
		end
	end

	def bad( string )
		if( @status.output == 1 )
			if( @status.colour == 1 )
				$stdout.print(@RED + string + @END)
			else
				$stdout.print(string)
			end
		end
	end

	def debug( string )
		if( @status.debug >= 1 )
			$stdout.print(string)
		end
	end

	def debug_extra( string )
		if( @status.debug == 2 )
			$stdout.print(string)
		end
	end

end
