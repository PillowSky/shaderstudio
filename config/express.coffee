'use strict'

express = require 'express'
glob = require 'glob'

favicon = require 'serve-favicon'
logger = require 'morgan'
cookieParser = require 'cookie-parser'
bodyParser = require 'body-parser'
compress = require 'compression'
ehp = require 'ehp'

module.exports = (app, config) ->
	env = process.env.NODE_ENV || 'development'
	app.locals.ENV = env;
	app.locals.ENV_DEVELOPMENT = env == 'development'

	app.engine 'html', ehp.renderFile
	app.set 'views', config.root + '/app/views'
	app.set 'view engine', 'jade'

	app.use favicon(config.root + '/public/img/favicon.ico')
	app.use logger 'dev'
	app.use bodyParser.json()
	app.use bodyParser.urlencoded({extended: true})
	app.use cookieParser()
	app.use compress()
	app.use express.static config.root + '/public'

	controllers = glob.sync config.root + '/app/controllers/**/*.coffee'
	controllers.forEach (controller) ->
		require(controller)(app)

	# catch 404 and forward to error handler
	app.use (req, res, next) ->
		err = new Error 'Not Found'
		err.status = 404
		next err

	# error handlers
	if app.get('env') == 'development'
		# development error handler
		# will print stacktrace
		app.use (err, req, res, next) ->
			res.status err.status || 500
			res.render 'error.jade',
				message: err.message
				error: err
				title: 'error'
	else
		# production error handler
		# no stacktraces leaked to user
		app.use (err, req, res, next) ->
			res.status err.status || 500
			res.render 'error.jade',
				message: err.message
				error: {}
				title: 'error'
