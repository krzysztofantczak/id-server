clean       = require 'gulp-clean'
coffee      = require 'gulp-coffee'
gulp        = require 'gulp'
ignore      = require 'gulp-ignore'
jade        = require 'gulp-jade'
less        = require 'gulp-less'
nodemon     = require 'gulp-nodemon'
templatizer = require 'templatizer'
watch       = require 'gulp-watch'
cp          = require 'child_process'

log = console.log.bind console

config =
	directories:
		source: './src'
		build:  './build'
		test:   './test'

		lib:           'lib'
		client:        'client'
		server:        'server'
		documentation: 'doc'

runTests = (exit, reporter, cb) ->
	mochaInstance = cp.spawn 'mocha', [
		'--recursive'
		'--compilers'
		'coffee:coffee-script/register'
		'--compilers'
		'litcoffee:coffee-script/register'
		'--reporter'
		'spec'
		'./test'
	]

	mochaInstance.stdout.on 'data', (data) ->
		process.stdout.write data

	mochaInstance.stderr.on 'data', (data) ->
		process.stdout.write data

	mochaInstance.once 'close', ->
		if exit
			process.exit()

		else
			cb()

gulp.task 'clean', ->
	gulp.src "#{config.directories.build}/*", read: false
		.pipe clean force: true

gulp.task 'copy', ->
	gulp.src [ "#{config.directories.source}/**/*", "!**/*.coffee", "!**/*.litcoffee", "!**/*.less" ]
		.pipe gulp.dest "#{config.directories.build}"

gulp.task 'compile:coffee', ->
	source = gulp.src [ "#{config.directories.source}/**/*.coffee", "#{config.directories.source}/**/*.litcoffee" ]

	source
		.pipe coffee bare: true
		.pipe gulp.dest "#{config.directories.build}"

gulp.task 'compile:less', ->
	gulp.src "#{config.directories.source}/#{config.directories.client}/less/app.less"
		.pipe less()
		.pipe gulp.dest "#{config.directories.build}/#{config.directories.client}/css"

gulp.task 'compile:templates', (cb) ->
	from = "#{config.directories.source}/#{config.directories.client}/templates"
	to   = "#{config.directories.build}/#{config.directories.client}/js/templates.js"

	try
		templatizer from, to
	catch error
		log 'No templates'

	cb()

gulp.task 'compile', [
	'compile:coffee'
	'compile:less'
	'compile:templates'
]

gulp.task 'test', ['compile', 'copy'], (cb) ->
	runTests true, 'spec', cb
	return

gulp.task 'watch', ['compile', 'copy'], ->
	compileCoffee = (src) ->
		destination = gulp.dest "#{config.directories.build}"

		destination.on 'end', ->
			runTests false, 'min', ->

		src
			.pipe coffee bare: true
			.pipe destination

	watch {
		name: 'watch.coffee'
		glob: "#{config.directories.source}/**/*.coffee"
	}, compileCoffee

	watch {
		name: 'watch.litcoffee'
		glob: "#{config.directories.source}/**/*.litcoffee"
	}, compileCoffee

	watch {
		name: 'watch.less'
		glob: "#{config.directories.source}/**/*.less"
	}, (files) ->
		gulp.src "#{config.directories.source}/#{config.directories.client}/less/app.less"
			.pipe less()
			.pipe gulp.dest "#{config.directories.build}/#{config.directories.client}/css"

	watch {
		name: 'watch.jade'
		glob: "#{config.directories.source}/**/*.jade"
	}, (files) ->
		from = "#{config.directories.source}/#{config.directories.client}/templates"
		to   = "#{config.directories.build}/#{config.directories.client}/js/templates.js"

		try
			templatizer from, to
		catch error
			log 'No templates'

	watch {
		name: 'watch.copy'
		glob: "#{config.directories.source}/**/*"
	}, (files) ->
		files
			.pipe ignore.exclude '**/*.less'
			.pipe ignore.exclude '**/*.coffee'
			.pipe ignore.exclude '**/*.litcoffee'
			.pipe ignore.exclude '**/*.jade'
			.pipe gulp.dest "#{config.directories.build}"

	monitor = nodemon
		script: 'index.js'
		watch:  [ "#{config.directories.build}" ]
		ext:    'js css html'

gulp.task 'default', [
	'compile'
	'copy'
	'test'
]
