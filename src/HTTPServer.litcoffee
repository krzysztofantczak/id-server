Global dependencies.

	http           = require 'http'
	idShared       = require 'id-shared'
	{ log, debug } = idShared.debug

Local dependencies.

	Server = require './Server'

Wraps the Node.js http.Server

	class HTTPServer extends Server
		constructor: (options) ->
			debug 'HTTPServer#constructor', options

			super options

			@server = http.createServer()

			@server.on 'error', (error) =>
				@emit 'error', error

		start: ->
			debug 'HTTPServer#start'

			@_connectClients()

			@server.listen @port, =>
				@emit 'start'

		stop: ->
			debug 'HTTPServer#stop'

			@_disconnectClients()

			@server.on 'close', =>
				@emit 'stop'

			@server.close()

	module.exports = HTTPServer
