'use strict'

class SoundRender extends ShaderRender
	initialize: =>
		super()
		@fbo = twgl.createFramebufferInfo(@gl, [
			{format: @gl.RGBA, type: @gl.UNSIGNED_BYTE, min: @gl.LINEAR, wrap: @gl.CLAMP_TO_EDGE}
		])
		twgl.bindFramebufferInfo(@gl, @fbo)
		@audioContext = new AudioContext()
		@sampleRate = 44100
		@frameDimension = 1024

	render: (time)=>
		# update inputs
		for texConfig in @textureConfigs
			texConfig?.update?()

		# update uniforms
		d = new Date()
		uniforms =
			iResolution: [@gl.canvas.width, @gl.canvas.height, 0]
			iGlobalTime: if time then time/1000 else @audioContext.currentTime
			iChannelTime: @channelTimes
			iChannelResolution: @channelResolutions
			iMouse: @mousePositions
			iDate: [d.getFullYear(), d.getMonth(), d.getDate(), d.getHours()*3600 + d.getMinutes()*60 + d.getSeconds() + d.getMilliseconds()/1000]
			iSampleRate: @sampleRate
			iFrameDimension: @frameDimension

		# update texture
		for channel, texture of @textures
			uniforms['iChannel' + channel] = texture

		twgl.setUniforms(@programInfo, uniforms)
		twgl.drawBufferInfo(@gl, @gl.TRIANGLE_STRIP, @bufferInfo)

		# pipe to audio
		playSamples = @frameDimension ** 2
		playTime = playSamples / @sampleRate

		audioBuffer = @audioContext.createBuffer(2, playSamples, @sampleRate)
		bufferL = audioBuffer.getChannelData(0)
		bufferR = audioBuffer.getChannelData(1)

		data = new Uint8Array(playSamples * 4)
		@gl.readPixels(0, 0, @frameDimension, @frameDimension, @gl.RGBA, @gl.UNSIGNED_BYTE, data)

		for i in [0...playSamples]
			bufferL[i] = -1.0 + 2.0*(data[4*i] + 256.0*data[4*i+1])/65535.0
			bufferR[i] = -1.0 + 2.0*(data[4*i+2] + 256.0*data[4*i+3])/65535.0

		playNode = @audioContext.createBufferSource()
		playNode.buffer = audioBuffer
		playNode.connect(@audioContext.destination)
		playNode.start(0)

		# padding 1000ms for latency
		setTimeout(@render, (playTime - 1) * 1000) if @isStarted

	start: =>
		if not @isStarted
			@isStarted = true
			@gl.useProgram(@programInfo.program)
			@gl.viewport(0, 0, @gl.canvas.width, @gl.canvas.height)
			twgl.setBuffersAndAttributes(@gl, @programInfo, @bufferInfo)
			@render(0)

	stop: =>
		@isStarted = false

window.SoundRender = SoundRender
