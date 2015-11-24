'use strict'

path     = require 'path'
rootPath = path.normalize __dirname + '/..'
env      = process.env.NODE_ENV || 'development'

config =
	development:
		root: rootPath
		app:
			name: 'stenography'
		port: 18080

	test:
		root: rootPath
		app:
			name: 'stenography'
		port: 18080

	production:
		root: rootPath
		app:
			name: 'stenography'
		port: 18080

module.exports = config[env]
