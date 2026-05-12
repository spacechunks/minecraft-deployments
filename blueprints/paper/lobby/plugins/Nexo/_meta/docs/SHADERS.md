# Shader Overview

The shaders in this repository are maintained for two Minecraft versions:
- `1.21.11`
- `26.1.2`

They live in version-specific overlays:
- `pack/1_21_11`
- `pack/26_1_2`

## Core behavior

1. Text colored `#ff1234` is treated as a marker for player head assets.
   - It is moved down by `8px`.
   - The marker color is replaced with white.
   - The shadow is not moved.

2. Vanilla Dynamic Emissives was adapted for `1.21.11` and `26.1.2`.
   - Emissive behavior is handled through the versioned core shaders and `emissive_utils.glsl`.
   - `terrain` shaders were removed because Sodium does not support overridden terrain/core shaders.

## References

- Vanilla Dynamic Emissives: https://github.com/ShockMicro/VanillaDynamicEmissives
- Sodium resource pack compatibility: https://github.com/CaffeineMC/sodium/wiki/Resource-Packs
