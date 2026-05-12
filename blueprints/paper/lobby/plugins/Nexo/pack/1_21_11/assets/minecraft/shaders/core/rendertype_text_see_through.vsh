#version 330

#moj_import <minecraft:dynamictransforms.glsl>
#moj_import <minecraft:projection.glsl>

in vec3 Position;
in vec4 Color;
in vec2 UV0;

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

    if (marker) {
        position.y += HEAD_VERTICAL_OFFSET;
        vertexColor = vec4(1.0, 1.0, 1.0, Color.a);
    } else {
        vertexColor = Color;
    }

    gl_Position = ProjMat * ModelViewMat * vec4(position, 1.0);
    texCoord0 = UV0;
}
