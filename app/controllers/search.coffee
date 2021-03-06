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
		fuzzyQuery = [{'info.name': {$regex: keyword, $options: 'i'}}, {'info.tags': {$elemMatch: {$regex: keyword, $options: 'i'}}}]

		if filter
			Filter.get filter, (error, doc)->
				return next(new Error(error)) if error

				Shader.count {'info.id': {$in: doc.value}, $or: fuzzyQuery}, (error, total)->
					return next(new Error(error)) if error

					Shader.query {'info.id': {$in: doc.value}, $or: fuzzyQuery}, order + sort, skip, limit, (error, docs)->
						return next(new Error(error)) if error

						res.render('search', {'shaders': docs, 'config': Config.config, 'user': req.cookies.user, 'pages': Math.ceil(total / pageItems), 'keyword': keyword, 'page': page, 'sort': req.query.sort, 'order': req.query.order, 'filter': req.query.filter})
		else
			Shader.count {$or: fuzzyQuery}, (error, total)->
				return next(new Error(error)) if error

				Shader.query {$or: fuzzyQuery}, order + sort, skip, limit, (error, docs)->
					return next(new Error(error)) if error

					res.render('search', {'shaders': docs, 'config': Config.config, 'user': req.cookies.user, 'pages': Math.ceil(total / pageItems), 'keyword': keyword, 'page': page, 'sort': req.query.sort, 'order': req.query.order, 'filter': req.query.filter})
