shader_type canvas_item;

uniform float appear_time = 2.0;

float rand(vec2 co) {
    return fract(sin(dot(co.xy, vec2(12.9898,78.233))) * 43758.5453);
}

void fragment() {
    vec2 uv = UV;
    float t = clamp(TIME / appear_time, 0.0, 1.0);
    float noise = rand(floor(uv * 50.0));
    if (noise > t) discard;
    COLOR = texture(TEXTURE, uv);
}
