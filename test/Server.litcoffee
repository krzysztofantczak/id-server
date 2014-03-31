	chai    = require 'chai'
	expect  = chai.expect
	seaport = require 'seaport'

	Client         = require '../src/client/Client'
	Server         = require '../src/Server'
	idShared       = require 'id-shared'
	{ log, debug } = idShared.debug

	describe 'Server', ->
		beforeEach (cb) ->
			@seaportServerPort = 9000 + Math.floor Math.random() * 1000
			@seaportServer = seaport.createServer()
			@seaportServer.listen @seaportServerPort, =>
				@server = new Server
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

		describe 'constructor', ->
			describe 'when the option clients is defined', ->
				it 'should have added a client for each', (cb) ->
					clientName = Math.random().toString(36).substring(7)

					@server = new Server
						name:    Math.random().toString(36).substring(7)
						version: '0.0.1'

						seaport:
							host: '127.0.0.1'
							port: @seaportServerPort

						clients: [
							name: clientName
							version: '0.0.1'
						]

					expect @server.clients[0]
						.to.be.instanceof Client

					expect @server.clients[0].name
						.to.equal clientName

					cb()

		describe 'addClient', ->
			describe 'when passed a name and version', ->
				it 'should have added a client', (cb) ->
					clientName    = Math.random().toString(36).substring(7)
					clientVersion = '0.0.1'

					@server.addClient
						name:    clientName
						version: clientVersion

					expect @server.clients[0]
						.to.be.instanceof Client

					expect @server.clients[0].name
						.to.equal clientName

					expect @server.clients[0].version
						.to.equal clientVersion

					cb()

		describe 'removeClient', ->
			describe 'when passed a name and version', ->
				it 'should have removed a client', (cb) ->
					clientName    = Math.random().toString(36).substring(7)
					clientVersion = '0.0.1'

					@server.addClient
						name:    clientName
						version: clientVersion

					expect @server.clients.length
						.to.equal 1

					@server.removeClient clientName, clientVersion

					expect @server.clients.length
						.to.equal 0

					cb()

		describe 'start', ->

		describe 'stop', ->

		#describe 'register', ->
		#	it 'should have emitted a `register` event with the port', (cb) ->
		#		@managedPort.once 'register', (port) ->
		#			expect port
		#				.to.be.a 'number'

		#			cb()

		#		@managedPort.register()

		#	it 'should have set the port on the instance', (cb) ->
		#		@managedPort.once 'register', (port) =>
		#			expect @managedPort.port
		#				.to.equal port

		#			cb()

		#		@managedPort.register()

		#	it 'should be queryable by name and version', (cb) ->
		#		@managedPort.once 'register', (port) =>
		#			@ports.get "#{@managedPort.name}@#{@managedPort.version}", ->
		#				cb()

		#			#stop the seaport process

		#		@managedPort.register()

		#describe 'free', ->
		#	it 'should have emitted a `free` event', (cb) ->
		#		@managedPort.once 'free', cb

		#		@managedPort.once 'register', (port) =>
		#			@managedPort.free()

		#		@managedPort.register()

		#	it 'should have freed the port on the instance', (cb) ->
		#		@managedPort.once 'free', =>
		#			expect @managedPort.port
		#				.to.not.exist

		#			cb()

		#		@managedPort.once 'register', (port) =>
		#			@managedPort.free()

		#		@managedPort.register()
