	http = require 'http'

	Server         = require './Server'
	{ log, debug } = require '../lib/debug'

	class HTTPServer extends Server
		constructor: (options) ->
			debug 'HTTPServer#constructor'

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
