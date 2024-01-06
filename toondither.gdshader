shader_type spatial;
render_mode ambient_light_disabled;

group_uniforms albedo;
	uniform vec4 albedo : source_color = vec4(1.0f);
	uniform sampler2D albedo_texture : hint_default_white;
group_uniforms;

group_uniforms attenuation;
	uniform bool use_attenuation = true;
group_uniforms;

group_uniforms light;
	uniform int cuts : hint_range(1, 8) = 3;
	uniform float wrap : hint_range(-2.0f, 2.0f) = 0.0f;
	uniform float steepness : hint_range(1.0f, 8.0f) = 1.0f;
	uniform bool clamp_diffuse_to_max = false;
group_uniforms;

group_uniforms ramp;
	uniform bool use_ramp = false;
	uniform sampler2D ramp : hint_default_transparent;
group_uniforms;

group_uniforms dither;
	uniform bool use_dither = false;
	uniform sampler2D dither_texture : hint_default_transparent;
	uniform int dither_size = 1;
group_uniforms dither;

group_uniforms specular;
	uniform bool use_specular = true;
	uniform float specular_strength : hint_range(0.0f, 1.0f) = 1.0f;
	uniform float specular_shininess : hint_range(0.0f, 32.0f) = 16.0f;
	uniform sampler2D specular_map : hint_default_transparent;
group_uniforms;

varying vec2 viewport_size;

float split_specular(float specular) {
	return step(0.5f, specular);
}

vec3 adjust_rgb(vec3 color){
	return mix(pow((color + vec3(0.055)) * (1.0 / (1.0 + 0.055)),vec3(2.4)),color * (1.0 / 12.92),lessThan(color,vec3(0.04045)));
}

void fragment() {
	viewport_size = VIEWPORT_SIZE;
	ALBEDO = albedo.rgb * texture(albedo_texture, UV).rgb;
}

void light() {
	float attenuation = 1.0f;
	if (use_attenuation) {
		attenuation = ATTENUATION;
	}
	
	// Diffuse lighting.
	float NdotL = dot(NORMAL, LIGHT);
	float diffuse_amount = NdotL + (attenuation - 1.0) + wrap;
	diffuse_amount *= steepness;
	float cuts_inv = 1.0f / float(cuts);
	float diffuse_stepped = clamp(diffuse_amount + mod(1.0f - diffuse_amount, cuts_inv), 0.0f, 1.0f);
	
	if (use_dither) {
		vec2 screen_uv = FRAGCOORD.xy/viewport_size;
		ivec2 noise_size = textureSize(dither_texture, 0);
		vec2 inv_noise_size = vec2(1.0 / float(noise_size.x), 1.0 / float(noise_size.y));
		vec2 noise_uv = screen_uv * inv_noise_size * viewport_size / vec2(float(dither_size));
		float threshold = texture(dither_texture, noise_uv).r;
		
		diffuse_stepped = diffuse_stepped > threshold ? 1.0 : 0.0;
	}
	
	// Apply diffuse result to different styles.
	vec3 diffuse = ALBEDO.rgb * LIGHT_COLOR / PI;
	if (use_ramp) {
		diffuse *= adjust_rgb(texture(ramp, vec2(min(max(diffuse_stepped,0.01f),0.99f), 0.0f)).rgb);
	} else {
		diffuse *= diffuse_stepped;
	}
	
	diffuse *= min(attenuation, 1.0);
	
	if (clamp_diffuse_to_max) {
		// Clamp diffuse to max for multiple light sources.
		DIFFUSE_LIGHT = max(DIFFUSE_LIGHT, diffuse);
	} else {
		DIFFUSE_LIGHT += diffuse;
	}
	
	// Specular lighting.
	if (use_specular) {
		vec3 H = normalize(LIGHT + VIEW);
		float NdotH = dot(NORMAL, H);
		float specular_amount = max(pow(NdotH, specular_shininess*specular_shininess), 0.0f)
							    * texture(specular_map, UV).r
								* attenuation;
		specular_amount = split_specular(specular_amount);
		SPECULAR_LIGHT += specular_strength * specular_amount * LIGHT_COLOR;
	}
}
