Global dependencies.

	dnode          = require 'dnode'
	idShared       = require 'id-shared'
	net            = require 'net'
	{ log, debug } = idShared.debug

Local dependencies.

	TCPServer = require './TCPServer'

RPC interface over TCP.

	class DnodeServer extends TCPServer
		constructor: (options) ->
			debug 'DnodeServer#constructor', options

			super options

			@interface = options.interface

			@server.on 'connection', (connection) =>
				dnodeConnection = dnode @interface

				connection
					.pipe dnodeConnection
					.pipe connection

	module.exports = DnodeServer
