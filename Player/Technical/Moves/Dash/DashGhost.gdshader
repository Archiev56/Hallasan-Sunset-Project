shader_type canvas_item;

uniform bool whiten = false;
uniform float mix_weight = 0.7;

void fragment() {
    vec4 texture_color = texture(TEXTURE, UV);
    if (whiten) {
        vec3 white = vec3(1, 1, 1);
        vec3 whitened_texture_rgb = mix(texture_color.rgb, white, mix_weight);
        COLOR = vec4(whitened_texture_rgb, texture_color.a);
    } else {
        COLOR = texture_color; // Missing semicolon fixed
    }
}
