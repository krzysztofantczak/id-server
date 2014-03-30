	chai      = require 'chai'
	expect    = chai.expect
	{ spawn } = require 'child_process'

	Task           = require '../../../server/Task'
	{ log, debug } = require '../../../lib/debug'

	newTask = ->
		name:    'foo'
		command: 'node'
		path:    "#{__dirname}/../../../testFixtures/unit/server/Task/daemonWorker.js"

	describe 'Task', ->
		describe 'constructor', ->
			describe 'when the option `command` is not defined', ->
				it 'should throw an error', (cb) ->
					fn = ->
						task = new Task
							name:    'foo'
							path:    "#{__dirname}../../../testFixtures/unit/server/Task/daemonWorker.js"

					expect(fn).to.throw Error

					cb()

			describe 'when the option `name` is not defined', ->
				it 'should throw an error', (cb) ->
					fn = ->
						task = new Task
							command: 'coffee'
							path: 'bar'

					expect(fn).to.throw Error

					cb()

			describe 'when the option `path` is not defined', ->
				it 'should throw an error', (cb) ->
					fn = ->
						task = new Task
							name: 'foo'
							command: 'coffee'

					expect(fn).to.throw Error

					cb()

			describe 'when the option `path` does not exist on disk', ->
				it 'should emit an error', (cb) ->
					task = new Task
						name: 'foo'
						command: 'coffee'
						path: './sdafasdfadsfadf'

					task.on 'error', (error) ->
						cb()

			describe 'when the option `workerCount` is not defined', ->
				it 'should be set to `1`', (cb) ->
					task = new Task newTask()

					expect(task.workerCount).to.equal 1

					cb()

			describe 'when the option `args` is not defined', ->
				it 'should be set to `[]`', (cb) ->
					task = new Task newTask()

					expect(task.args).to.be.an('array')
						.with.deep.property('[0]')
						.that.equals(task.path)

					cb()

		describe 'start', ->
			describe 'when already started', ->
				it 'should throw an error', (cb) ->
					task = new Task newTask()

					task.once 'start', ->
						fn = ->
							task.start()

						expect(fn).to.throw Error

						cb()

					task.start()

			describe 'when started', ->
				it 'should have configured the instance', (cb) ->
					task = new Task newTask()

					task.once 'start', ->
						expect(task.workers).to.have.length 1
						expect(task.pids).to.have.length 1
						expect(task.started).to.equal true

						cb()

					task.start()

			describe 'when a worker stops unexpectedly', ->
				describe 'when the restart option is set to true', ->
					it 'should have launched a new one', (cb) ->
						task = new Task newTask()

						task.restart = true

						task.once 'start', ->
							task.once 'worker', ->
								task.once 'stop', ->
									cb()

								task.stop()

							spawn 'kill', ['-s', 9, task.pids[0]]

						task.start()

		describe 'stop', ->
			describe 'when not yet started', ->
				it 'should throw an error', (cb) ->
					task = new Task newTask()

					fn = ->
						task.stop()

					expect(fn).to.throw Error

					cb()

			describe 'when started', ->
				describe 'when stopped', ->
					it 'should have reset the instance', (cb) ->
						task = new Task newTask()

						task.once 'stop', ->
							expect(task.workers).to.have.length 0
							expect(task.pids).to.have.length 0
							expect(task.started).to.equal false

							cb()

						task.once 'start', ->
							task.stop()

						task.start()
