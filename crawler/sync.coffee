'use strict'

request = require('request')
MongoClient = require('mongodb').MongoClient
assert = require('assert')
async = require('async')

mongoUrl = 'mongodb://localhost:27017/shaderstudio'
syncUrl = 'http://shaderstudio.duapp.com/import'

MongoClient.connect mongoUrl, (error, db)->
	assert.equal(null, error)
	console.log("Connected to #{mongoUrl}")

	db.collection('preset').find().toArray (error, docs)->
		assert.equal(null, error)
		tasks = docs.map (doc, index)->
			return (callback)->
				option =
					'url': syncUrl
					'method': 'POST'
					'body': doc
					'json': true

				request option, (error, response, body)->
					callback(error, response)
					console.log(body) if body
		async.parallel tasks, (error, resutls)->
			console.log('All done')
			db.close()
