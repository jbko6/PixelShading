shader_type spatial;

uniform vec4 albedo : source_color = vec4(0.0);
uniform sampler2D noise : hint_default_black;

varying vec3 _vertex;

void fragment() {
	_vertex = VERTEX;
	
	ALBEDO = albedo.rgb;
}

void light() {
	float light = dot(NORMAL, LIGHT);
	
	if (LIGHT_IS_DIRECTIONAL) {
		vec3 variation = vec3(_vertex.x + (texture(noise, vec2(_vertex.x, TIME)).r/10.0), _vertex.y, _vertex.z + (texture(noise, vec2(TIME, _vertex.z)).r/10.0));
		
		float shadow = get_directional_shadow(LIGHT_INDEX, variation, 0.5);
		
		DIFFUSE_LIGHT += vec3(shadow) - light;
	}
}