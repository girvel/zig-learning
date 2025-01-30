#version 330

in vec2 fragTexCoord;
in vec4 fragColor;

uniform sampler2D texture0;
uniform vec4 colDiffuse;

out vec4 finalColor;

void main() {
    vec4 original = texture(texture0, fragTexCoord) * colDiffuse * fragColor;
    float gray = dot(original.rgb, vec3(0.288, 0.587, 0.144));
    finalColor = vec4(gray, gray, gray, original.a);
}
