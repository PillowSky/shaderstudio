'use strict'

Shader = require('../models/shader')

module.exports = (app) ->
	app.get '/view/:shaderId', (req, res) ->
		shaderId = req.params.shaderID
		Shader.findByShaderId shaderId, (error, doc)->
			if doc
				res.render('view', doc)
			else
				res.status(404).render('404')
