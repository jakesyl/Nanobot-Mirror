#!/usr/bin/ruby

class Config
	def initialize
		@nick		= "nanodev"					# Bot nickname
		@user		= "nanobot"					# IRC username
		@pass		= ""						# NickServ password
		@version	= "Nanobot 4.0 beta"		# Version

		@attention	= "?"						# Character prefix for commands (one char)

#		@server		= "irc.insomnia247.nl"		# IPv4 address
		@server		= "127.0.0.1"				# IPv4 address
		@server6	= "irc6.insomnia247.nl"		# IPv6 address
		@port		= 6667						# Normal port
		@sslport	= 6697						# SSL port

		@channels	= ("#bot", "#test")			# Autojoin channel list

		@opers		= ("insomnia247.nl")		# Opers list

		@data		= "data"					# Data directory
		@plugins	= "plugins"					# Plugin directory
		@autoload	= (),						# Plugin autoload list

		@autorejoin	= 1							# Rejoin on kick
		@rejointime	= 3							# Time to wait before rejoin (seconds)

		@pingwait	= 0							# Wait for server's first PING
		@conn_time	= 20						# Connect timeout
		@timeout	= 300						# IRC timeout

		@use_ipv6	= 0							# Prefer IPv6
		@use_ssl	= 0							# Prefer SSL
		@ssl_verif	= 0x00						# Verification process to be performed on peer certificate.
												# This can be a combination of
												#	0x00 (don't verify)
												#	0x01 (verify peer)
												#	0x02 (fail verification if there's no peer certificate)
												#	0x04 (verify client once)

		@sslfback	= 0							# Allow fallback to insecure connect when SSL isn't available
		@ipv6fback	= 1							# Allow fallback to IPv4 when IPv6 isn't available

		@output		= ""					# System object, do not modify
	end

	def server( server = "" )
		if( server != "" )
			@server = server
		end

		return @server
	end

	def port( port = "" )
		if( port != "" )
			@port = port
		end

		return @port
	end

end
