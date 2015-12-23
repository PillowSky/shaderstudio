'use strict'

request = require('request')
MongoClient = require('mongodb').MongoClient
assert = require('assert')
async = require('async')
fs = require('fs')

mongoUrl = 'mongodb://localhost:27017/shaderstudio'

MongoClient.connect mongoUrl, (error, db)->
	assert.equal(null, error);
	console.log("Connected to #{mongoUrl}");
	shaders = db.collection('shader')
	presets = db.collection('preset')

	shaders.find().toArray (error, docs)->
		tasks = docs.map (doc)->
			return (callback)->
				if doc.Shader.renderpass[0].inputs.length
					_tasks = doc.Shader.renderpass[0].inputs.map (input, index)->
						return (_callback)->
							presets.findOne {'src': input.src}, (_error, _doc)->
								assert.equal(null, error)
								if _doc
									console.log(doc.Shader.info.id)
									doc.Shader.renderpass[0].inputs[index].info =
										'width': _doc.width
										'height': _doc.height
									shaders.updateOne {"Shader.info.id": doc.Shader.info.id}, doc, _callback
								else
									_callback()
					async.series _tasks, callback
				else
					callback()
		async.parallel tasks, (error)->
			assert.equal(null, error)
			console.log('All done')
			db.close()
