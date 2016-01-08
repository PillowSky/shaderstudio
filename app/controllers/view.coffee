'use strict'

Config = require('../models/config')
Shader = require('../models/shader')

module.exports = (app) ->
	app.get '/view/:shaderId', (req, res, next) ->
		shaderId = req.params.shaderId
		Shader.findByShaderId shaderId, (error, doc)->
			return next(new Error(error)) if error
			return next(doc) if not doc

			res.render('view', {'shader': doc, 'config': Config.config})
