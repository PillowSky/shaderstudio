'use strict'

mongo = require('../services/mongo')

module.exports.query = (shaderID, callback)->
	mongo.collection('shader').findOne {'Shader.info.id': shaderID}, callback
