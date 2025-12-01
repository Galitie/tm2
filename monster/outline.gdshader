shader_type canvas_item;
render_mode unshaded;

const vec2 OFFSETS[16] = {
	vec2(0.45, 0.89), vec2(0.89, 0.45), vec2(0.89, -0.45), vec2(0.45, -0.89),
	vec2(-0.45, -0.89), vec2(-0.89, -0.45), vec2(-0.89, 0.45), vec2(-0.45, 0.89),
	vec2(-0.71, -0.71), vec2(-1, 0), vec2(-0.71, 0.71), vec2(0, -1), vec2(0, 1),
	vec2(0.71, -0.71), vec2(1, 0), vec2(0.71, 0.71)
};

uniform float alpha = 1.0;

uniform vec2 positions[10];
uniform vec4 colors[10];

uniform float line_thickness : hint_range(0.0, 10.0);
uniform vec4 line_color : source_color = vec4(1.0);
uniform vec4 outer_color : source_color = vec4(0.0);
uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;

void fragment() {
	// Get the size of the pixels on screen, and create a variable for out outline
	vec2 size = line_thickness * SCREEN_PIXEL_SIZE;
	float outline = 0.0;
	float outer_outline = 0.0;

	// Get the texture from the screen
	vec4 color = texture(screen_texture, SCREEN_UV);

	// Project in each direction, and add up the alpha of each projection.
	// This is similar to picking a point, hit testing in 8 directions, and
	// returning true if the hit test works
	for (int i = 0; i < OFFSETS.length(); i++) {
		vec2 coordinate_offset = SCREEN_UV + size * OFFSETS[i];
		outline += texture(screen_texture, coordinate_offset).a;
		
		vec2 outer_offset = SCREEN_UV + size * 2.0 * OFFSETS[i];
		outer_outline += texture(screen_texture, outer_offset).a;
	}

	// Force outline to 1 or 0
	outline = sign(outline);

	vec2 texture_size = vec2(textureSize(TEXTURE, 0));

	vec4 blended_color = vec4(0.0);
	float total_weight = 0.0;

	if (color.a > 0.0) {
		for (int i = 0; i < 10; i++)
		{
			float dist = length(positions[i] - UV);
			float weight = 1.0 / (dist + 0.05);
			blended_color += colors[i] * weight;
			total_weight += weight;
		}

		blended_color /= total_weight;
		//color = blended_color;
	}

	// If the alpha exists at least a little bit, amplify the colors.
	// This ensures alpha and colors remain precise even when reading from screen.
	if (color.a > 0.0001) {
		color.rgb /= color.a;
	}

	if (outline > 0.0) {
		COLOR = mix(color, line_color, outline - color.a);
		COLOR.a *= alpha;
	}
	else if (outer_outline > 0.0) {
		COLOR = mix(color, outer_color, outer_outline - color.a);
		COLOR.a *= alpha;
	}
	else {
		COLOR = vec4(0.0);
	}
}