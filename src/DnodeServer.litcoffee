	net   = require 'net'
	dnode = require 'dnode'

	TCPServer      = require './TCPServer'
	{ log, debug } = require '../lib/debug'

	class DnodeServer extends TCPServer
		constructor: (options) ->
			debug 'DnodeServer#constructor'

			super options

			@interface = options.interface

			@server.on 'connection', (connection) =>
				dnodeConnection = dnode @interface

				connection
					.pipe dnodeConnection
					.pipe connection

	module.exports = DnodeServer
