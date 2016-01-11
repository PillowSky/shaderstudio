'use strict'

$ ->
	$('.ui.search').search()

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

	shiftShader = (offset)->
		stopShader()
		window.shaderIndex += offset
		window.shaderIndex = window.shaderIds.length - 1 if window.shaderIndex < 0
		window.shaderIndex = 0 if window.shaderIndex >= window.shaderIds.length

		$.get "/api/shaders/#{window.shaderIds[window.shaderIndex]}", (data)->
			#wait for previous shader's render call finished
			requestAnimationFrame ->
				window.shader = data
				data.info.index = window.shaderIndex
				$('p.info').html(tmpl('tmpl-info', data.info))
				destroyShader()
				createShader()
				startShader()

	$('#left').click ->
		shiftShader(-1)

	$('#right').click ->
		shiftShader(1)

	$('#control').click ->
		if imageRender?.isStarted or soundRender?.isStarted
			stopShader()
			$('#control').children('i.icon').removeClass('pause').addClass('play')
		else
			startShader()
			$('#control').children('i.icon').removeClass('play').addClass('pause')

	setTimeout ->
		shiftShader(Math.floor(Math.random() * window.shaderIds.length))
	, 0

	$('#goto input').attr('max', window.shaderIds.length - 1).attr('placeholder', "#{window.shaderIds.length} shaders in total")
	$('#goto button').click ->
		index = $('#goto > input').val()
		shiftShader(index - window.shaderIndex) if 0 <= index < window.shaderIds.length
