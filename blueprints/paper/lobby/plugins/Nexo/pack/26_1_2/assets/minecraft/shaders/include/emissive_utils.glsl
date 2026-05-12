#version 330

bool compare_floats(float a, float b) {
    float targetLess = a - 0.01;
    float targetMore = a + 0.01;
    return b > targetLess && b < targetMore;
}

vec4 apply_partial_emissivity(vec4 inputColor, vec4 originalLightColor, vec3 minimumLightColor) {
    vec4 newLightColor = originalLightColor;
    newLightColor.r = max(originalLightColor.r, minimumLightColor.r);
    newLightColor.g = max(originalLightColor.g, minimumLightColor.g);
    newLightColor.b = max(originalLightColor.b, minimumLightColor.b);
    return inputColor * newLightColor;
}

bool face_lighting_check(int inputAlpha) {
    if (inputAlpha == 252) return false;
    if (inputAlpha == 250) return false;
    return true;
}

float remap_alpha(int inputAlpha) {
    if (inputAlpha == 252) return 255.0;
    if (inputAlpha == 251) return 190.0;
    if (inputAlpha == 250) return 255.0;
    return float(inputAlpha);
}

vec4 make_emissive(vec4 inputColor, vec4 lightColor, vec4 faceLightColor, int inputAlpha) {
    if (face_lighting_check(inputAlpha)) inputColor *= faceLightColor;
    inputColor.a = remap_alpha(inputAlpha) / 255.0;

    if (inputAlpha == 252 || inputAlpha == 250) return inputColor;
    if (inputAlpha == 251) return apply_partial_emissivity(inputColor, lightColor, vec3(0.411, 0.345, 0.388));

    return inputColor * lightColor;
}
