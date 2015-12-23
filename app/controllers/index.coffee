'use strict'

shader = require('../models/shader')

module.exports = (app) ->
	app.get '/', (req, res) ->
		shaderID = 'XstGR8'
		shader.findID shaderID, (error, doc)->
			if doc
				res.render('index', doc.Shader)
			else
				res.status(404).render('404')
