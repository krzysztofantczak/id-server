	chai    = require 'chai'
	expect  = chai.expect
	net     = require 'net'
	seaport = require 'seaport'

	TCPServer      = require '../src/TCPServer'
	idShared       = require 'id-shared'
	{ log, debug } = idShared.debug

	describe 'TCPServer', ->
		beforeEach (cb) ->
			@seaportServerPort = 9000 + Math.floor Math.random() * 1000
			@seaportServer = seaport.createServer()
			@seaportServer.listen @seaportServerPort, =>
				@tcpServer = new TCPServer
					name:    Math.random().toString(36).substring(7)
					version: '0.0.1'
					seaport:
						host: '127.0.0.1'
						port: @seaportServerPort

				cb()

		afterEach (cb) ->
			@seaportServer.on 'close', ->
				cb()

			@seaportServer.close()

		describe 'start', ->
			it 'should have emitted a `start` event', (cb) ->
				@tcpServer.once 'start', ->
					cb()

				@tcpServer.once 'register', (port) =>
					@tcpServer.start()

				@tcpServer.register()

			it 'should be reachable through TCP', (cb) ->
				@tcpServer.once 'start', =>
					client = net.connect @tcpServer.port

					client.on 'connect', =>
						cb()

				@tcpServer.once 'register', (port) =>
					@tcpServer.start()

				@tcpServer.register()

		describe 'stop', ->
			it 'should have emitted a `stop` event', (cb) ->
				@tcpServer.once 'stop', ->
					cb()

				@tcpServer.once 'start', =>
					@tcpServer.stop()

				@tcpServer.once 'register', (port) =>
					@tcpServer.start()

				@tcpServer.register()

			it 'should no longer be reachable through TCP', (cb) ->
				@tcpServer.once 'start', =>
					client = net.connect @tcpServer.port

					@tcpServer.once 'stop', =>
						failingClient = net.connect @tcpServer.port

						failingClient.on 'error', ->
							cb()

					client.on 'close', =>

					client.on 'connect', =>
						@tcpServer.stop()

						# Force an end on the client side to fully close the server.
						client.end()

				@tcpServer.once 'register', (port) =>
					@tcpServer.start()

				@tcpServer.register()
