shader_type spatial;

uniform vec4 current_color : hint_color;

void fragment(){
	ALBEDO = current_color.rgb;
	ALPHA = 0.5;
}