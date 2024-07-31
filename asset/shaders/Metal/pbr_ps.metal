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

struct PerBatchConstants
{
    float4x4 modelMatrix;
};

constant spvUnsafeArray<float2, 4> _326 = spvUnsafeArray<float2, 4>({ float2(-0.94201624393463134765625, -0.39906215667724609375), float2(0.94558608531951904296875, -0.768907248973846435546875), float2(-0.094184100627899169921875, -0.929388701915740966796875), float2(0.34495937824249267578125, 0.29387760162353515625) });

struct main0_out
{
    float4 outputColor [[color(0)]];
};

struct main0_in
{
    float4 normal_world [[user(locn1)]];
    float4 v_world [[user(locn3)]];
    float2 uv [[user(locn4)]];
};

static inline __attribute__((always_inline))
float3 inverse_gamma_correction(thread const float3& color)
{
    return powr(color, float3(2.2000000476837158203125));
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
                float4 _271 = float4(L, float(light.lightShadowMapIndex));
                near_occ = cubeShadowMap.sample(cubeShadowMapSmplr, _271.xyz, uint(rint(_271.w))).x;
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
                    float3 _341 = float3(v_light_space.xy + (_326[i] / float2(700.0)), float(light.lightShadowMapIndex));
                    near_occ = shadowMap.sample(shadowMapSmplr, _341.xy, uint(rint(_341.z))).x;
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
                    float3 _383 = float3(v_light_space.xy + (_326[i_1] / float2(700.0)), float(light.lightShadowMapIndex));
                    near_occ = globalShadowMap.sample(globalShadowMapSmplr, _383.xy, uint(rint(_383.z))).x;
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
                    float3 _423 = float3(v_light_space.xy + (_326[i_2] / float2(700.0)), float(light.lightShadowMapIndex));
                    near_occ = shadowMap.sample(shadowMapSmplr, _423.xy, uint(rint(_423.z))).x;
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
float DistributionGGX(thread const float3& N, thread const float3& H, thread const float& roughness)
{
    float a = roughness * roughness;
    float a2 = a * a;
    float NdotH = fast::max(dot(N, H), 0.0);
    float NdotH2 = NdotH * NdotH;
    float num = a2;
    float denom = (NdotH2 * (a2 - 1.0)) + 1.0;
    denom = (3.1415927410125732421875 * denom) * denom;
    return num / denom;
}

static inline __attribute__((always_inline))
float GeometrySchlickGGXDirect(thread const float& NdotV, thread const float& roughness)
{
    float r = roughness + 1.0;
    float k = (r * r) / 8.0;
    float num = NdotV;
    float denom = (NdotV * (1.0 - k)) + k;
    return num / denom;
}

static inline __attribute__((always_inline))
float GeometrySmithDirect(thread const float3& N, thread const float3& V, thread const float3& L, thread const float& roughness)
{
    float NdotV = fast::max(dot(N, V), 0.0);
    float NdotL = fast::max(dot(N, L), 0.0);
    float param = NdotV;
    float param_1 = roughness;
    float ggx2 = GeometrySchlickGGXDirect(param, param_1);
    float param_2 = NdotL;
    float param_3 = roughness;
    float ggx1 = GeometrySchlickGGXDirect(param_2, param_3);
    return ggx1 * ggx2;
}

static inline __attribute__((always_inline))
float3 fresnelSchlick(thread const float& cosTheta, thread const float3& F0)
{
    return F0 + ((float3(1.0) - F0) * powr(1.0 - cosTheta, 5.0));
}

static inline __attribute__((always_inline))
float3 fresnelSchlickRoughness(thread const float& cosTheta, thread const float3& F0, thread const float& roughness)
{
    return F0 + ((fast::max(float3(1.0 - roughness), F0) - F0) * powr(1.0 - cosTheta, 5.0));
}

static inline __attribute__((always_inline))
float3 reinhard_tone_mapping(thread const float3& color)
{
    return color / (color + float3(1.0));
}

static inline __attribute__((always_inline))
float3 gamma_correction(thread const float3& color)
{
    return powr(color, float3(0.4545454680919647216796875));
}

fragment main0_out main0(main0_in in [[stage_in]], constant PerFrameConstants& _589 [[buffer(0)]], texturecube_array<float> cubeShadowMap [[texture(0)]], texture2d_array<float> shadowMap [[texture(1)]], texture2d_array<float> globalShadowMap [[texture(2)]], texture2d<float> diffuseMap [[texture(3)]], texture2d<float> metallicMap [[texture(4)]], texture2d<float> roughnessMap [[texture(5)]], texture2d<float> aoMap [[texture(6)]], texturecube_array<float> skybox [[texture(7)]], texture2d<float> brdfLUT [[texture(8)]], sampler cubeShadowMapSmplr [[sampler(0)]], sampler shadowMapSmplr [[sampler(1)]], sampler globalShadowMapSmplr [[sampler(2)]], sampler diffuseMapSmplr [[sampler(3)]], sampler metallicMapSmplr [[sampler(4)]], sampler roughnessMapSmplr [[sampler(5)]], sampler aoMapSmplr [[sampler(6)]], sampler skyboxSmplr [[sampler(7)]], sampler brdfLUTSmplr [[sampler(8)]])
{
    main0_out out = {};
    float3 N = fast::normalize(in.normal_world.xyz);
    float3 V = fast::normalize(_589.camPos.xyz - in.v_world.xyz);
    float3 R = reflect(-V, N);
    float3 param = diffuseMap.sample(diffuseMapSmplr, in.uv).xyz;
    float3 albedo = inverse_gamma_correction(param);
    float meta = metallicMap.sample(metallicMapSmplr, in.uv).x;
    float rough = roughnessMap.sample(roughnessMapSmplr, in.uv).x;
    float3 F0 = float3(0.039999999105930328369140625);
    F0 = mix(F0, albedo, float3(meta));
    float3 Lo = float3(0.0);
    Light light;
    for (int i = 0; i < _589.numLights; i++)
    {
        light.lightIntensity = _589.allLights[i].lightIntensity;
        light.lightType = _589.allLights[i].lightType;
        light.lightCastShadow = _589.allLights[i].lightCastShadow;
        light.lightShadowMapIndex = _589.allLights[i].lightShadowMapIndex;
        light.lightAngleAttenCurveType = _589.allLights[i].lightAngleAttenCurveType;
        light.lightDistAttenCurveType = _589.allLights[i].lightDistAttenCurveType;
        light.lightSize = _589.allLights[i].lightSize;
        light.lightGUID = _589.allLights[i].lightGUID;
        light.lightPosition = _589.allLights[i].lightPosition;
        light.lightColor = _589.allLights[i].lightColor;
        light.lightDirection = _589.allLights[i].lightDirection;
        light.lightDistAttenCurveParams[0] = _589.allLights[i].lightDistAttenCurveParams[0];
        light.lightDistAttenCurveParams[1] = _589.allLights[i].lightDistAttenCurveParams[1];
        light.lightAngleAttenCurveParams[0] = _589.allLights[i].lightAngleAttenCurveParams[0];
        light.lightAngleAttenCurveParams[1] = _589.allLights[i].lightAngleAttenCurveParams[1];
        light.lightVP = _589.allLights[i].lightVP;
        light.padding[0] = _589.allLights[i].padding[0];
        light.padding[1] = _589.allLights[i].padding[1];
        float3 L = fast::normalize(light.lightPosition.xyz - in.v_world.xyz);
        float3 H = fast::normalize(V + L);
        float NdotL = fast::max(dot(N, L), 0.0);
        float visibility = shadow_test(in.v_world, light, NdotL, cubeShadowMap, cubeShadowMapSmplr, shadowMap, shadowMapSmplr, globalShadowMap, globalShadowMapSmplr);
        float lightToSurfDist = length(L);
        float lightToSurfAngle = acos(dot(-L, light.lightDirection.xyz));
        float param_1 = lightToSurfAngle;
        int param_2 = light.lightAngleAttenCurveType;
        spvUnsafeArray<float4, 2> param_3 = light.lightAngleAttenCurveParams;
        float atten = apply_atten_curve(param_1, param_2, param_3);
        float param_4 = lightToSurfDist;
        int param_5 = light.lightDistAttenCurveType;
        spvUnsafeArray<float4, 2> param_6 = light.lightDistAttenCurveParams;
        atten *= apply_atten_curve(param_4, param_5, param_6);
        float3 radiance = light.lightColor.xyz * (light.lightIntensity * atten);
        float3 param_7 = N;
        float3 param_8 = H;
        float param_9 = rough;
        float NDF = DistributionGGX(param_7, param_8, param_9);
        float3 param_10 = N;
        float3 param_11 = V;
        float3 param_12 = L;
        float param_13 = rough;
        float G = GeometrySmithDirect(param_10, param_11, param_12, param_13);
        float param_14 = fast::max(dot(H, V), 0.0);
        float3 param_15 = F0;
        float3 F = fresnelSchlick(param_14, param_15);
        float3 kS = F;
        float3 kD = float3(1.0) - kS;
        kD *= (1.0 - meta);
        float3 numerator = F * (NDF * G);
        float denominator = (4.0 * fast::max(dot(N, V), 0.0)) * NdotL;
        float3 specular = numerator / float3(fast::max(denominator, 0.001000000047497451305389404296875));
        Lo += ((((((kD * albedo) / float3(3.1415927410125732421875)) + specular) * radiance) * NdotL) * visibility);
    }
    float ambientOcc = aoMap.sample(aoMapSmplr, in.uv).x;
    float param_16 = fast::max(dot(N, V), 0.0);
    float3 param_17 = F0;
    float param_18 = rough;
    float3 F_1 = fresnelSchlickRoughness(param_16, param_17, param_18);
    float3 kS_1 = F_1;
    float3 kD_1 = float3(1.0) - kS_1;
    kD_1 *= (1.0 - meta);
    float4 _882 = float4(N, 0.0);
    float3 irradiance = skybox.sample(skyboxSmplr, _882.xyz, uint(rint(_882.w)), level(1.0)).xyz;
    float3 diffuse = irradiance * albedo;
    float4 _895 = float4(R, 1.0);
    float3 prefilteredColor = skybox.sample(skyboxSmplr, _895.xyz, uint(rint(_895.w)), level(rough * 8.0)).xyz;
    float2 envBRDF = brdfLUT.sample(brdfLUTSmplr, float2(fast::max(dot(N, V), 0.0), rough)).xy;
    float3 specular_1 = prefilteredColor * ((F_1 * envBRDF.x) + float3(envBRDF.y));
    float3 ambient = ((kD_1 * diffuse) + specular_1) * ambientOcc;
    float3 linearColor = ambient + Lo;
    float3 param_19 = linearColor;
    linearColor = reinhard_tone_mapping(param_19);
    float3 param_20 = linearColor;
    linearColor = gamma_correction(param_20);
    out.outputColor = float4(linearColor, 1.0);
    return out;
}

