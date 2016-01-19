'use strict'

assert = require('assert')
Shader = require('../app/models/shader')
Asset = require('../app/models/asset')
Filter = require('../app/models/filter')

Shader.find {}, (error, docs)->
	assert.equal(null, error)

	map = {}
	docs.forEach (doc)->
		Filter.parse(doc)

	console.log('Done', map)
