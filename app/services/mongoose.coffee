'use strict'

mongoose = require('mongoose')

if process.env.BAE_ENV_APPID
	db_username = process.env.BAE_USER_AK
	db_password = process.env.BAE_USER_SK
	db_host = process.env.BAE_MONGODB_HOST
	db_port = process.env.BAE_MONGODB_PORT
	db_name = process.env.BAE_MONGODB_NAME
	mongoose.connect("mongodb://#{db_username}:#{db_password}@#{db_host}:#{db_port}/#{db_name}")
else
	db_host = 'localhost'
	db_name = 'shaderstudio'
	mongoose.connect("mongodb://#{db_host}/#{db_name}")

module.exports = mongoose
