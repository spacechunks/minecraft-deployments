#version 330

#moj_import <minecraft:fog.glsl>
#moj_import <minecraft:dynamictransforms.glsl>
#moj_import <minecraft:emissive_utils.glsl>

uniform sampler2D Sampler0;

in float sphericalVertexDistance;
in float cylindricalVertexDistance;
in vec4 vertexColor;
in vec4 faceLightColor;
in vec4 lightMapColor;
in vec2 texCoord0;

out vec4 fragColor;

void main() {
    vec4 color = texture(Sampler0, texCoord0);
#ifdef ALPHA_CUTOUT
    if (color.a < ALPHA_CUTOUT) {
        discard;
    }
#endif

    color *= vertexColor * ColorModulator;
    color = make_emissive(color, lightMapColor, faceLightColor, int(round(textureLod(Sampler0, texCoord0, 0.0).a * 255.0)));
    fragColor = apply_fog(color, sphericalVertexDistance, cylindricalVertexDistance, FogEnvironmentalStart, FogEnvironmentalEnd, FogRenderDistanceStart, FogRenderDistanceEnd, FogColor);
}
