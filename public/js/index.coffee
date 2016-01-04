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


	imageRender = new ImageRender('#canvasImage', 'image', $('#canvasImage'), $('body'), $('#glslPass').text(), $('#glslImage').text(), window.shader, window.config)

	render = (time)->
		imageRender.render(time)
		requestAnimationFrame(render)

	requestAnimationFrame(render)
