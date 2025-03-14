shader_type canvas_item;

uniform vec2 initial_z = vec2(0.0);
uniform vec2 c_value = vec2(0.3, -0.38);
uniform vec2 x_value = vec2(0.0,1.0);

#include "rendering.gdshaderinc"

uniform vec2 viewport_size;

vec4 draw(vec2 z, vec2 c, vec2 x) {
	float le = 0.0;
	int iterations = 0;
	
	for (int i = 0; i < max_iterations; i++) {
		float r = length(z);
		
		if (r == 0.0) {
			z = c;
		} else { // z_n+1 = x^z_n + c
			float theta = atan(x.y,x.x);
			if (use_lyapunov) { le += log(r); }
			z = vec2(
				pow(length(x),z.x)*exp(-z.y*theta)*cos((z.x*theta)+(z.y*log(length(x)))),
				pow(length(x),z.x)*exp(-z.y*theta)*sin((z.x*theta)+(z.y*log(length(x))))
			) + c;
		}
		
		if (length(z) > escape_value && !use_lyapunov) { break; }
		iterations++;
	}
	if (use_lyapunov) { 
		le += log(length(z)); // to cover that very last iteration
		le /= float(max_iterations);
		return vec4(color_getter_le(le), 1.0);
	} else {
		if (iterations == max_iterations) { return vec4(in_set_color/255.0, 1.0);
		} else { return vec4(color_getter_et(iterations), 1.0); }
		
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