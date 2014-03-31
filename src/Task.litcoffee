Global dependencies.
Local dependencies.
	_                = require 'underscore'
	async            = require 'async'
	fs               = require 'fs'
	idShared         = require 'id-shared'
	{ EventEmitter } = require 'events'
	{ log, debug }   = idShared.debug
	{ spawn }        = require 'child_process'

Delegates work in parallel over workers

- TODO: connect stdin/out/err in a meaningful way.
- TODO: emit 'done' when the task is done

	class Task extends EventEmitter
		constructor: (options) ->
			debug 'Task#constructor', arguments

			throw new Error 'command option required' unless options.command
			throw new Error 'name option required'    unless options.name
			throw new Error 'path option required'    unless options.path


			@command     = options.command
			@name        = options.name
			@path        = options.path
			@workerCount = options.workerCount or 1
			@restart     = options.restart or false
			@args        = options.args or []
			@args.unshift @path

			debug 'Task#constructor args', @args

			@cwd         = options.cwd
			@env         = options.env or process.env
			@detached    = options.detached
			@uid         = options.uid
			@gid         = options.gid

			@pids        = []
			@workers     = []
			@started     = false

			fs.exists @path, (exists) =>
				@emit 'error', new Error 'path does not exist' unless exists

Add a worker to @workers and @pids

		_addWorker: ->
			debug 'Task#_addWorker'

			worker = spawn "#{@command}", @args,
				cwd:      @cwd
				env:      @env
				detached: @detached
				uid:      @uid
				gid:      @gid

			worker.on 'error', (error) =>
				throw error
				@emit 'error', error

			worker.once 'exit', (code, signal) =>
				@_removeWorker worker

Restart if the restart option is set and unless it was a clean exit or SIGTERM.

				if @restart and not (code in [null, 0, 143] and signal in [null, 'SIGTERM'])
					debug "worker #{worker.pid} exited (code: #{code}, signal: #{signal}), restarting..."
					@_addWorker()

			@pids.push worker.pid
			@workers.push worker

			@emit 'worker', worker

Remove a worker from @workers and @pids

		_removeWorker: (worker) ->
			debug 'Task#_removeWorker', worker.pid

			@pids = _.filter @pids, (pid) ->
				pid isnt worker.pid

			@workers = _.filter @workers, (worker) ->
				worker.pid isnt worker.pid

		_stopWorker: (worker, cb) ->
			debug 'Task#_stopWorker', worker.pid

			worker.once 'exit', cb

			worker.kill()

		start: ->
			debug 'Task#start', arguments

			throw new Error 'already started' if @started

			for i in [ 0...@workerCount ]
				@_addWorker()

			@started = true

			@emit 'start'

		stop: ->
			debug 'Task#stop', arguments

			throw new Error 'not started' unless @started

			fn = (worker) =>
				(cb) =>
					@_stopWorker worker, cb

			async.parallel _.map(@workers, fn), (error) =>
				@started = false
				@emit 'stop'

	module.exports = Task
