	chai    = require 'chai'
	dnode   = require 'dnode'
	expect  = chai.expect
	seaport = require 'seaport'

	DnodeServer    = require '../src/DnodeServer'
	idShared       = require 'id-shared'
	{ log, debug } = idShared.debug

	describe 'server', ->
		describe 'DnodeServer', ->
			beforeEach (cb) ->
				@seaportServerPort = 9000 + Math.floor Math.random() * 1000
				@seaportServer = seaport.createServer()
				@seaportServer.listen @seaportServerPort, =>
					@s = new DnodeServer
						name:    Math.random().toString(36).substring(7)
						version: '0.0.1'
						interface:
							work: (cb) ->
								process.nextTick cb
						seaport:
							host: '127.0.0.1'
							port: @seaportServerPort

					cb()

			afterEach (cb) ->
				@seaportServer.on 'close', ->
					cb()

				@seaportServer.close()

			describe 'start', ->
				afterEach ->
					@s.on 'stop', =>
						@s = undefined

					@s.stop()

				it 'should be reachable through Dnode', (cb) ->
					@s.once 'start', =>
						client = dnode.connect @s.port

						debug 'client', client

						client.on 'remote', (remote) ->
							debug 'remote', remote

							remote.work ->
								cb()

					@s.once 'register', (port) =>
						@s.start()

					@s.register()
