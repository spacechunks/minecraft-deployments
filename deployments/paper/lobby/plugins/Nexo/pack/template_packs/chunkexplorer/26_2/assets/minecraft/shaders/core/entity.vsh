#version 330

#moj_import <minecraft:light.glsl>
#moj_import <minecraft:fog.glsl>
#moj_import <minecraft:dynamictransforms.glsl>
#moj_import <minecraft:projection.glsl>
#moj_import <minecraft:sample_lightmap.glsl>

in vec3 Position;
in vec4 Color;
in vec2 UV0;
in ivec2 UV1;
in ivec2 UV2;
in vec3 Normal;

#ifndef NO_OVERLAY
uniform sampler2D Sampler1;
#endif

#ifndef EMISSIVE
uniform sampler2D Sampler2;
#endif

out float sphericalVertexDistance;
out float cylindricalVertexDistance;

#ifdef PER_FACE_LIGHTING
out vec4 vertexPerFaceColorBack;
out vec4 vertexPerFaceColorFront;
out vec4 faceLightColorBack;
out vec4 faceLightColorFront;
#else
out vec4 vertexColor;
out vec4 faceLightColor;
#endif

#ifndef EMISSIVE
out vec4 lightMapColor;
#endif

#ifndef NO_OVERLAY
out vec4 overlayColor;
#endif

out vec2 texCoord0;

void main() {
    gl_Position = ProjMat * ModelViewMat * vec4(Position, 1.0);

    sphericalVertexDistance = fog_spherical_distance(Position);
    cylindricalVertexDistance = fog_cylindrical_distance(Position);

    // Keeps the 26.2 Lighting uniform block active for pipelines that validate it
    // even when cardinal lighting is disabled by render-type defines.
    float lightingUniformKeepAlive =
        dot(Light0_Direction, Light0_Direction) * 1.0e-30 +
        dot(Light1_Direction, Light1_Direction) * 1.0e-30;
    vec4 baseColor = Color + vec4(vec3(lightingUniformKeepAlive), 0.0);

#ifdef PER_FACE_LIGHTING
    vec2 light = minecraft_compute_light(Light0_Direction, Light1_Direction, Normal);
    vertexPerFaceColorBack = baseColor;
    vertexPerFaceColorFront = baseColor;
    faceLightColorBack = minecraft_mix_light_separate(-light, vec4(1.0));
    faceLightColorFront = minecraft_mix_light_separate(light, vec4(1.0));
#elif defined(NO_CARDINAL_LIGHTING)
    vertexColor = baseColor;
    faceLightColor = vec4(1.0);
#else
    vertexColor = baseColor;
    faceLightColor = minecraft_mix_light(Light0_Direction, Light1_Direction, Normal, vec4(1.0));
#endif

#ifndef EMISSIVE
    lightMapColor = sample_lightmap(Sampler2, UV2);
#endif

#ifndef NO_OVERLAY
    overlayColor = texelFetch(Sampler1, UV1, 0);
#endif

    texCoord0 = UV0;

#ifdef APPLY_TEXTURE_MATRIX
    texCoord0 = (TextureMat * vec4(UV0, 0.0, 1.0)).xy;
#endif
}
