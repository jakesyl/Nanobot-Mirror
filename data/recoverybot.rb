require 'rubygems'
require 'json'
require 'timeout'
require 'socket'
require 'openssl'

configfile = "data/netsplit.json"

target = ARGV.first
port = 0

# Load config
if File.exists?( configfile )

	jsonline = ""
	File.open( configfile ) do |file|
		file.each do |line|
			jsonline << line
		end
	end
	parsed = JSON.parse( jsonline )

	connect_pass = parsed[ 'connect_pass' ]
	oper_user    = parsed[ 'oper_user' ]
	oper_pass    = parsed[ 'oper_pass' ]
	hub_address  = parsed[ 'hub_address' ]
	
	parsed[ 'nodes' ].each do |node|
		if( node[ 'name' ] == target )
			target = node[ 'ip' ]
			port   = node[ 'port' ]
		end
	end
end

# Start socket
sock = TCPSocket
sock = TCPSocket.open( target, port )

# Start SSL
ssl_context = OpenSSL::SSL::SSLContext.new
ssl_context.verify_mode = OpenSSL::SSL::VERIFY_NONE
ssl_sock = OpenSSL::SSL::SSLSocket.new(sock, ssl_context)
ssl_sock.sync_close = true
ssl_sock.connect

sock = ssl_sock

# Send server connect password
sock.puts( "PASS #{connect_pass}" )

# Send user info
sock.puts( "NICK recoverybot" )
sock.puts( "USER recoverybot 8 *  :nanobot" )

# Identify as oper
sock.puts( "OPER #{oper_user} #{oper_pass}" )

# Tell leaf to reconnect to hub
sock.puts( "CONNECT #{hub_address}" )

# Wait for any output
sleep(4)

# Exit with some grace
sock.puts( "QUIT Leaf should be reconnected." )
sleep(1)
sock.close