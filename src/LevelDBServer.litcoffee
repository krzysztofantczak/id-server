	multilevel = require 'multilevel'
	net        = require 'net'
	level      = require 'level'

	TCPServer      = require './TCPServer'
	idShared       = require 'id-shared'
	{ log, debug } = idShared.debug

	class LevelDBServer extends TCPServer
		constructor: (options) ->
			debug 'LevelDBServer#constructor'

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
