shader_type canvas_item;

uniform vec2 initial_z = vec2(0.0);
uniform vec2 c_value = vec2(-1.15, 0.26);
uniform vec2 x_value = vec2(2.0,0.0);

#include "rendering.gdshaderinc"
#include "complex_math.gdshaderinc"

uniform vec2 viewport_size;

vec4 draw(vec2 z, vec2 c, vec2 x) {
	int iterations = 0;
	
	for (int i = 0; i < max_iterations; i++) {
		float r = length(z);
		
		if (r == 0.0) {
			z = c;
		} else { // z_n+1 = z_n^x + c
			float theta = atan(z.y,z.x);
			z = vec2(
				pow(r,x.x)*exp(-x.y*theta)*cos((x.x*theta)+(x.y*log(r))),
				pow(r,x.x)*exp(-x.y*theta)*sin((x.x*theta)+(x.y*log(r)))
			) + c;
			//z = c_power(z,x) + c
		}
		
		if (length(z) > escape_value && use_escape_time_coloring) { break; }
		iterations++;
	}
	if (use_escape_time_coloring) {
		if (iterations == max_iterations) {
			return vec4(in_set_color/255.0, 1.0);
		} else {
			return vec4(color_getter_escape_time(iterations), 1.0);
		}
		
	}
}

void fragment() {
	vec2 uv = FRAGCOORD.xy - viewport_size/2.0;
	
	if (var_on_pixels == 1) {
		vec2 z = uv * zoom / 1000.0 + vec2(center.x, -center.y);
		COLOR = draw(z, c_value, x_value);
	} else if (var_on_pixels == 2) {
		vec2 x = uv * zoom / 1000.0 + vec2(center.x, -center.y);
		COLOR = draw(initial_z, c_value, x);
	} else {
		vec2 c = uv * zoom / 1000.0 + vec2(center.x, -center.y);
		COLOR = draw(initial_z, c, x_value);
	}
}