'use strict'

Shader = require('../models/shader')

module.exports = (app) ->
	app.get '/', (req, res) ->
		shaderId = 'XstGR8'
		Shader.findByShaderId shaderID, (error, doc)->
			if doc
				res.render('index', doc)
			else
				res.status(404).render('404')
