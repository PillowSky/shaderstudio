'use strict'

Config = require('../models/config')
Shader = require('../models/shader')

module.exports = (app) ->
	app.get '/', (req, res, next) ->
		ids = Config.config['home.shaders']
		shaderId = ids[Math.floor(Math.random() * ids.length)]

		Shader.get shaderId, (error, doc)->
			return next(new Error(error)) if error
			return next(doc) if not doc

			res.render('index', {'shader': doc, 'config': Config.config})
