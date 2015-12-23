'use strict'

shader = require('../models/shader')

module.exports = (app) ->
	app.get '/', (req, res) ->
		shader.find {}, 0, 4, (error, docs)->
			if docs
				shaders = docs.map (doc)->
					doc.Shader
				res.render('index', {'shaders': shaders})
			else
				res.status(404).render('404')

