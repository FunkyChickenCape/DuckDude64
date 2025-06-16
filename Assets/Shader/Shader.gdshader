shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;
uniform float pixel_size : hint_range(1.0, 6.0) = 3.0;
uniform float color_levels : hint_range(2.0, 8.0) = 5.0;
uniform float noise_strength : hint_range(0.0, 0.1) = 0.03;
uniform float scanline_strength : hint_range(0.0, 0.3) = 0.15;

float rand(vec2 co) {
    return fract(sin(dot(co.xy ,vec2(12.9898,78.233))) * 43758.5453);
}

void fragment() {
    vec2 resolution = vec2(textureSize(SCREEN_TEXTURE, 0));
    
    // Пикселизация UV
    vec2 pixel_uv = floor(UV * resolution / pixel_size) * pixel_size / resolution;

    // Дрожание UV (имитация аффинной текстуры)
    float jitter = (rand(pixel_uv * resolution + TIME * 30.0) - 0.5) * noise_strength;
    pixel_uv += vec2(jitter, jitter);

    // Выбираем цвет с дрожанием UV
    vec4 color = texture(SCREEN_TEXTURE, pixel_uv);

    // Квантование цвета
    color.rgb = floor(color.rgb * color_levels) / (color_levels - 1.0);

    // Добавляем сканлайны
    float scanline = 1.0 - scanline_strength * sin(UV.y * resolution.y * 3.1415 * 2.0);

    // Итоговый цвет
    color.rgb *= scanline;

    COLOR = color;
}
