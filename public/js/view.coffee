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

	shiftShader = (offset)->
		stopShader()
		homeShaders = window.config['home.shaders']
		newIndex = homeShaders.indexOf(window.shader.info.id) + offset
		newIndex = homeShaders.length - 1 if newIndex < 0
		newIndex = 0 if newIndex >= homeShaders.length

		$.get "/api/shaders/#{homeShaders[newIndex]}", (data)->
			#wait for previous shader's render call finished
			requestAnimationFrame ->
				window.shader = data
				destroyShader()
				createShader()
				startShader()

	setTimeout ->
		createShader()
		startShader()
	, 0

	editor = ace.edit("editor");
	editor.setTheme("ace/theme/twilight");
	editor.session.setMode("ace/mode/glsl");

