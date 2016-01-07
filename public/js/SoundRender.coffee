'use strict'

class SoundRender extends ShaderRender
	initialize: =>
		super()
		@fbo = twgl.createFramebufferInfo(@gl, [
			{format: @gl.RGBA, type: @gl.UNSIGNED_BYTE, min: @gl.LINEAR, wrap: @gl.CLAMP_TO_EDGE}
		])
		twgl.bindFramebufferInfo(@gl, @fbo)
		@audioContext = new AudioContext()
		@sampleRate = @audioContext.sampleRate
		@frameDimension = 1024

	render: (time = performance.now())=>
		# update inputs
		for texConfig in @textureConfigs
			texConfig?.update?()

		# update uniforms
		d = new Date()
		uniforms =
			iResolution: [@gl.canvas.width, @gl.canvas.height, 0]
			iGlobalTime: (time - @timestamp) / 1000
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
		playNode.start()

		# hack here due to chromium bug#121654
		console.log(playNode)
		playNode.onended = =>
			@render()

	start: =>
		if not @isStarted
			if @everStarted
				for texConfig in @textureConfigs
					texConfig?.audio?.resume?()
					texConfig?.video?.play?()
				@audioContext.resume()
			else
				@render()
			@timestamp = performance.now() - @laststamp
			@isStarted = @everStarted = true

	stop: =>
		if @isStarted
			for texConfig in @textureConfigs
				texConfig?.audio?.suspend?()
				texConfig?.video?.pause?()
			@audioContext.suspend()
			@laststamp = performance.now() - @timestamp
			@isStarted = false

window.SoundRender = SoundRender
