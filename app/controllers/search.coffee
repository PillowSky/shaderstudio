'use strict'

Shader = require('../models/shader')

module.exports = (app) ->
	app.get '/search', (req, res) ->
		page = req.query.page || 1
		pageItems = 12
		Shader.select {}, (page - 1) * pageItems, pageItems, (error, docs)->
			if docs
				res.render('search', {'shaders': docs})
			else
				res.status(404).render('404')
