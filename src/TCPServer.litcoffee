	net = require 'net'

	Server         = require './Server'
	idShared       = require 'id-shared'
	{ log, debug } = idShared.debug

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
