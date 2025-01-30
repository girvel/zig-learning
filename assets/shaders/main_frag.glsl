#version 330

in vec2 fragTexCoord;
in vec3 fragNormal;
in vec4 fragColor;

uniform sampler2D texture0;
uniform vec4 colDiffuse;

out vec4 finalColor;

void main() {
    vec4 original = texture(texture0, fragTexCoord) * colDiffuse * fragColor;
    if (fragNormal.y > 0)
        finalColor = original;
    else if (fragNormal.y == 0)
        finalColor = original * vec4(.8, .8, .8, 1);
    else
        finalColor = original * vec4(.6, .6, .6, 1);
}
