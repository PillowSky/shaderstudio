'use strict'

$ ->
	$('.masthead').visibility
		once: false
		onBottomPassed: ->
			$('.fixed.menu').transition 'fade in'
		onBottomPassedReverse: ->
			$('.fixed.menu').transition 'fade out'

	# create sidebar and attach to menu open
	$('.ui.sidebar').sidebar 'attach events', '.toc.item'
	$('.ui.search').search()

	imageRender = null
	soundRender = null

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
					imageRender.start()
				else
					console.log("Pass ignored: #{pass.type}", pass)

			when 'sound'
				if not soundRender
					canvas = document.createElement('canvas')
					canvas.width = 1024
					canvas.height = 1024

					soundRender = new SoundRender(
						canvas,
						null
						null,
						$('#glslVert').text(),
						$('#glslSound').text(),
						pass,
						window.config['asset.host']
					)
					soundRender.start()
				else
					console.log("Pass ignored: #{pass.type}", pass)
			else
				console.log("Pass ignored: #{pass.type}", pass)
