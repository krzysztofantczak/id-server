	chai    = require 'chai'
	expect  = chai.expect
	http    = require 'http'
	seaport = require 'seaport'

	HTTPServer     = require '../src/HTTPServer'
	idShared       = require 'id-shared'
	{ log, debug } = idShared.debug

	describe 'HTTPServer', ->
		beforeEach (cb) ->
			@seaportServerPort = 9000 + Math.floor Math.random() * 1000
			@seaportServer = seaport.createServer()
			@seaportServer.listen @seaportServerPort, =>
				@s = new HTTPServer
					name:    Math.random().toString(36).substring(7)
					version: '0.0.1'
					seaport:
						host: '127.0.0.1'
						port: @seaportServerPort

				@s.server.on 'request', (req, res) ->
					res.end()

				cb()

		afterEach (cb) ->
			@seaportServer.on 'close', ->
				cb()

			@seaportServer.close()

		describe 'start', ->
			it 'should have emitted a `start` event', (cb) ->
				@s.once 'start', ->
					cb()

				@s.once 'register', (port) =>
					@s.start()

				@s.register()

			it 'should be reachable through HTTP', (cb) ->
				@s.once 'start', =>
					req = http.request "http://127.0.0.1:#{@s.port}/", =>
						cb()

					req.end()

				@s.once 'register', (port) =>
					@s.start()

				@s.register()

		describe 'stop', ->
			it 'should have emitted a `stop` event', (cb) ->
				@s.once 'stop', ->
					cb()

				@s.once 'start', =>
					@s.stop()

				@s.once 'register', (port) =>
					@s.start()

				@s.register()

			it 'should no longer be reachable through HTTP', (cb) ->
				@s.once 'stop', =>
					req = http.request "http://127.0.0.1:#{@s.port}/"

					req.on 'error', =>
						cb()

					req.end()

				@s.once 'start', =>
					@s.stop()

				@s.once 'register', (port) =>
					@s.start()

				@s.register()
