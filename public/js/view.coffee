'use strict'

$ ->
	$('.menu .item').tab()
	$('.ui.accordion').accordion()
	hljs.initHighlightingOnLoad()

	class InfoRender
		constructor: (@playback, @framerate)->
			@isStarted = false
			@timestamp = 0
			@laststamp = 0
			@lastsecond = 0

		render: (time = performance.now()) =>
			playsecond = (time - @timestamp) / 1000
			@playback.text("#{playsecond.toFixed(1)}s")
			@framerate.text("#{(6 / (playsecond - @lastsecond)).toFixed(1)} fps")
			@lastsecond = playsecond
			setTimeout(@render, 100) if @isStarted

		start: =>
			if not @isStarted
				@timestamp = performance.now() - @laststamp
				@isStarted = true
				requestAnimationFrame(@render)

		stop: =>
			if @isStarted
				@laststamp = performance.now() - @timestamp
				@isStarted = false

	imageRender = null
	soundRender = null
	infoRender = null
	imageEditor = null
	soundEditor = null

	createShader = ->
		infoRender = new InfoRender($('#playback'), $('#framerate'))
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
		infoRender.start()

	stopShader = ->
		imageRender?.stop()
		soundRender?.stop()
		infoRender.stop()

	destroyShader = ->
		imageRender = null
		soundRender = null

	setTimeout ->
		createShader()
		startShader()
		window.imageRender = imageRender
		window.soundRender = soundRender
		window.infoRender = infoRender

		if imageRender
			$('#imageEditor').text(imageRender.pass.code)
		else
			$('#imageEditor').parent().dimmer('show')

		if soundRender
			$('#soundEditor').text(soundRender.pass.code)
		else
			$('#soundEditor').parent().dimmer('show')

		imageEditor = ace.edit('imageEditor')
		imageEditor.setTheme('ace/theme/twilight')
		imageEditor.session.setMode('ace/mode/glsl')

		soundEditor = ace.edit('soundEditor')
		soundEditor.setTheme('ace/theme/twilight')
		soundEditor.session.setMode('ace/mode/glsl')
	, 0

	$('#backward').click ->
		now = performance.now()
		imageRender?.timestamp = now
		imageRender?.laststamp = now
		soundRender?.timestamp = now
		soundRender?.laststamp = now
		infoRender.timestamp = now
		infoRender.laststamp = now

	$('#switch').click ->
		if infoRender.isStarted
			stopShader()
			$(this).removeClass('pause').addClass('play')
		else
			startShader()
			$(this).removeClass('play').addClass('pause')

	$('#fullscreen').click ->
		canvas = document.querySelector('#canvas')
		if canvas.requestFullscreen
			canvas.requestFullscreen()
		else if canvas.webkitRequestFullscreen
			canvas.webkitRequestFullscreen()
		else if canvas.mozRequestFullScreen
			canvas.mozRequestFullScreen()
		else if canvas.msRequestFullscreen
			canvas.msRequestFullscreen()

	$('#run').click ->
		stopShader()

		#TODO: support add and reduce pass
		window.shader.renderpass.forEach (pass)->
			switch pass.type
				when 'image'
					pass.code = imageEditor.getValue()
				when 'sound'
					pass.code = soundEditor.getValue()
				else
					console.log("Pass ignored: #{pass.type}", pass)

		requestAnimationFrame ->
			destroyShader()
			createShader()
			startShader()

	$.get "/comment/#{window.shader.info.id}", (data)->
		$('#board').html(tmpl('tmpl-comment', data))

	$('form.reply.form').submit (event)->
		comment = $(this).find('textarea').val()
		$.post "/comment/#{window.shader.info.id}", {comment: comment}, (data)->
			$.get "/comment/#{window.shader.info.id}", (data)->
				$('#board').html(tmpl('tmpl-comment', data))
		return false

	$('.searchbutton').click ->
		keyword = $(this).prev().val()
		location.href = "/search?keyword=#{keyword}"
