'use strict'

request = require('request')
MongoClient = require('mongodb').MongoClient
assert = require('assert')
async = require('async')
fs = require('fs')
path = require('path')
jimp = require('jimp')

presetDir = '../public/presets'

mongoUrl = 'mongodb://localhost:27017/shaderstudio'

MongoClient.connect mongoUrl, (error, db)->
	assert.equal(null, error);
	console.log("Connected to #{mongoUrl}")

	preset = db.collection('preset')
	fs.readdir presetDir, (error, files)->
		tasks = files.map (file)->
			return (callback)->
				filePath = path.join(presetDir, file)
				if path.extname(filePath) in ['.jpg', '.png']
					jimp.read filePath, (error, image)->
						json =
							'src': '/presets/' + file
							'width': image.bitmap.width
							'height': image.bitmap.height
						preset.insert(json, callback)
						console.log(json)
				else
					callback()
		async.parallel tasks, (error, resutls)->
			console.log('All done')
			db.close()
