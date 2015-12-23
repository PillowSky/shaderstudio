fs = require 'fs'
path = require 'path'
request = require 'request'
cheerio = require 'cheerio'

siteUrl = 'http://soundflush.com/'

json = JSON.parse(fs.readFileSync('srcs.json'))

json.forEach (track)->
	options =
		url: siteUrl
		method: 'POST'
		form:
			track_url: track
			btn_download: 'Download'

	request options, (error, response, body)->
		$ = cheerio.load(body)
		link = $('.button--save').attr('href')
		save = $('.button--save').attr('download')
		request(link).pipe(fs.createWriteStream(save))
		console.log(track)
