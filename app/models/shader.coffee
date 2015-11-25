'use strict'

mongo = require('../services/mongo')
async = require('async')

module.exports.query = (shaderID, callback)->
	mongo.collection('shader').findOne {'Shader.info.id': shaderID}, (error, doc)->
		if error
			callback(error, doc)
		else
			if doc.Shader.renderpass[0].inputs.length
				tasks = doc.Shader.renderpass[0].inputs.map (input)->
					return (_callback)->
						mongo.collection('preset').findOne {'src': input.src}, (_error, _doc)->
							input.info = _doc
							_callback(_error)
				async.parallel tasks, (error)->
					callback(error, doc)
			else
				callback(error, doc)
