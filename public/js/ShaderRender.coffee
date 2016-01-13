'use strict'

#polyfill
navigator.getUserMedia = navigator.getUserMedia or navigator.webkitGetUserMedia or navigator.mozGetUserMedia or navigator.msGetUserMedia

class ShaderRender
	constructor: (@canvas, @mouse, @keyboard, @vert, @frag, @pass, @host) ->
		@gl = twgl.getWebGLContext(@canvas)
		@gl.getExtension('OES_standard_derivatives')
		@gl.getExtension('EXT_shader_texture_lod')
		@programInfo = null
		@bufferInfo = null
		@textures = new Array(4)
		@textureConfigs = new Array(4)
		@channelResolutions = new Float32Array(12)
		@channelTimes = new Float32Array(4)
		@mousePositions = new Float32Array(4)
		@isStarted = false
		@everStarted = false
		@timestamp = 0
		@laststamp = 0
		@initialize()

	initialize: =>
		@pass.inputs.forEach (input)=>
			switch input.ctype
				when 'texture', 'cubemap'
					texConfig = {}

					if input.ctype == 'texture'
						texConfig.src = @host + input.src
					else
						@frag = @frag.replace("sampler2D #{'iChannel' + input.channel}", "samplerCube #{'iChannel' + input.channel}")
						texConfig.target = @gl.TEXTURE_CUBE_MAP
						texConfig.src = input.src.map (src)=>
							@host + src

					@samplerToConfig(input.sampler, texConfig)
					@textureConfigs[input.channel] = texConfig

				when 'music', 'mic'
					context = new AudioContext()
					source = null
					analyser = context.createAnalyser()
					gain = context.createGain()

					#NOTE: Only low frequency component(lower half) is taken, the next line should be commented
					#analyser.fftSize = 1024
					analyser.connect(gain)
					gain.connect(context.destination)

					if input.ctype == 'music'
						audio = new Audio()
						audio.src = @host + input.src
						audio.autoplay = true
						audio.loop = true
						source = context.createMediaElementSource(audio)
						source.connect(analyser)
					else
						navigator.getUserMedia {audio: true}, (stream)->
							#URL.createObjectURL(stream) failed due to Chrome implementation limits
							source = context.createMediaStreamSource(stream)
							source.connect(analyser)
						, (error)->
							console.error(error) if error

					buffer = new ArrayBuffer(1024)
					freq = new Uint8Array(buffer, 0, 512)
					wave = new Uint8Array(buffer, 512, 512)

					texConfig =
						format: @gl.LUMINANCE
						src: new Uint8Array(buffer)
						width: 512
						height: 2
						audio: context
						update: =>
							analyser.getByteFrequencyData(freq)
							analyser.getByteTimeDomainData(wave)
							@textures[input.channel] = twgl.createTexture(@gl, texConfig)
							#double check here due to Chrome implementation limits
							@channelTimes[input.channel] = source?.mediaElement?.currentTime

					@samplerToConfig(input.sampler, texConfig)
					@textureConfigs[input.channel] = texConfig

				when 'video', 'webcam'
					video = document.createElement('video')

					if input.ctype == 'video'
						video.src = @host + input.src
						video.loop = true
					else
						navigator.getUserMedia {video: true}, (stream)->
							video.src = URL.createObjectURL(stream)
						, (error)->
							console.error(error) if error

					texConfig =
						src: video
						video: video
						update: =>
							@textures[input.channel] = twgl.createTexture(@gl, texConfig)
							@channelTimes[input.channel] = video.currentTime

					@samplerToConfig(input.sampler, texConfig)
					video.addEventListener 'canplay', =>
						video.width = video.videoWidth
						video.height = video.videoHeight
						video.play() if @isStarted
						@textures[input.channel] = twgl.createTexture(@gl, texConfig)
						@textureConfigs[input.channel] = texConfig
						@channelResolutions[input.channel * 3] = @videoWidth
						@channelResolutions[input.channel * 3 + 1] = @videoHeight

				when 'keyboard'
					buffer = new Uint8Array(256 * 2)
					texConfig =
						format: @gl.LUMINANCE
						src: buffer
						width: 256
						height: 2

					@samplerToConfig(input.sampler, texConfig)
					@textureConfigs[input.channel] = texConfig

					@keyboard.on 'keydown', (event)=>
						buffer[event.which] = 255
						buffer[event.which + 256] = 255 - buffer[event.which + 256]
						@textures[input.channel] = twgl.createTexture(@gl, texConfig)
					@keyboard.on 'keyup', (event)=>
						buffer[event.which] = 0
						@textures[input.channel] = twgl.createTexture(@gl, texConfig)
				else
					console.warn("Input ignored: #{input.ctype}", input)

		@textures = twgl.createTextures @gl, @textureConfigs, (error, texs, imgs)=>
			if error
				console.error(error)
			else
				@pass.inputs.forEach (input)=>
					switch input.ctype
						when 'texture', 'cubemap'
							@channelResolutions[input.channel * 3] = imgs[input.channel].width
							@channelResolutions[input.channel * 3 + 1] = imgs[input.channel].height
						when 'music', 'mic'
							@channelResolutions[input.channel * 3] = 512
							@channelResolutions[input.channel * 3 + 1] = 2
						when 'video', 'webcam'
							null
						when 'keyboard'
							@channelResolutions[input.channel * 3] = 256
							@channelResolutions[input.channel * 3 + 1] = 2
						else
							console.warn("Input ignored again: #{input.ctype}", input)

		@programInfo = twgl.createProgramInfo(@gl, [@vert, @frag + @pass.code])
		@bufferInfo = twgl.createBufferInfoFromArrays(@gl, {
			position: {
				numComponents: 2,
				data: new Float32Array([
					1.0, 1.0,
					-1.0, 1.0,
					1.0, -1.0,
					-1.0, -1.0
				])
			}
		})

		@gl.useProgram(@programInfo.program)
		twgl.setBuffersAndAttributes(@gl, @programInfo, @bufferInfo)

	samplerToConfig: (sampler, config)=>
		switch sampler.filter
			when 'nearest'
				config.filter = @gl.NEAREST
			when 'linear'
				config.filter = @gl.LINEAR
			when 'mipmap'
				config.filter = @gl.LINEAR_MIPMAP_NEAREST
			else
				console.warn("Unexpected filter: #{sampler.filter}", sampler)

		switch sampler.wrap
			when 'clamp'
				config.wrap = @gl.CLAMP_TO_EDGE
			when 'repeat'
				config.wrap = @gl.REPEAT
			else
				console.warn("Unexpected wrap: #{sampler.wrap}", sampler)

		switch sampler.vflip
			when 'true'
				config.flipY = true
			when 'false'
				config.flipY = false
			else
				console.warn("Unexpected vflip: #{sampler.vflip}", sampler)

	render: (time)=>
		console.warning('render called from ShaderRender', time)

	start: =>
		console.warning('start called from ShaderRender')

	stop: =>
		console.warning('stop called from ShaderRender')

window.ShaderRender = ShaderRender
