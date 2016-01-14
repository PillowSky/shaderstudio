'use strict'

mongoose = require('../services/mongoose')

FilterSchema = new mongoose.Schema({
	key: String
	value: [String]
})

FilterSchema.statics.get = (key, callback)->
	@findOne({'key': key}, callback)

FilterSchema.statics.parse = (shader)->
	for pass in shader.renderpass
		if pass.type == 'sound'
			@findOneAndUpdate({key: 'gpusound'}, {$addToSet: {value: shader.info.id}}).exec()
		for input in pass.inputs
			switch input.ctype
				when 'mic'
					@findOneAndUpdate({key: 'microphone'}, {$addToSet: {value: shader.info.id}}).exec()
				when 'music'
					@findOneAndUpdate({key: 'musicinput'}, {$addToSet: {value: shader.info.id}}).exec()
				when 'webcam'
					@findOneAndUpdate({key: 'webcamera'}, {$addToSet: {value: shader.info.id}}).exec()

module.exports = mongoose.model('Filter', FilterSchema)
