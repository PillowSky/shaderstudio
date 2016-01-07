'use strict'

assert = require('assert')
mongoose = require('../services/mongoose')

module.exports = (app) ->
	app.post '/import/:collection', (req, res) ->
		mongoose.connection.db.collection req.params.collection, (error, collection)->
			assert.equal(null, error)
			collection.insert req.body, (error)->
				if error
					res.status(403).json(error)
				else
					res.status(200).end()
