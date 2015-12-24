'use strict'

request = require('request')
MongoClient = require('mongodb').MongoClient
assert = require('assert')
async = require('async')
fs = require('fs')

appkey = 'ftHtWH'
shaderListUrl = 'https://www.shadertoy.com/api/v1/shaders?key=' + appkey
shaderDetailUrl = 'https://www.shadertoy.com/api/v1/shaders/shaderID?key=' + appkey
assetUrl = 'https://www.shadertoy.com/'
mongoUrl = 'mongodb://localhost:27017/shaderstudio'

MongoClient.connect mongoUrl, (error, db)->
	assert.equal(null, error);
	console.log("Connected to #{mongoUrl}");
	shaders = db.collection('shader2')
	tasks = db.collection('tasks')
	soundcloud = db.collection('soundcloud')

	worker = (document)->
		shaderID = document.shaderID
		request shaderDetailUrl.replace('shaderID', shaderID), (error, response, body)->
			try
				json = JSON.parse(body).Shader
				json.renderpass.forEach (pass)->
					pass.inputs.forEach (preset)->
						if preset.src[0] == '/'
							preset.src = preset.src.slice(1)
							if not fs.existsSync(preset.src)
								request(assetUrl + preset.src).pipe(fs.createWriteStream(preset.src))
								console.log("Done Asset: #{preset.src}")
						else
							console.log("Queue soundcloud: #{preset.src} => #{shaderID}")
							soundcloud.insert({src: preset.src, shaderID: shaderID})
							preset.src = 'soundcloud/' + new RegExp("soundcloud.com/(.+)").exec(preset.src)[1] + '.mp3'

				shaders.update({"info.id": json.info.id}, json, {upsert: true})
				tasks.remove({shaderID: shaderID})
				console.log("Done: #{shaderID}")

			catch e
				console.error(e, shaderID)
				worker(document)

	tasks.find().forEach(worker)
