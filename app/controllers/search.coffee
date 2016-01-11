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

	app.get '/search', (req, res, next) ->
		page = parseInt(req.query.page) || 1
		pageItems = 12

		req.query.sort ?= 'view'
		req.query.order ?= 'desc'
		req.query.filter ?= ''

		sort = sortMap[req.query.sort]
		order = orderMap[req.query.order]
		filter = filterMap[req.query.filter]

		skip = (page - 1) * pageItems
		limit = pageItems

		if filter
			Filter.get filter, (error, doc)->
				return next(new Error(error)) if error
				return next(doc) if not doc

				Shader.select {'info.id': {$in: doc.value}}, order + sort, skip, limit, (error, docs)->
					return next(new Error(error)) if error
					return next(docs) if not docs

					res.render('search', {'shaders': docs, 'config': Config.config, 'pages': Math.ceil(doc.value.length / pageItems), 'page': page, 'sort': req.query.sort, 'order': req.query.order, 'filter': req.query.filter})
		else
			Shader.count {}, (error, total)->
				return next(new Error(error)) if error
				return next(total) if not total

				Shader.select {}, order + sort, skip, limit, (error, docs)->
					return next(new Error(error)) if error
					return next(docs) if not docs

					res.render('search', {'shaders': docs, 'config': Config.config, 'pages': Math.ceil(total / pageItems), 'page': page, 'sort': req.query.sort, 'order': req.query.order, 'filter': req.query.filter})
