Global dependencies.
	idShared       = require 'id-shared'
	net            = require 'net'
	{ log, debug } = idShared.debug

Local dependencies.

	Server = require './Server'

Wraps the Node.js net.Server.

	class TCPServer extends Server
		constructor: (options) ->
			debug 'TCPServer#constructor'

			super options

			@server = net.createServer()

			@server.on 'error', (error) =>
				@emit 'error', error

		start: ->
			debug 'TCPServer#start'

			@_connectClients()

			@server.listen @port, =>
				@emit 'start'

		stop: ->
			debug 'TCPServer#stop'

			@_disconnectClients()

			@server.on 'close', =>
				@emit 'stop'

			@server.close()

	module.exports = TCPServer
