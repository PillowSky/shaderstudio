'use strict'

mongo = require('../services/mongo')

module.exports.findID = (shaderID, callback)->
	mongo.collection('shader').findOne {'Shader.info.id': shaderID}, callback


module.exports.find = (find, skip, limit, callback)->
	mongo.collection('shader').find(find).skip(skip).limit(limit).toArray callback
