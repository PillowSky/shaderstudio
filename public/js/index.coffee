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
				if imageRender
					console.log("Pass ignored: #{pass.type}", pass)
				else
					imageRender = new ImageRender(
						document.querySelector('#canvasImage'),
						$('#canvasImage'),
						$('body'),
						$('#glslVert').text(),
						$('#glslImage').text(),
						pass,
						window.config['asset.host']
					)
					imageRender.start()
			when 'sound'
				if soundRender
					console.log("Pass ignored: #{pass.type}", pass)
				else
					soundRender = new SoundRender(
						document.querySelector('#canvasSound'),
						$('#canvasImage'),
						$('body'),
						$('#glslVert').text(),
						$('#glslSound').text(),
						pass,
						window.config['asset.host']
					)
					soundRender.start()
			else
				console.log("Pass ignored: #{pass.type}", pass)
