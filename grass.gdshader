shader_type spatial;

uniform vec4 albedo : source_color = vec4(0.0);
uniform sampler2D noise : hint_default_black, filter_nearest;

varying vec3 _vertex;

void fragment() {
	_vertex = VERTEX;
	
	ALBEDO = albedo.rgb;
}

void light() {
	float light = dot(NORMAL, LIGHT);
	
	vec3 variation = vec3(_vertex.x + (texture(noise, vec2(_vertex.x * 3.0, _vertex.y)).r/35.0), _vertex.y, _vertex.z + (texture(noise, vec2(_vertex.y, _vertex.z * 1.0)).r/85.0));
	
	if (LIGHT_IS_DIRECTIONAL) {
		float shadow = 1.0 - sample_directional_shadow(LIGHT_INDEX, variation);
		
		DIFFUSE_LIGHT += light - shadow;
	} else if (LIGHT_IS_OMNI) {
		float shadow = sample_omni_shadow(LIGHT_INDEX, variation, NORMAL);
		
		DIFFUSE_LIGHT += light * shadow * AMPLITUDE;
	} else {
		DIFFUSE_LIGHT += light * ATTENUATION;
	}
}