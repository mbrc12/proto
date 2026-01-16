uniform mediump float pl;
uniform mediump float pr;
uniform mediump float pt;
uniform mediump float pb;
uniform mediump vec2 portionSize;
uniform mediump vec2 portionPos;
uniform mediump vec2 scale;
uniform mediump int tiledX;
uniform mediump int tiledY;
uniform mediump vec2 texSize;
uniform mediump float offsetX;
uniform mediump float offsetY;

#COMMON

#ifdef VERTEX
vec4 position( mat4 transform_projection, vec4 vertex_position )
{
    return transform_projection * vertex_position;
}
#endif

#ifdef PIXEL

float clamp9(float pixel, float portion, float scale, float l, float r, int tiled, float offset) {
    if (pixel <= l) {
        return pixel;
    } else if (pixel >= portion * scale - r) {
        return portion - (portion * scale - pixel);
    } else {
        if (tiled == 1) {
            offset = positiveMod(offset, portion - l - r);
            float modPixel = mod(pixel - l + offset, portion - l - r);
            return l + modPixel;
        } else {
            return l + ((pixel - l) / (portion * scale - r - l)) * (portion - l - r);
        }
    }
}

vec4 effect(vec4 color, Image tex, vec2 texcoord, vec2 screen_coords) {
    vec2 pixel = (texcoord * texSize - portionPos) * scale;
    vec2 target = vec2(clamp9(pixel.x, portionSize.x, scale.x, pl, pr, tiledX, offsetX),
                       clamp9(pixel.y, portionSize.y, scale.y, pt, pb, tiledY, offsetY));
    vec2 uv = (portionPos + target) / texSize;
    return Texel(tex, uv) * color;
}

#endif
