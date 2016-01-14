'use strict'

Config = require('../models/config')
Shader = require('../models/shader')

module.exports = (app) ->
	app.get '/view/:shaderId', (req, res, next) ->
		shaderId = req.params.shaderId
		Shader.get shaderId, (error, doc)->
			return next(new Error(error)) if error

			res.render('view', {'shader': doc, 'config': Config.config, 'user': req.cookies.user})
