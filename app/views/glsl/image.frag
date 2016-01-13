#extension GL_OES_standard_derivatives : enable
#extension GL_EXT_shader_texture_lod : enable

precision mediump float;

uniform vec3 iResolution;
uniform float iGlobalTime;
uniform float iChannelTime[4];
uniform vec3 iChannelResolution[4];
uniform vec4 iMouse;
uniform sampler2D iChannel0;
uniform sampler2D iChannel1;
uniform sampler2D iChannel2;
uniform sampler2D iChannel3;
uniform vec4 iDate;
uniform float iSampleRate;

void mainImage(out vec4 fragColor, in vec2 fragCoord);

void main() {
	mainImage(gl_FragColor, gl_FragCoord.xy);
}
