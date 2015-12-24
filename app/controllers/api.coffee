'use strict'

Shader = require('../models/shader')

module.exports = (app) ->
	app.get '/api/shaders', (req, res, next) ->
		Shader.allId (error, docs)->
			return next(new Error(error)) if error
			res.json({Shaders: docs.length, Results: docs})

	app.get '/api/shaders/:shaderId', (req, res, next)->
		Shader.findByShaderId req.params.shaderId, (error, doc)->
			return next(new Error(error)) if error
			return next(doc) if not doc
			res.json(doc)
