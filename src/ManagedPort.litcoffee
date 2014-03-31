	net              = require 'net'
	seaport          = require 'seaport'
	{ EventEmitter } = require 'events'

	idShared       = require 'id-shared'
	{ log, debug } = idShared.debug

	class ManagedPort extends EventEmitter
		constructor: (options) ->
			debug 'ManagedPort#constructor', arguments

			throw new Error 'name option required'         unless options.name
			throw new Error 'version option required'      unless options.name
			throw new Error 'seaport.host option required' unless options.seaport?.host
			throw new Error 'seaport.port option required' unless options.seaport?.port

			@seaportServerHost = options.seaport.host
			@seaportServerPort = options.seaport.port
			@seaportClient     = seaport.connect options.seaport.host, options.seaport.port
			@name              = options.name
			@version           = options.version
			@port              = undefined

		register: ->
			debug 'ManagedPort#register'

			@port = @seaportClient.register
				role:    @name
				version: @version
				host:    '127.0.0.1'

			@emit 'register'

		free: ->
			debug 'ManagedPort#free'

			@seaportClient.free @seaportClient

			@port = undefined

			@emit 'free'

	module.exports = ManagedPort
