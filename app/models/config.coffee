'use strict'

assert = require('assert')
mongoose = require('../services/mongoose')

ConfigSchema = new mongoose.Schema({
	key: String
	value: mongoose.Schema.Types.Mixed
})

config = {}
ConfigSchema.statics.config = config

ConfigSchema.statics.get = (key, callback)->
	@findOne({'key': key}, callback)

ConfigSchema.statics.set = (key, value, callback)->
	@update({'key': key}, {'key': key, 'value': value}, {upsert: true}, callback)

ConfigSchema.statics.reload = ->
	@find {}, (error, docs)->
		assert.equal(null, error)
		for doc in docs
			config[doc.key] = doc.value

module.exports = mongoose.model('Config', ConfigSchema)
module.exports.reload()
