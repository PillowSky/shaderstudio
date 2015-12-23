'use strict'

shader = require('../models/shader')

module.exports = (app) ->
	app.get '/search', (req, res) ->
		page = req.query.page || 1
		pageItems = 12
		shader.find {}, (page - 1) * pageItems, pageItems, (error, docs)->
			if docs
				shaders = docs.map (doc)->
					doc.Shader
				res.render('search', {'shaders': shaders})
			else
				res.status(404).render('404')
