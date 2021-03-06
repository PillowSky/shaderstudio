'use strict'

$ ->
	Array.prototype.forEach.call document.querySelectorAll('canvas.canvas'), (canvas, index)->
		imageRender = null
		soundRender = null

		createShader = ->
			window.shaders[index].renderpass.forEach (pass)->
				switch pass.type
					when 'image'
						if not imageRender
							imageRender = new ImageRender(
								canvas
								$(canvas),
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

		$(canvas).mouseenter ->
			startShader()

		$(canvas).mouseleave ->
			stopShader()

		# trick to load shader one by one
		setTimeout ->
			createShader()
			startShader()
			stopShader()
			$(canvas).next().remove()
		, index * 100

	$('.searchbutton').click ->
		keyword = $(this).prev().val()
		location.href = "/search?keyword=#{keyword}"
