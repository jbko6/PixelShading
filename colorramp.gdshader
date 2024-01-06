shader_type spatial;
render_mode ambient_light_disabled;

uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;
uniform sampler2D color_ramp : hint_default_white, filter_nearest;

group_uniforms Shader_Parameters.Attenuation;
uniform bool use_directional_attenuation;
uniform bool use_omni_attentuation;
uniform bool use_spot_attentuation;
group_uniforms;

vec3 adjust_rgb(vec3 color){
	return mix(pow((color + vec3(0.055)) * (1.0 / (1.0 + 0.055)),vec3(2.4)),color * (1.0 / 12.92),lessThan(color,vec3(0.04045)));
}

void fragment() {
	vec3 screen = texture(screen_texture, SCREEN_UV).rgb;
	float value = sqrt(screen.r + screen.b + screen.g);
	
	ALBEDO = adjust_rgb(texture(color_ramp, vec2(min(max(value, 0.01f), 0.99f), 0.5)).rgb);
}

void light() {
	if ((LIGHT_IS_DIRECTIONAL && use_directional_attenuation) 
			|| (LIGHT_IS_OMNI && use_omni_attentuation)
			|| (LIGHT_IS_SPOT && use_spot_attentuation)) {
		DIFFUSE_LIGHT += dot(NORMAL, LIGHT) * ATTENUATION;
	} else {
		DIFFUSE_LIGHT += dot(NORMAL, LIGHT) * AMPLITUDE;
	}
}
