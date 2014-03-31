Global dependencies.

	idShared       = require 'id-shared'
	level          = require 'level'
	multilevel     = require 'multilevel'
	net            = require 'net'
	{ log, debug } = idShared.debug

Local dependencies.

	TCPServer = require './TCPServer'

Wraps a Multilevel Server.

	class LevelDBServer extends TCPServer
		constructor: (options) ->
			debug 'LevelDBServer#constructor', options

			super options

			@multilevelDatabase = level "#{__dirname}/../db/#{options.db}"

			@multilevelServer = multilevel.server @multilevelDatabase

			@server.on 'error', (error) =>
				@emit 'error', error

			@server.on 'connection', (clientStream) =>
				clientStream
					.pipe @multilevelServer
					.pipe clientStream

		start: ->
			debug 'LevelDBServer#start'

			@_connectClients()

			@server.listen @port, =>
				@emit 'start'

		stop: ->
			debug 'LevelDBServer#stop'

			@_disconnectClients()

			@server.on 'close', =>
				@emit 'stop'

			@server.close()

	module.exports = LevelDBServer
