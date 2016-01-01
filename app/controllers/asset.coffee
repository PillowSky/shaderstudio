'use strict'

request = require('request')

ASSET_HOST = 'http://shaderstudio.bj.bcebos.com/'

module.exports = (app) ->
	app.get '/asset/*', (req, res) ->
		req.pipe(request(ASSET_HOST + req.params[0])).pipe(res)
