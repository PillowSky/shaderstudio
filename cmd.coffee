'use strict'

pHash = require './pHash'

if process.argv.length < 6
	console.log('Usage: coffee cmd.coffee <scale> <length> <target image> <case images...>')
	console.log('Example: coffee cmd.coffee 64 64 target.png case/*')
	process.exit(-1)
else
	scale = parseInt(process.argv[2])
	length = parseInt(process.argv[3])
	targetPath = process.argv[4]
	targetHash = null

	console.log("Target Image: #{targetPath}")
	console.log("Similarities:")

	pHash.pHash targetPath, scale, length, (error, hash)->
		if error
			console.error(error)
		else
			targetHash = hash
			process.argv.slice(5).forEach (path)->
				pHash.pHash path, scale, length, (error, hash)->
					if error
						console.error(error)
					else
						console.log("#{path}: #{pHash.similarity(targetHash, hash)}")
