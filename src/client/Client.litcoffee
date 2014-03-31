Global depencencies.

	net              = require 'net'
	http             = require 'http'
	{ EventEmitter } = require 'events'

Local depencies.

	{ log, debug } = require '../../lib/debug'

A class that will establish and make available a connection to a Server. Used
by the Server class for instances to connect to other Server instances. Enables
the servers to talk via a managed interface.

	class Client extends EventEmitter
		constructor: (options = {}) ->
			debug 'Client#constructor'

			super options

			throw new Error 'name option required'          unless options.name
			throw new Error 'version option required'       unless options.version
			throw new Error 'seaportClient option required' unless options.seaportClient

			@name          = options.name
			@port          = undefined
			@protocol      = options.protocol or 'tcp'
			@seaportClient = options.seaportClient
			@version       = options.version

		_connectTCP: (service) ->
			@socket = net.connect service.host, service.port

TODO: Decide about reconnection strategies.

			@socket.on 'connect', =>
				@emit 'connect'

		connect: ->
			debug 'Client#connect'

			@seaportClient.get "#{@name}@#{@version}", (services) =>

TODO: Decide about load balancing.

				service = services[0]

				switch @protocol
					when 'tcp'
						@_connectTcp service

					else
						@emit 'error', new Error 'Unsupported protocol'

		disconnect: ->
			debug 'Client#disconnect'

			@seaportClient.on 'close', =>
				@emit 'disconnect'

			@seaportClient.close()

	module.exports = Client
