#ifdef VERTEX
vec4 position( mat4 transform_projection, vec4 vertex_position )
{
    return transform_projection * vertex_position;
}
#endif

#ifdef PIXEL

vec4 effect(vec4 color, Image tex, vec2 texcoord, vec2 screen_coords) {
    vec4 pixel = Texel(tex, texcoord);
    if (pixel.a < 0.1) {
        discard;
    }

    return color * pixel;
}

#endif
