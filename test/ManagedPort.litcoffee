	chai    = require 'chai'
	expect  = chai.expect
	seaport = require 'seaport'

	ManagedPort    = require '../src/ManagedPort'
	idShared       = require 'id-shared'
	{ log, debug } = idShared.debug

	describe 'ManagedPort', ->
		describe 'constructor', ->
			describe 'when the option `name` is not defined', ->
				it 'should throw an error', (cb) ->
					fn = ->
						service = new ManagedPort
							version: '0.0.1'
							seaport:
								host: '127.0.0.1'
								port: 9000

					expect(fn).to.throw Error

					cb()

		beforeEach (cb) ->
			@seaportServerPort = 9000 + Math.floor Math.random() * 1000
			@seaportServer = seaport.createServer()
			@seaportServer.listen @seaportServerPort, =>
				@ports = seaport.connect '127.0.0.1', @seaportServerPort

				@ports.once 'connect', cb

				@managedPort = new ManagedPort
					name:    Math.random().toString(36).substring(7)
					version: '0.0.1'
					seaport:
						host: '127.0.0.1'
						port: @seaportServerPort

		afterEach (cb) ->
			@seaportServer.on 'close', ->
				cb()

			@seaportServer.close()

		describe 'register', ->
			it 'should have emitted a `register` event', (cb) ->
				@managedPort.once 'register', cb
				@managedPort.register()

			it 'should have set the port on the instance', (cb) ->
				@managedPort.once 'register', =>
					expect @managedPort.port
						.to.be.a 'number'

					cb()

				@managedPort.register()

			it 'should be queryable by name and version', (cb) ->
				@managedPort.once 'register', (port) =>
					@ports.get "#{@managedPort.name}@#{@managedPort.version}", ->
						cb()

					#stop the seaport process

				@managedPort.register()

		describe 'free', ->
			it 'should have emitted a `free` event', (cb) ->
				@managedPort.once 'free', cb

				@managedPort.once 'register', (port) =>
					@managedPort.free()

				@managedPort.register()

			it 'should have freed the port on the instance', (cb) ->
				@managedPort.once 'free', =>
					expect @managedPort.port
						.to.not.exist

					cb()

				@managedPort.once 'register', (port) =>
					@managedPort.free()

				@managedPort.register()
