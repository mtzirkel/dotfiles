#version 300 es
// Maps the grayscale binaryring output onto the Tokyo Night palette.
precision highp float;
in vec2 v_texcoord;
uniform sampler2D tex;
out vec4 fragColor;

void main() {
    vec3 c = texture(tex, v_texcoord).rgb;
    float l = dot(c, vec3(0.2126, 0.7152, 0.0722));

    vec3 bg     = vec3(0.102, 0.106, 0.149); // #1a1b26
    vec3 blue   = vec3(0.478, 0.635, 0.969); // #7aa2f7
    vec3 purple = vec3(0.733, 0.604, 0.969); // #bb9af7
    vec3 fg     = vec3(0.753, 0.792, 0.961); // #c0caf5

    vec3 o;
    if (l < 0.55)      o = mix(bg, blue, l / 0.55);
    else if (l < 0.85) o = mix(blue, purple, (l - 0.55) / 0.30);
    else               o = mix(purple, fg, (l - 0.85) / 0.15);
    fragColor = vec4(o, 1.0);
}
