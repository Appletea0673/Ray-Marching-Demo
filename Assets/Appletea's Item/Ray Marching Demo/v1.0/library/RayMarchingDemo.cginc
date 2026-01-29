#ifndef RAYMARCHING_DEMO_CGINC
#define RAYMARCHING_DEMO_CGINC

#pragma multi_compile _ SHAPE_CHANGE

#ifndef UNITY_PI
    #define UNITY_PI 3.14159265359
#endif
    
uniform float4 _Color;
uniform float _ShapeShift;

// inline修飾子は関数を展開した状態でコンパイルする
inline float bevel(float x,float size) { return max(0.15 * size, abs(x)); }

inline float bevelMax(float a, float b, float size) { return (a + b + bevel(a - b, size)) * 0.5; }

inline float dot2(float2 v) { return dot(v,v); }

float torus(float3 p)
{
    float h = sin(_Time.y) * 0.05 + 0.05;
    p.x -= clamp(p.x, -h, h);
    return length(float2(length(p.xy) - 0.3, p.z)) - 0.1;
}

float Heart2d(float2 p, float size)
{
    p.y += 0.6 * size;
    p.x = abs(p.x);

    if(p.y + p.x > size)
        return sqrt(dot2(p - float2(0.25 * size, 0.75 * size))) - size * sqrt(2) / 4;
    return sqrt(min(dot2(p - float2(0.00,1.00 * size)),
                    dot2(p - 0.5 * max(p.x + p.y, 0)))) * sign(p.x - p.y);
}

float Heart3d(float3 p, float2 size)
{
    float sdf2d = Heart2d(p.xy, size.x);
    
    // Bevel : Anti-Artifact
    return bevelMax(sdf2d, abs(p.z) - 0.05 * size.y, size.x);
}

float Star2d(float2 p, float r, float n, float w)
{
    float m = n + w * (2 - n);
    
    float an = UNITY_PI / n;
    float en = UNITY_PI / m;
    float2 racs = r * float2(cos(an), sin(an));
    float2 ecs =   float2(cos(en), sin(en));

    p.x = abs(p.x);
    
    // Reduce to first sector
    float bn = fmod(atan2(p.x, p.y), 2 * an) - an;
    p = length(p) * float2(cos(bn), abs(sin(bn)));

    // line sdf
    p -= racs;
    p += ecs * clamp(-dot(p, ecs), 0, racs.y / ecs.y);
    return length(p) * sign(p.x);
}

float Star3d(float3 p, float3 size, float t)
{
    float sdf2d = Star2d(p.xy, size, 5, t);
    
    // Bevel : Anti-Artifact
    return bevelMax(sdf2d, abs(p.z) - 0.05 * size.x * size.y, size.x * size.z);
}

float distanceField(float3 p)
{
    #ifdef SHAPE_CHANGE
        return lerp(Heart3d(p, float2(0.8, 1)), torus(p), _ShapeShift);
    #else
        return lerp(Heart3d(p, float2(0.8, 1)), Star3d(p, float3(0.5, 5, 0.3), 0.5), _ShapeShift);
    #endif
}

float3 getNormal(float3 p)
{
    float d = distanceField(p).x;
    const float2 e = float2(.01, 0);
    float3 n = d - float3(distanceField(p - e.xyy).x, distanceField(p - e.yxy).x, distanceField(p - e.yyx).x);
    return normalize(n);
}

float4 RayMarching(float3 pos)
{
    // World座標系のRay Marching
    // float3 ro = _WorldSpaceCameraPos;
    // float3 rd = normalize(pos.xyz - ro);
                
    // Local座標系のRay Marching
    float3 ro = mul(unity_WorldToObject,float4(_WorldSpaceCameraPos,1)).xyz;
    float3 rd = normalize(pos.xyz - ro);

    const int maxIteration = 100;
    const float precision = 0.001;
    const float maxDistance = 1000;
    float d = 0;
    float t = 0;
    float3 p = float3(0, 0, 0);
    int k;
                
    // Ray Marchingのメインループ
    // [unroll]
    for (int i = 0; i < maxIteration; ++i)
    {
        p = ro + rd * t;
        d = distanceField(p);
        t += d;
        if (d < precision || t > maxDistance) break;
        k = i;
    }

    p = ro + rd * t;
    
    float4 col = float4(0, 0, 0, 1);

    #ifdef SHAPE_CHANGE
        // ピンクとドーナツ色変化
        col.rgb = lerp(float3(1, 0.5, 1), float3(0.5, 0.5, 1), _ShapeShift);
    #else
        // ピンクと黄色の色変化
        col.rgb = lerp(float3(1, 0.5, 1), float3(1, 1, 0.5), _ShapeShift);
    #endif
    
    col *= _Color;

    if (d > precision) discard;
    else 
    {
        float3 normal = getNormal(p);
        float3 lightdir = normalize(_WorldSpaceLightPos0.xyz);
    
        // 影(ランバート反射)を計算
        float NdotL = max(0, dot(normal, lightdir)); 
        col = float4(col.rgb * NdotL, 1);
        // Ambient Occlusion
        col += (float)k / maxIteration;
    }
    return col;
}
                      
#define MAGIC_VERTEX_STRUCTURE float3 pos : TEXCOORD1;

// Local座標系のRay Marching
#define MAGIC_VERTEX o.pos = v.vertex.xyz;

#define MAGIC_FRAGMENT col = RayMarching(i.pos);

#undef UNITY_PI

#endif