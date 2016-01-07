'use strict'

request = require('request')
assert = require('assert')
async = require('async')
mongoose = require('../app/services/mongoose')

syncUrl = 'http://shaderstudio.duapp.com/import/'
collectionName = process.argv[2]
assert.notEqual(collectionName, null)

setTimeout ->
	mongoose.connection.db.collection collectionName, (error, collection)->
		assert.equal(null, error)

		collection.find().toArray (error, docs)->
			assert.equal(null, error)

			tasks = docs.map (doc, index)->
				return (callback)->
					option =
						'url': syncUrl + collectionName
						'method': 'POST'
						'body': doc
						'json': true

					request option, (error, response, body)->
						callback(error, response)
						console.log(body) if body

			async.parallelLimit tasks, 10, (error, resutls)->
				console.log('All done')
, 1000
