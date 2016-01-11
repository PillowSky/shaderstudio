'use strict'

Shader = require('../models/shader')
Config = require('../models/config')
Filter = require('../models/filter')

module.exports = (app) ->
	sortMap =
		'view': 'info.viewed'
		'like': 'info.likes'
		'date': 'info.date'

	orderMap =
		'desc': '-'
		'asc': ''

	filterMap =
		'gpusound': 'gpusound'
		'microphone': 'microphone'
		'musicinput': 'musicinput'
		'webcamera': 'webcamera'

	app.get '/browse', (req, res, next) ->
		req.query.sort ?= 'view'
		req.query.order ?= 'desc'
		req.query.filter ?= ''

		sort = sortMap[req.query.sort]
		order = orderMap[req.query.order]
		filter = filterMap[req.query.filter]

		if filter
			Filter.get filter, (error, doc)->
				return next(new Error(error)) if error
				return next(doc) if not doc

				Shader.selectId {'info.id': {$in: doc.value}}, order + sort, (error, docs)->
					return next(new Error(error)) if error
					return next(docs) if not docs

					res.render('browse', {'shaderIds': docs, 'config': Config.config, 'sort': req.query.sort, 'order': req.query.order, 'filter': req.query.filter})
		else
			Shader.count {}, (error, total)->
				return next(new Error(error)) if error
				return next(total) if not total

				Shader.selectId {}, order + sort, (error, docs)->
					return next(new Error(error)) if error
					return next(docs) if not docs

					res.render('browse', {'shaderIds': docs, 'config': Config.config, 'sort': req.query.sort, 'order': req.query.order, 'filter': req.query.filter})
