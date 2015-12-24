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
mongoUrl = 'mongodb://localhost:27017/shaderstudio'

MongoClient.connect mongoUrl, (error, db)->
	assert.equal(null, error)
	console.log("Connected to #{mongoUrl}")
	tasks = db.collection('tasks')

	request shaderListUrl, (error, response, body)->
		json = JSON.parse(body)
		console.log("#{json.Shaders} Shaders to fetch")

		taskList = json.Results.map (id)->
			return {'shaderID': id}

		tasks.insertMany taskList, (error, result)->
			assert.equal(null, error)
			console.log(error)
			db.close()
