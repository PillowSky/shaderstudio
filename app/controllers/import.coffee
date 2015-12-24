mongoose = require('../services/mongoose')

module.exports = (app) ->
	app.post '/import', (req, res) ->
		mongoose.collection('preset').insert req.body, (error)->
			if error
				res.status(403).json(error)
			else
				res.status(200).end()
