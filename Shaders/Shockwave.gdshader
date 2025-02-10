shader_type canvas_item;

uniform float speed : hint_range(0.0, 10.0) = 3.0;
uniform float amplitude : hint_range(0.0, 2.0) = 0.5;
uniform float frequency : hint_range(0.0, 10.0) = 5.0;
uniform float progress : hint_range(0.0, 1.0) = 0.0;
uniform sampler2D noise_texture;

void fragment() {
    vec2 uv = UV;
    vec2 center = vec2(0.5);
    float dist = distance(uv, center);

    // Shockwave effect calculation
    float wave = sin(dist * frequency - progress * speed) * amplitude / (dist + 0.1);
    float noise = texture(noise_texture, uv * 2.0).r;
    vec2 offset = normalize(uv - center) * wave * noise;

    // Apply fade-out effect
    float fade = smoothstep(1.0, 0.0, progress);

    COLOR = texture(TEXTURE, uv + offset) * fade;
}
