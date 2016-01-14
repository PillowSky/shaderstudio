'use strict'

$ ->
	imageRender = null
	soundRender = null

	createShader = ->
		window.shader.renderpass.forEach (pass)->
			switch pass.type
				when 'image'
					if not imageRender
						imageRender = new ImageRender(
							document.querySelector('#canvas')
							$('#canvas'),
							$('body'),
							$('#glslVert').text(),
							$('#glslImage').text(),
							pass,
							window.config['asset.host']
						)
					else
						console.log("Pass ignored: #{pass.type}", pass)

				when 'sound'
					if not soundRender
						soundRender = new SoundRender(
							document.createElement('canvas'),
							null
							null,
							$('#glslVert').text(),
							$('#glslSound').text(),
							pass,
							window.config['asset.host']
						)
					else
						console.log("Pass ignored: #{pass.type}", pass)
				else
					console.log("Pass ignored: #{pass.type}", pass)

	startShader = ->
		imageRender?.start()
		soundRender?.start()

	stopShader = ->
		imageRender?.stop()
		soundRender?.stop()

	destroyShader = ->
		imageRender = null
		soundRender = null

	shiftShader = (index)->
		stopShader()
		window.shaderIndex = index

		$.get "/api/shaders/#{window.shaderIds[window.shaderIndex]}", (data)->
			data.info.index = window.shaderIndex + 1
			data.info.count = window.shaderIds.length
			$('#info').html(tmpl('tmpl-info', data.info))
			$('#page').html(tmpl('tmpl-page', data.info))
			$('#goto input').attr('max', window.shaderIds.length)

			#wait for previous shader's render call finished
			requestAnimationFrame ->
				window.shader = data
				destroyShader()
				createShader()
				startShader()

	$('#left').click ->
		newIndex = window.shaderIndex - 1
		newIndex = window.shaderIds.length - 1 if newIndex < 0
		location.hash = newIndex + 1

	$('#right').click ->
		newIndex = window.shaderIndex + 1
		newIndex = 0 if newIndex >= window.shaderIds.length
		location.hash = newIndex + 1

	$('#control').click ->
		if imageRender?.isStarted or soundRender?.isStarted
			stopShader()
			$('#control').children('i.icon').removeClass('pause').addClass('play')
		else
			startShader()
			$('#control').children('i.icon').removeClass('play').addClass('pause')

	$('#goto').submit (event)->
		location.hash = $('#goto input').val()
		return false

	$('.searchbutton').click ->
		keyword = $(this).prev().val()
		location.href = "/search?keyword=#{keyword}"

	# mini router
	$(window).on 'load hashchange', ->
		index = parseInt(location.hash[1..]) - 1
		if 0 <= index < window.shaderIds.length
			shiftShader(index)
		else
			location.hash = Math.floor(Math.random() * window.shaderIds.length) + 1
