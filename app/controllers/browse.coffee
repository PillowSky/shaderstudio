'use strict'

Shader = require('../models/shader')
Config = require('../models/config')

module.exports = (app) ->
	app.get '/browse', (req, res, next) ->
		page = req.query.page || 1
		pageItems = 12
		Shader.select {}, 'info.liked', (page - 1) * pageItems, pageItems, (error, docs)->
			return next(new Error(error)) if error
			return next(docs) if not docs

			res.render('search', {'shaders': docs, 'config': Config.config})
