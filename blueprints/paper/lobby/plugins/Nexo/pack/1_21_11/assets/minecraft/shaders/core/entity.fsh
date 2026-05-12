#version 330

#moj_import <minecraft:fog.glsl>
#moj_import <minecraft:dynamictransforms.glsl>
#moj_import <minecraft:emissive_utils.glsl>

uniform sampler2D Sampler0;

#ifdef DISSOLVE
uniform sampler2D DissolveMaskSampler;
#endif

in float sphericalVertexDistance;
in float cylindricalVertexDistance;
in vec4 vertexColor;

#ifdef PER_FACE_LIGHTING
in vec4 faceLightColorBack;
in vec4 faceLightColorFront;
#else
in vec4 faceLightColor;
#endif

#ifndef EMISSIVE
in vec4 lightMapColor;
#endif

#ifndef NO_OVERLAY
in vec4 overlayColor;
#endif

in vec2 texCoord0;

out vec4 fragColor;

void main() {
    vec4 color = texture(Sampler0, texCoord0);
#ifdef ALPHA_CUTOUT
    if (color.a < ALPHA_CUTOUT) {
        discard;
    }
#endif

#ifdef PER_FACE_LIGHTING
    vec4 selectedFaceLightColor = gl_FrontFacing ? faceLightColorFront : faceLightColorBack;
#else
    vec4 selectedFaceLightColor = faceLightColor;
#endif

#ifdef DISSOLVE
    if (vertexColor.a < texture(DissolveMaskSampler, texCoord0).a) {
        discard;
    }
    color.a = 1.0;
#endif

    color *= vertexColor * ColorModulator;
#ifndef NO_OVERLAY
    color.rgb = mix(overlayColor.rgb, color.rgb, overlayColor.a);
#endif

#ifndef EMISSIVE
    int alpha = int(round(textureLod(Sampler0, texCoord0, 0.0).a * 255.0));
    color = make_emissive(color, lightMapColor, selectedFaceLightColor, alpha);
#else
    color *= selectedFaceLightColor;
#endif

    fragColor = apply_fog(color, sphericalVertexDistance, cylindricalVertexDistance, FogEnvironmentalStart, FogEnvironmentalEnd, FogRenderDistanceStart, FogRenderDistanceEnd, FogColor);
}
