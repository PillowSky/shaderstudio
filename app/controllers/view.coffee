'use strict'

shader = require('../models/shader')

module.exports = (app) ->
	app.get '/view/:shaderID', (req, res) ->
		shaderID = req.params.shaderID
		shader.findID shaderID, (error, doc)->
			if doc
				res.render('view', doc.Shader)
			else
				res.status(404).render('404')
