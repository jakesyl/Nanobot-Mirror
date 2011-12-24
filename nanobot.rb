#!/usr/bin/ruby

# Load support files
require 'socket'
require 'openssl'
require 'config.rb'
require 'startup.rb'

begin
	require 'something'
rescue LoadError
	$stderr.print "" + $! + "\n"
end

config = Config.new

sock = TCPSocket.open( config.host, config.port )

while line = sock.gets
	puts line.chop
end

sock.close
