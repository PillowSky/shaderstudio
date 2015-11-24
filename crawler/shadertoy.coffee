'use strict'

request = require('request')
MongoClient = require('mongodb').MongoClient
assert = require('assert')
async = require('async')
fs = require('fs')

appkey = 'ftHtWH'
shaderListUrl = 'https://www.shadertoy.com/api/v1/shaders?key=' + appkey
shaderDetailUrl = 'https://www.shadertoy.com/api/v1/shaders/shaderID?key=' + appkey
assetUrl = 'https://www.shadertoy.com'
mongoUrl = 'mongodb://localhost:27017/shader'

MongoClient.connect mongoUrl, (error, db)->
	assert.equal(null, error);
	console.log("Connected to #{mongoUrl}");
	shaders = db.collection('shaders')

	request shaderListUrl, (error, response, body)->
		json = JSON.parse(body)
		tasks = json.Results.map (shaderID)->
			return (callback) ->
				request shaderDetailUrl.replace('shaderID', shaderID), (error, response, body)->
					try
						json = JSON.parse(body)
						shaders.insert(json, callback)
						console.log(shaderID)

						if json.Shader.renderpass[0].inputs.length
							json.Shader.renderpass[0].inputs.forEach (preset)->
								if preset.src[0] == '/'
									savePath = preset.src.slice(1)
									fs.exists savePath, (exists)->
										if not exists
											request(assetUrl + preset.src).pipe(fs.createWriteStream(savePath))
											console.log(savePath)
								else
									console.log preset.src, shaderID
					catch e
						console.error(e, shaderID, body)
		async.series tasks, (error, resutls)->
			console.log('All done')
			db.close()
