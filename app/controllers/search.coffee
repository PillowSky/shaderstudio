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
		req.query.keyword ?= ''
		req.query.page ?= 1
		req.query.sort ?= 'view'
		req.query.order ?= 'desc'
		req.query.filter ?= ''

		keyword = req.query.keyword
		page = parseInt(req.query.page)
		sort = sortMap[req.query.sort]
		order = orderMap[req.query.order]
		filter = filterMap[req.query.filter]

		pageItems = 12
		skip = (page - 1) * pageItems
		limit = pageItems

		if filter
			Filter.get filter, (error, doc)->
				return next(new Error(error)) if error
				return next(doc) if not doc

				Shader.count {'info.id': {$in: doc.value}, 'info.name': {$regex: keyword, $options: 'i'}}, (error, total)->
					return next(new Error(error)) if error
					return next(total) if not total

					Shader.query {'info.id': {$in: doc.value}, 'info.name': {$regex: keyword, $options: 'i'}}, order + sort, skip, limit, (error, docs)->
						return next(new Error(error)) if error
						return next(docs) if not docs

						res.render('search', {'shaders': docs, 'config': Config.config, 'pages': Math.ceil(total / pageItems), 'keyword': keyword, 'page': page, 'sort': req.query.sort, 'order': req.query.order, 'filter': req.query.filter})
		else
			Shader.count {'info.name': {$regex: keyword, $options: 'i'}}, (error, total)->
				return next(new Error(error)) if error
				return next(total) if not total

				Shader.query {'info.name': {$regex: keyword, $options: 'i'}}, order + sort, skip, limit, (error, docs)->
					return next(new Error(error)) if error
					return next(docs) if not docs

					res.render('search', {'shaders': docs, 'config': Config.config, 'pages': Math.ceil(total / pageItems), 'keyword': keyword, 'page': page, 'sort': req.query.sort, 'order': req.query.order, 'filter': req.query.filter})
