shader_type canvas_item;

// Controlli RGB
uniform float red_factor : hint_range(0.0, 2.0) = 1.0;
uniform float green_factor : hint_range(0.0, 2.0) = 1.0;
uniform float blue_factor : hint_range(0.0, 2.0) = 1.0;

// Controlli Saturazione, Contrasto, Luminosità e Hue
uniform float saturation : hint_range(0.0, 2.0) = 1.0;    // Saturazione
uniform float brightness : hint_range(-1.0, 1.0) = 0.0;  // Luminosità
uniform float contrast : hint_range(0.0, 2.0) = 1.0;     // Contrasto
uniform float hue_shift : hint_range(-1.0, 1.0) = 0.0;   // Shift Tonalità
uniform float gamma : hint_range(0.1, 3.0) = 1.0;        // Gamma Correction

// Varying to capture built‑in COLOR (vertex_color × modulate × self_modulate)
varying vec4 v_modulate;

void vertex() {
    // Store the incoming modulate*vertex_color for the fragment stage
    v_modulate = COLOR;
}

// Funzione per convertire da RGB a HSL
vec3 rgb2hsl(vec3 color) {
    float max_color = max(max(color.r, color.g), color.b);
    float min_color = min(min(color.r, color.g), color.b);
    float delta = max_color - min_color;

    float lightness = (max_color + min_color) / 2.0;
    float hue = 0.0;
    float sat = 0.0;

    if (delta != 0.0) {
        sat = (lightness < 0.5)
            ? (delta / (max_color + min_color))
            : (delta / (2.0 - max_color - min_color));

        if (max_color == color.r) {
            hue = (color.g - color.b) / delta + (color.g < color.b ? 6.0 : 0.0);
        } else if (max_color == color.g) {
            hue = (color.b - color.r) / delta + 2.0;
        } else {
            hue = (color.r - color.g) / delta + 4.0;
        }

        hue /= 6.0;
    }

    return vec3(hue, sat, lightness);
}

// Funzione per convertire da HSL a RGB
vec3 hsl2rgb(vec3 hsl) {
    float hue = hsl.x;
    float sat = hsl.y;
    float lightness = hsl.z;

    float chroma = (1.0 - abs(2.0 * lightness - 1.0)) * sat;
    float h = hue * 6.0;
    float x = chroma * (1.0 - abs(mod(h, 2.0) - 1.0));

    vec3 result;
    if      (h < 1.0) result = vec3(chroma, x, 0.0);
    else if (h < 2.0) result = vec3(x, chroma, 0.0);
    else if (h < 3.0) result = vec3(0.0, chroma, x);
    else if (h < 4.0) result = vec3(0.0, x, chroma);
    else if (h < 5.0) result = vec3(x, 0.0, chroma);
    else              result = vec3(chroma, 0.0, x);

    float m = lightness - chroma / 2.0;
    return result + vec3(m);
}

void fragment() {
    // Prendi il colore della texture
    vec4 tex_color = texture(TEXTURE, UV);

    // Modifica RGB
    tex_color.r *= red_factor;
    tex_color.g *= green_factor;
    tex_color.b *= blue_factor;

    // Converte il colore in HSL e applica shift/saturazione
    vec3 hsl = rgb2hsl(tex_color.rgb);
    hsl.x = mod(hsl.x + hue_shift, 1.0);
    hsl.y *= saturation;

    // Riconverti in RGB
    vec3 final_rgb = hsl2rgb(hsl);

    // Applica Luminosità e Contrasto
    final_rgb = final_rgb * contrast + vec3(brightness);

    // Applica la correzione gamma
    final_rgb = pow(final_rgb, vec3(gamma));

    // Ripristina il modulate originale
    COLOR = vec4(final_rgb, tex_color.a) * v_modulate;
}
