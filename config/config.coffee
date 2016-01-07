'use strict'

path     = require 'path'
rootPath = path.normalize __dirname + '/..'
env      = process.env.NODE_ENV || 'development'

config =
	development:
		root: rootPath
		port: 18080

	test:
		root: rootPath
		port: 18080

	production:
		root: rootPath
		port: 18080

module.exports = config[env]
