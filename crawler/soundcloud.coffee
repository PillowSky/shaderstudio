fs = require 'fs'
path = require 'path'
request = require 'request'
cheerio = require 'cheerio'
MongoClient = require('mongodb').MongoClient
child_process = require('child_process')

siteUrl = 'http://soundflush.com/'
soundcloudUrl = 'https://soundcloud.com/'
mongoUrl = 'mongodb://localhost:27017/shaderstudio'

MongoClient.connect mongoUrl, (error, db)->
	db.collection('assets').find().forEach (document)->
		if document.path.indexOf('soundcloud') != -1
			track_url = document.path.replace('.mp3', '').replace('soundcloud/', soundcloudUrl)
			options =
				url: siteUrl
				method: 'POST'
				form:
					track_url: track_url
					btn_download: 'Download'

			request options, (error, response, body)->
				$ = cheerio.load(body)
				link = $('.button--save').attr('href')
				save = $('.button--save').attr('download')
				folder = document.path.split('/')[1]
				if not fs.existsSync(folder)
					fs.mkdirSync(folder)
				console.log(document.path, track_url, link, folder, save)
				try
					child_process.execSync("wget \"#{link}\" -nc -O \"#{folder}/#{save}\"", {stdio: [0, 1, 2]})
				catch e
