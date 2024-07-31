#pragma clang diagnostic ignored "-Wmissing-prototypes"
#pragma clang diagnostic ignored "-Wmissing-braces"

#include <metal_stdlib>
#include <simd/simd.h>

using namespace metal;

template<typename T, size_t Num>
struct spvUnsafeArray
{
    T elements[Num ? Num : 1];
    
    thread T& operator [] (size_t pos) thread
    {
        return elements[pos];
    }
    constexpr const thread T& operator [] (size_t pos) const thread
    {
        return elements[pos];
    }
    
    device T& operator [] (size_t pos) device
    {
        return elements[pos];
    }
    constexpr const device T& operator [] (size_t pos) const device
    {
        return elements[pos];
    }
    
    constexpr const constant T& operator [] (size_t pos) const constant
    {
        return elements[pos];
    }
    
    threadgroup T& operator [] (size_t pos) threadgroup
    {
        return elements[pos];
    }
    constexpr const threadgroup T& operator [] (size_t pos) const threadgroup
    {
        return elements[pos];
    }
};

struct Light
{
    float lightIntensity;
    int lightType;
    int lightCastShadow;
    int lightShadowMapIndex;
    int lightAngleAttenCurveType;
    int lightDistAttenCurveType;
    float2 lightSize;
    int4 lightGUID;
    float4 lightPosition;
    float4 lightColor;
    float4 lightDirection;
    spvUnsafeArray<float4, 2> lightDistAttenCurveParams;
    spvUnsafeArray<float4, 2> lightAngleAttenCurveParams;
    float4x4 lightVP;
    spvUnsafeArray<float4, 2> padding;
};

struct Light_1
{
    float lightIntensity;
    int lightType;
    int lightCastShadow;
    int lightShadowMapIndex;
    int lightAngleAttenCurveType;
    int lightDistAttenCurveType;
    float2 lightSize;
    int4 lightGUID;
    float4 lightPosition;
    float4 lightColor;
    float4 lightDirection;
    float4 lightDistAttenCurveParams[2];
    float4 lightAngleAttenCurveParams[2];
    float4x4 lightVP;
    float4 padding[2];
};

struct PerFrameConstants
{
    float4x4 viewMatrix;
    float4x4 projectionMatrix;
    float4 camPos;
    int numLights;
    Light_1 allLights[100];
};

struct constants_t
{
    float4 ambientColor;
    float4 specularColor;
    float specularPower;
};

struct PerBatchConstants
{
    float4x4 modelMatrix;
};

constant spvUnsafeArray<float2, 4> _354 = spvUnsafeArray<float2, 4>({ float2(-0.94201624393463134765625, -0.39906215667724609375), float2(0.94558608531951904296875, -0.768907248973846435546875), float2(-0.094184100627899169921875, -0.929388701915740966796875), float2(0.34495937824249267578125, 0.29387760162353515625) });

struct main0_out
{
    float4 outputColor [[color(0)]];
};

struct main0_in
{
    float4 normal [[user(locn0)]];
    float4 normal_world [[user(locn1)]];
    float4 v [[user(locn2)]];
    float4 v_world [[user(locn3)]];
    float2 uv [[user(locn4)]];
};

static inline __attribute__((always_inline))
float3 projectOnPlane(thread const float3& point, thread const float3& center_of_plane, thread const float3& normal_of_plane)
{
    return point - (normal_of_plane * dot(point - center_of_plane, normal_of_plane));
}

static inline __attribute__((always_inline))
float linear_interpolate(thread const float& t, thread const float& begin, thread const float& end)
{
    if (t < begin)
    {
        return 1.0;
    }
    else
    {
        if (t > end)
        {
            return 0.0;
        }
        else
        {
            return (end - t) / (end - begin);
        }
    }
}

static inline __attribute__((always_inline))
float apply_atten_curve(thread const float& dist, thread const int& atten_curve_type, thread const spvUnsafeArray<float4, 2>& atten_params)
{
    float atten = 1.0;
    switch (atten_curve_type)
    {
        case 1:
        {
            float begin_atten = atten_params[0].x;
            float end_atten = atten_params[0].y;
            float param = dist;
            float param_1 = begin_atten;
            float param_2 = end_atten;
            atten = linear_interpolate(param, param_1, param_2);
            break;
        }
        case 2:
        {
            float begin_atten_1 = atten_params[0].x;
            float end_atten_1 = atten_params[0].y;
            float param_3 = dist;
            float param_4 = begin_atten_1;
            float param_5 = end_atten_1;
            float tmp = linear_interpolate(param_3, param_4, param_5);
            atten = (3.0 * powr(tmp, 2.0)) - (2.0 * powr(tmp, 3.0));
            break;
        }
        case 3:
        {
            float scale = atten_params[0].x;
            float offset = atten_params[0].y;
            float kl = atten_params[0].z;
            float kc = atten_params[0].w;
            atten = fast::clamp((scale / ((kl * dist) + (kc * scale))) + offset, 0.0, 1.0);
            break;
        }
        case 4:
        {
            float scale_1 = atten_params[0].x;
            float offset_1 = atten_params[0].y;
            float kq = atten_params[0].z;
            float kl_1 = atten_params[0].w;
            float kc_1 = atten_params[1].x;
            atten = fast::clamp(powr(scale_1, 2.0) / ((((kq * powr(dist, 2.0)) + ((kl_1 * dist) * scale_1)) + (kc_1 * powr(scale_1, 2.0))) + offset_1), 0.0, 1.0);
            break;
        }
        default:
        {
            break;
        }
    }
    return atten;
}

static inline __attribute__((always_inline))
bool isAbovePlane(thread const float3& point, thread const float3& center_of_plane, thread const float3& normal_of_plane)
{
    return dot(point - center_of_plane, normal_of_plane) > 0.0;
}

static inline __attribute__((always_inline))
float3 linePlaneIntersect(thread const float3& line_start, thread const float3& line_dir, thread const float3& center_of_plane, thread const float3& normal_of_plane)
{
    return line_start + (line_dir * (dot(center_of_plane - line_start, normal_of_plane) / dot(line_dir, normal_of_plane)));
}

static inline __attribute__((always_inline))
float3 apply_areaLight(Light light, thread float4& normal, constant PerFrameConstants& _500, thread float4& v, texture2d<float> diffuseMap, sampler diffuseMapSmplr, thread float2& uv, constant constants_t& u_pushConstants)
{
    float3 N = fast::normalize(normal.xyz);
    float3 right = fast::normalize((_500.viewMatrix * float4(1.0, 0.0, 0.0, 0.0)).xyz);
    float3 pnormal = fast::normalize((_500.viewMatrix * light.lightDirection).xyz);
    float3 ppos = (_500.viewMatrix * light.lightPosition).xyz;
    float3 up = fast::normalize(cross(pnormal, right));
    right = fast::normalize(cross(up, pnormal));
    float width = light.lightSize.x;
    float height = light.lightSize.y;
    float3 param = v.xyz;
    float3 param_1 = ppos;
    float3 param_2 = pnormal;
    float3 projection = projectOnPlane(param, param_1, param_2);
    float3 dir = projection - ppos;
    float2 diagonal = float2(dot(dir, right), dot(dir, up));
    float2 nearest2D = float2(fast::clamp(diagonal.x, -width, width), fast::clamp(diagonal.y, -height, height));
    float3 nearestPointInside = (ppos + (right * nearest2D.x)) + (up * nearest2D.y);
    float3 L = nearestPointInside - v.xyz;
    float lightToSurfDist = length(L);
    L = fast::normalize(L);
    float param_3 = lightToSurfDist;
    int param_4 = light.lightDistAttenCurveType;
    spvUnsafeArray<float4, 2> param_5 = light.lightDistAttenCurveParams;
    float atten = apply_atten_curve(param_3, param_4, param_5);
    float3 linearColor = float3(0.0);
    float pnDotL = dot(pnormal, -L);
    float nDotL = dot(N, L);
    bool _750 = nDotL > 0.0;
    bool _761;
    if (_750)
    {
        float3 param_6 = v.xyz;
        float3 param_7 = ppos;
        float3 param_8 = pnormal;
        _761 = isAbovePlane(param_6, param_7, param_8);
    }
    else
    {
        _761 = _750;
    }
    if (_761)
    {
        float3 V = fast::normalize(-v.xyz);
        float3 R = fast::normalize((N * (2.0 * dot(V, N))) - V);
        float3 R2 = fast::normalize((N * (2.0 * dot(L, N))) - L);
        float3 param_9 = v.xyz;
        float3 param_10 = R;
        float3 param_11 = ppos;
        float3 param_12 = pnormal;
        float3 E = linePlaneIntersect(param_9, param_10, param_11, param_12);
        float specAngle = fast::clamp(dot(-R, pnormal), 0.0, 1.0);
        float3 dirSpec = E - ppos;
        float2 dirSpec2D = float2(dot(dirSpec, right), dot(dirSpec, up));
        float2 nearestSpec2D = float2(fast::clamp(dirSpec2D.x, -width, width), fast::clamp(dirSpec2D.y, -height, height));
        float specFactor = 1.0 - fast::clamp(length(nearestSpec2D - dirSpec2D), 0.0, 1.0);
        float3 admit_light = light.lightColor.xyz * (light.lightIntensity * atten);
        linearColor = (diffuseMap.sample(diffuseMapSmplr, uv).xyz * nDotL) * pnDotL;
        linearColor += (((u_pushConstants.specularColor.xyz * powr(fast::clamp(dot(R2, V), 0.0, 1.0), u_pushConstants.specularPower)) * specFactor) * specAngle);
        linearColor *= admit_light;
    }
    return linearColor;
}

static inline __attribute__((always_inline))
float shadow_test(float4 p, Light light, float cosTheta, texturecube_array<float> cubeShadowMap, sampler cubeShadowMapSmplr, texture2d_array<float> shadowMap, sampler shadowMapSmplr, texture2d_array<float> globalShadowMap, sampler globalShadowMapSmplr)
{
    float4 v_light_space = light.lightVP * p;
    v_light_space /= float4(v_light_space.w);
    float visibility = 1.0;
    if (light.lightShadowMapIndex != (-1))
    {
        float bias0 = 0.0005000000237487256526947021484375 * tan(acos(cosTheta));
        bias0 = fast::clamp(bias0, 0.0, 0.00999999977648258209228515625);
        float near_occ;
        switch (light.lightType)
        {
            case 0:
            {
                float3 L = p.xyz - light.lightPosition.xyz;
                float4 _299 = float4(L, float(light.lightShadowMapIndex));
                near_occ = cubeShadowMap.sample(cubeShadowMapSmplr, _299.xyz, uint(rint(_299.w))).x;
                if ((length(L) - (near_occ * 10.0)) > bias0)
                {
                    visibility -= 0.87999999523162841796875;
                }
                break;
            }
            case 1:
            {
                v_light_space = float4x4(float4(0.5, 0.0, 0.0, 0.0), float4(0.0, 0.5, 0.0, 0.0), float4(0.0, 0.0, 0.5, 0.0), float4(0.5, 0.5, 0.5, 1.0)) * v_light_space;
                for (int i = 0; i < 4; i++)
                {
                    float3 _369 = float3(v_light_space.xy + (_354[i] / float2(700.0)), float(light.lightShadowMapIndex));
                    near_occ = shadowMap.sample(shadowMapSmplr, _369.xy, uint(rint(_369.z))).x;
                    if ((v_light_space.z - near_occ) > bias0)
                    {
                        visibility -= 0.2199999988079071044921875;
                    }
                }
                break;
            }
            case 2:
            {
                v_light_space = float4x4(float4(0.5, 0.0, 0.0, 0.0), float4(0.0, 0.5, 0.0, 0.0), float4(0.0, 0.0, 0.5, 0.0), float4(0.5, 0.5, 0.5, 1.0)) * v_light_space;
                for (int i_1 = 0; i_1 < 4; i_1++)
                {
                    float3 _411 = float3(v_light_space.xy + (_354[i_1] / float2(700.0)), float(light.lightShadowMapIndex));
                    near_occ = globalShadowMap.sample(globalShadowMapSmplr, _411.xy, uint(rint(_411.z))).x;
                    if ((v_light_space.z - near_occ) > bias0)
                    {
                        visibility -= 0.2199999988079071044921875;
                    }
                }
                break;
            }
            case 3:
            {
                v_light_space = float4x4(float4(0.5, 0.0, 0.0, 0.0), float4(0.0, 0.5, 0.0, 0.0), float4(0.0, 0.0, 0.5, 0.0), float4(0.5, 0.5, 0.5, 1.0)) * v_light_space;
                for (int i_2 = 0; i_2 < 4; i_2++)
                {
                    float3 _451 = float3(v_light_space.xy + (_354[i_2] / float2(700.0)), float(light.lightShadowMapIndex));
                    near_occ = shadowMap.sample(shadowMapSmplr, _451.xy, uint(rint(_451.z))).x;
                    if ((v_light_space.z - near_occ) > bias0)
                    {
                        visibility -= 0.2199999988079071044921875;
                    }
                }
                break;
            }
        }
    }
    return visibility;
}

static inline __attribute__((always_inline))
float3 apply_light(Light light, texturecube_array<float> cubeShadowMap, sampler cubeShadowMapSmplr, texture2d_array<float> shadowMap, sampler shadowMapSmplr, texture2d_array<float> globalShadowMap, sampler globalShadowMapSmplr, thread float4& normal, constant PerFrameConstants& _500, thread float4& v, thread float4& v_world, texture2d<float> diffuseMap, sampler diffuseMapSmplr, thread float2& uv, constant constants_t& u_pushConstants)
{
    float3 N = fast::normalize(normal.xyz);
    float3 light_dir = fast::normalize((_500.viewMatrix * light.lightDirection).xyz);
    float3 L;
    if (light.lightPosition.w == 0.0)
    {
        L = -light_dir;
    }
    else
    {
        L = (_500.viewMatrix * light.lightPosition).xyz - v.xyz;
    }
    float lightToSurfDist = length(L);
    L = fast::normalize(L);
    float cosTheta = fast::clamp(dot(N, L), 0.0, 1.0);
    float visibility = shadow_test(v_world, light, cosTheta, cubeShadowMap, cubeShadowMapSmplr, shadowMap, shadowMapSmplr, globalShadowMap, globalShadowMapSmplr);
    float lightToSurfAngle = acos(dot(L, -light_dir));
    float param = lightToSurfAngle;
    int param_1 = light.lightAngleAttenCurveType;
    spvUnsafeArray<float4, 2> param_2 = light.lightAngleAttenCurveParams;
    float atten = apply_atten_curve(param, param_1, param_2);
    float param_3 = lightToSurfDist;
    int param_4 = light.lightDistAttenCurveType;
    spvUnsafeArray<float4, 2> param_5 = light.lightDistAttenCurveParams;
    atten *= apply_atten_curve(param_3, param_4, param_5);
    float3 R = fast::normalize((N * (2.0 * dot(L, N))) - L);
    float3 V = fast::normalize(-v.xyz);
    float3 admit_light = light.lightColor.xyz * (light.lightIntensity * atten);
    float3 linearColor = diffuseMap.sample(diffuseMapSmplr, uv).xyz * cosTheta;
    if (visibility > 0.20000000298023223876953125)
    {
        linearColor += (u_pushConstants.specularColor.xyz * powr(fast::clamp(dot(R, V), 0.0, 1.0), u_pushConstants.specularPower));
    }
    linearColor *= admit_light;
    return linearColor * visibility;
}

static inline __attribute__((always_inline))
float3 exposure_tone_mapping(thread const float3& color)
{
    return float3(1.0) - exp((-color) * 1.0);
}

static inline __attribute__((always_inline))
float3 gamma_correction(thread const float3& color)
{
    return powr(color, float3(0.4545454680919647216796875));
}

fragment main0_out main0(main0_in in [[stage_in]], constant PerFrameConstants& _500 [[buffer(0)]], constant constants_t& u_pushConstants [[buffer(1)]], texturecube_array<float> cubeShadowMap [[texture(0)]], texture2d_array<float> shadowMap [[texture(1)]], texture2d_array<float> globalShadowMap [[texture(2)]], texture2d<float> diffuseMap [[texture(3)]], texturecube_array<float> skybox [[texture(4)]], sampler cubeShadowMapSmplr [[sampler(0)]], sampler shadowMapSmplr [[sampler(1)]], sampler globalShadowMapSmplr [[sampler(2)]], sampler diffuseMapSmplr [[sampler(3)]], sampler skyboxSmplr [[sampler(4)]])
{
    main0_out out = {};
    float3 linearColor = float3(0.0);
    Light arg;
    Light arg_1;
    for (int i = 0; i < _500.numLights; i++)
    {
        if (_500.allLights[i].lightType == 3)
        {
            arg.lightIntensity = _500.allLights[i].lightIntensity;
            arg.lightType = _500.allLights[i].lightType;
            arg.lightCastShadow = _500.allLights[i].lightCastShadow;
            arg.lightShadowMapIndex = _500.allLights[i].lightShadowMapIndex;
            arg.lightAngleAttenCurveType = _500.allLights[i].lightAngleAttenCurveType;
            arg.lightDistAttenCurveType = _500.allLights[i].lightDistAttenCurveType;
            arg.lightSize = _500.allLights[i].lightSize;
            arg.lightGUID = _500.allLights[i].lightGUID;
            arg.lightPosition = _500.allLights[i].lightPosition;
            arg.lightColor = _500.allLights[i].lightColor;
            arg.lightDirection = _500.allLights[i].lightDirection;
            arg.lightDistAttenCurveParams[0] = _500.allLights[i].lightDistAttenCurveParams[0];
            arg.lightDistAttenCurveParams[1] = _500.allLights[i].lightDistAttenCurveParams[1];
            arg.lightAngleAttenCurveParams[0] = _500.allLights[i].lightAngleAttenCurveParams[0];
            arg.lightAngleAttenCurveParams[1] = _500.allLights[i].lightAngleAttenCurveParams[1];
            arg.lightVP = _500.allLights[i].lightVP;
            arg.padding[0] = _500.allLights[i].padding[0];
            arg.padding[1] = _500.allLights[i].padding[1];
            linearColor += apply_areaLight(arg, in.normal, _500, in.v, diffuseMap, diffuseMapSmplr, in.uv, u_pushConstants);
        }
        else
        {
            arg_1.lightIntensity = _500.allLights[i].lightIntensity;
            arg_1.lightType = _500.allLights[i].lightType;
            arg_1.lightCastShadow = _500.allLights[i].lightCastShadow;
            arg_1.lightShadowMapIndex = _500.allLights[i].lightShadowMapIndex;
            arg_1.lightAngleAttenCurveType = _500.allLights[i].lightAngleAttenCurveType;
            arg_1.lightDistAttenCurveType = _500.allLights[i].lightDistAttenCurveType;
            arg_1.lightSize = _500.allLights[i].lightSize;
            arg_1.lightGUID = _500.allLights[i].lightGUID;
            arg_1.lightPosition = _500.allLights[i].lightPosition;
            arg_1.lightColor = _500.allLights[i].lightColor;
            arg_1.lightDirection = _500.allLights[i].lightDirection;
            arg_1.lightDistAttenCurveParams[0] = _500.allLights[i].lightDistAttenCurveParams[0];
            arg_1.lightDistAttenCurveParams[1] = _500.allLights[i].lightDistAttenCurveParams[1];
            arg_1.lightAngleAttenCurveParams[0] = _500.allLights[i].lightAngleAttenCurveParams[0];
            arg_1.lightAngleAttenCurveParams[1] = _500.allLights[i].lightAngleAttenCurveParams[1];
            arg_1.lightVP = _500.allLights[i].lightVP;
            arg_1.padding[0] = _500.allLights[i].padding[0];
            arg_1.padding[1] = _500.allLights[i].padding[1];
            linearColor += apply_light(arg_1, cubeShadowMap, cubeShadowMapSmplr, shadowMap, shadowMapSmplr, globalShadowMap, globalShadowMapSmplr, in.normal, _500, in.v, in.v_world, diffuseMap, diffuseMapSmplr, in.uv, u_pushConstants);
        }
    }
    float4 _1012 = float4(in.normal_world.xyz, 0.0);
    linearColor += (skybox.sample(skyboxSmplr, _1012.xyz, uint(rint(_1012.w)), level(8.0)).xyz * float3(0.20000000298023223876953125));
    float3 param = linearColor;
    linearColor = exposure_tone_mapping(param);
    float3 param_1 = linearColor;
    out.outputColor = float4(gamma_correction(param_1), 1.0);
    return out;
}

