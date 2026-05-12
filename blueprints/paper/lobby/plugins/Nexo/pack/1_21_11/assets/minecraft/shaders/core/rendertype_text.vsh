#version 330

#moj_import <minecraft:fog.glsl>
#moj_import <minecraft:dynamictransforms.glsl>
#moj_import <minecraft:projection.glsl>

in vec3 Position;
in vec4 Color;
in vec2 UV0;
in ivec2 UV2;

uniform sampler2D Sampler2;

out float sphericalVertexDistance;
out float cylindricalVertexDistance;
out vec4 vertexColor;
out vec2 texCoord0;

const vec3 HEAD_MARKER_COLOR = vec3(1.0, 18.0 / 255.0, 52.0 / 255.0);
const float HEAD_MARKER_EPSILON = 0.0025;
const float HEAD_VERTICAL_OFFSET = 8.0;

bool is_head_marker(vec4 color) {
    return color.a > 0.0 && distance(color.rgb, HEAD_MARKER_COLOR) <= HEAD_MARKER_EPSILON;
}

void main() {
    bool marker = is_head_marker(Color);
    vec3 position = Position;
    vec4 tint = marker ? vec4(1.0, 1.0, 1.0, Color.a) : Color;

    if (marker) {
        position.y += HEAD_VERTICAL_OFFSET;
    }

    gl_Position = ProjMat * ModelViewMat * vec4(position, 1.0);

    sphericalVertexDistance = fog_spherical_distance(position);
    cylindricalVertexDistance = fog_cylindrical_distance(position);
    vertexColor = tint * texelFetch(Sampler2, UV2 / 16, 0);
    texCoord0 = UV0;
}
