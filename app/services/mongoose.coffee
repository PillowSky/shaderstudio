'use strict'

mongoose = require('mongoose')

if process.env.BAE_ENV_APPID
	db_username = '91ffd5e7cbe44f6fb8d6bdde574fc06e'
	db_password = 'd977a9f49d6f4a78a7dfde99896efaea'
	db_host = 'mongo.duapp.com'
	db_port = '8908'
	db_name = 'juttKHwHVOlviRkTYYUU'
	mongoose.connect("mongodb://#{db_username}:#{db_password}@#{db_host}:#{db_port}/#{db_name}")

else
	db_host = 'localhost'
	db_name = 'shaderstudio'
	mongoose.connect("mongodb://#{db_host}/#{db_name}")

module.exports = mongoose
