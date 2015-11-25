'use strict'

Db = require('mongodb').Db
Server = require('mongodb').Server

if process.env.RUNTIME && process.env.RUNTIME == 'BAE'
	db_name = 'juttKHwHVOlviRkTYYUU'
	db_host = 'mongo.duapp.com'
	db_port = '8908'
	username = '91ffd5e7cbe44f6fb8d6bdde574fc06e'
	password = 'd977a9f49d6f4a78a7dfde99896efaea'
else
	db_name = 'shaderstudio'
	db_host = 'localhost'
	db_port = '27017'

db = new Db(db_name, new Server(db_host, db_port))

if process.env.RUNTIME && process.env.RUNTIME == 'BAE'
	db.open (error, db)->
		db.authenticate username, password, (error, result)->
			if error
				db.close()
				console.error(error, result)
else
	db.open()

module.exports = db
