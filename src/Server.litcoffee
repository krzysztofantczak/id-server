Global dependencies.

	_                = require 'underscore'
	async            = require 'async'
	seaport          = require 'seaport'
	{ EventEmitter } = require 'events'

Local dependencies.

	Client         = require './client/Client'
	ManagedPort    = require './ManagedPort'
	idShared       = require 'id-shared'
	{ log, debug } = idShared.debug

Base class for all servers that run by name/version on managed ports. Uses the
Client class to enable servers to connect during startup and talk
automatically.

	class Server extends ManagedPort
		constructor: (options) ->
			debug 'Server#constructor'

			super options

			@clients = []

			if options.clients
				for clientoptions in options.clients
					@addClient clientoptions

		_connectClients: ->
			debug 'Server#_connectClients'

			async.parallel (_.map @clients, ((client) ->
				(cb) ->
					client.once 'connect', cb
					client.connect())), =>
						@emit 'clientsConnected'

		_disconnectClients: ->
			debug 'Server#_disconnectClients'

			async.parallel (_.map @clients, ((client) ->
				(cb) ->
					client.once 'disconnect', cb
					client.disconnect())), =>
						@emit 'clientsDisconnected'

		addClient: (options) ->
			debug 'Server#addClient'

			@clients.push new Client
				name:          options.name
				version:       options.version
				seaportClient: @seaportClient

			this

		removeClient: (name, version) ->
			debug 'Server#removeClient'

			@clients = _.filter @clients, (c) ->
				c.name isnt name and c.version isnt version

			this

Generic start method for Server subclasses that coordinates connecting all the
Client's when the Server starts. We can't let the Server wait for the
availability of it's dependees. It should register to the Service Registry as
soon as possible to not get deadlock situations. Server implementations may
react to their clients reactively anyway and start doing their business when
the clients have connected. Overwritten by child classes.

		start: ->
			debug 'Server#start'

			@_connectClients()

			@emit 'start'

		stop: ->
			debug 'Server#stop'

			@_disconnectClients()

			@emit 'stop'

	module.exports = Server
