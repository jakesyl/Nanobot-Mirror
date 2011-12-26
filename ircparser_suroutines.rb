#!/usr/bin/ruby

# Methods to handle IRC commands
	def kick( nick, user, host, channel, kicked, reason )
		@output.std( nick + " kicked " + kicked + " from " + channel + ". (" + reason + ")\n" )

		# Check if we need to rejoin
		if( @config.nick == kicked && @config.rejoin == 1 )
			@timer.action( @config.rejointime, "JOIN " + channel )
		end
	end

	def notice( nick,  user,  host,  to,  message )
	end

	def userjoin( nick, user, host, channel )
	end

	def userpart( nick, user, host, channel )
	end

	def userquit( nick, user, host, message )
	end

	def privmsg( nick, user, host, from, message )
	end

	def misc( unknown )
	end
