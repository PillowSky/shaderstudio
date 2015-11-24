mongo = require('../services/mongo')

module.exports = (app) ->
	app.get '/view/:shaderID', (req, res) ->
		shaderID = req.params.shaderID
		mongo.collection('shaders').findOne {"Shader.info.id": shaderID}, (error, doc)->
			res.render('view', doc.Shader)
