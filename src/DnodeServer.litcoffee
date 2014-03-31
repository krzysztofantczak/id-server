	net      = require 'net'
	dnode    = require 'dnode'

	idShared       = require 'id-shared'
	{ log, debug } = idShared.debug

	TCPServer = require './TCPServer'

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
