	chai       = require 'chai'
	dnode      = require 'dnode'
	expect     = chai.expect
	multilevel = require 'multilevel'
	net        = require 'net'
	seaport    = require 'seaport'

	LevelDBServer  = require '../src/LevelDBServer'
	idShared       = require 'id-shared'
	{ log, debug } = idShared.debug

	describe 'server', ->
		describe 'server', ->
			describe 'server', ->
				describe 'LevelDBServer', ->
					beforeEach (cb) ->
						@seaportServerPort = 9000 + Math.floor Math.random() * 1000
						@seaportServer = seaport.createServer()
						@seaportServer.listen @seaportServerPort, =>
							@s = new LevelDBServer
								name:    Math.random().toString(36).substring(7)
								version: '0.0.1'

								seaport:
									host: '127.0.0.1'
									port: @seaportServerPort

								db: 'test'

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

						it 'should be reachable through MultiLevel RPC', (cb) ->
							@s.once 'start', =>
								db  = multilevel.client()
								con = net.connect @s.port
								con
									.pipe db.createRpcStream()
									.pipe con

								con.once 'connect', cb

							@s.once 'register', (port) =>
								@s.start()

							@s.register()
