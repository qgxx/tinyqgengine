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

constant spvUnsafeArray<float2, 4> _332 = spvUnsafeArray<float2, 4>({ float2(-0.94201624393463134765625, -0.39906215667724609375), float2(0.94558608531951904296875, -0.768907248973846435546875), float2(-0.094184100627899169921875, -0.929388701915740966796875), float2(0.34495937824249267578125, 0.29387760162353515625) });

struct main0_out
{
    float4 outputColor [[color(0)]];
};

struct main0_in
{
    float4 v_world [[user(locn3)]];
    float2 uv [[user(locn4)]];
    float3 TBN_0 [[user(locn5)]];
    float3 TBN_1 [[user(locn6)]];
    float3 TBN_2 [[user(locn7)]];
    float3 v_tangent [[user(locn8)]];
    float3 camPos_tangent [[user(locn9)]];
};

static inline __attribute__((always_inline))
float2 ParallaxMapping(thread const float2& texCoords, thread const float3& viewDir, texture2d<float> heightMap, sampler heightMapSmplr)
{
    float numLayers = mix(32.0, 8.0, abs(dot(float3(0.0, 0.0, 1.0), viewDir)));
    float layerDepth = 1.0 / numLayers;
    float currentLayerDepth = 0.0;
    float2 currentTexCoords = texCoords;
    float currentDepthMapValue = 1.0 - heightMap.sample(heightMapSmplr, currentTexCoords).x;
    float2 P = viewDir.xy * 0.100000001490116119384765625;
    float2 deltaTexCoords = P / float2(numLayers);
    while (currentLayerDepth < currentDepthMapValue)
    {
        currentTexCoords -= deltaTexCoords;
        currentDepthMapValue = 1.0 - heightMap.sample(heightMapSmplr, currentTexCoords).x;
        currentLayerDepth += layerDepth;
    }
    float2 prevTexCoords = currentTexCoords + deltaTexCoords;
    float afterDepth = currentDepthMapValue - currentLayerDepth;
    float beforeDepth = ((1.0 - heightMap.sample(heightMapSmplr, prevTexCoords).x) - currentLayerDepth) + layerDepth;
    float weight = afterDepth / (afterDepth - beforeDepth);
    float2 finalTexCoords = (prevTexCoords * weight) + (currentTexCoords * (1.0 - weight));
    return finalTexCoords;
}

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
                float4 _277 = float4(L, float(light.lightShadowMapIndex));
                near_occ = cubeShadowMap.sample(cubeShadowMapSmplr, _277.xyz, uint(rint(_277.w))).x;
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
                    float3 _346 = float3(v_light_space.xy + (_332[i] / float2(700.0)), float(light.lightShadowMapIndex));
                    near_occ = shadowMap.sample(shadowMapSmplr, _346.xy, uint(rint(_346.z))).x;
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
                    float3 _388 = float3(v_light_space.xy + (_332[i_1] / float2(700.0)), float(light.lightShadowMapIndex));
                    near_occ = globalShadowMap.sample(globalShadowMapSmplr, _388.xy, uint(rint(_388.z))).x;
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
                    float3 _428 = float3(v_light_space.xy + (_332[i_2] / float2(700.0)), float(light.lightShadowMapIndex));
                    near_occ = shadowMap.sample(shadowMapSmplr, _428.xy, uint(rint(_428.z))).x;
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

fragment main0_out main0(main0_in in [[stage_in]], constant PerFrameConstants& _710 [[buffer(0)]], texturecube_array<float> cubeShadowMap [[texture(0)]], texture2d_array<float> shadowMap [[texture(1)]], texture2d_array<float> globalShadowMap [[texture(2)]], texture2d<float> heightMap [[texture(3)]], texture2d<float> normalMap [[texture(4)]], texture2d<float> diffuseMap [[texture(5)]], texture2d<float> metallicMap [[texture(6)]], texture2d<float> roughnessMap [[texture(7)]], texture2d<float> aoMap [[texture(8)]], texturecube_array<float> skybox [[texture(9)]], texture2d<float> brdfLUT [[texture(10)]], sampler cubeShadowMapSmplr [[sampler(0)]], sampler shadowMapSmplr [[sampler(1)]], sampler globalShadowMapSmplr [[sampler(2)]], sampler heightMapSmplr [[sampler(3)]], sampler normalMapSmplr [[sampler(4)]], sampler diffuseMapSmplr [[sampler(5)]], sampler metallicMapSmplr [[sampler(6)]], sampler roughnessMapSmplr [[sampler(7)]], sampler aoMapSmplr [[sampler(8)]], sampler skyboxSmplr [[sampler(9)]], sampler brdfLUTSmplr [[sampler(10)]])
{
    main0_out out = {};
    float3x3 TBN = {};
    TBN[0] = in.TBN_0;
    TBN[1] = in.TBN_1;
    TBN[2] = in.TBN_2;
    float3 viewDir = fast::normalize(in.camPos_tangent - in.v_tangent);
    float2 param = in.uv;
    float3 param_1 = viewDir;
    float2 texCoords = ParallaxMapping(param, param_1, heightMap, heightMapSmplr);
    float3 tangent_normal = normalMap.sample(normalMapSmplr, texCoords).xyz;
    tangent_normal = (tangent_normal * 2.0) - float3(1.0);
    float3 N = fast::normalize(TBN * tangent_normal);
    float3 V = fast::normalize(_710.camPos.xyz - in.v_world.xyz);
    float3 R = reflect(-V, N);
    float3 param_2 = diffuseMap.sample(diffuseMapSmplr, texCoords).xyz;
    float3 albedo = inverse_gamma_correction(param_2);
    float meta = metallicMap.sample(metallicMapSmplr, texCoords).x;
    float rough = roughnessMap.sample(roughnessMapSmplr, texCoords).x;
    float3 F0 = float3(0.039999999105930328369140625);
    F0 = mix(F0, albedo, float3(meta));
    float3 Lo = float3(0.0);
    Light light;
    for (int i = 0; i < _710.numLights; i++)
    {
        light.lightIntensity = _710.allLights[i].lightIntensity;
        light.lightType = _710.allLights[i].lightType;
        light.lightCastShadow = _710.allLights[i].lightCastShadow;
        light.lightShadowMapIndex = _710.allLights[i].lightShadowMapIndex;
        light.lightAngleAttenCurveType = _710.allLights[i].lightAngleAttenCurveType;
        light.lightDistAttenCurveType = _710.allLights[i].lightDistAttenCurveType;
        light.lightSize = _710.allLights[i].lightSize;
        light.lightGUID = _710.allLights[i].lightGUID;
        light.lightPosition = _710.allLights[i].lightPosition;
        light.lightColor = _710.allLights[i].lightColor;
        light.lightDirection = _710.allLights[i].lightDirection;
        light.lightDistAttenCurveParams[0] = _710.allLights[i].lightDistAttenCurveParams[0];
        light.lightDistAttenCurveParams[1] = _710.allLights[i].lightDistAttenCurveParams[1];
        light.lightAngleAttenCurveParams[0] = _710.allLights[i].lightAngleAttenCurveParams[0];
        light.lightAngleAttenCurveParams[1] = _710.allLights[i].lightAngleAttenCurveParams[1];
        light.lightVP = _710.allLights[i].lightVP;
        light.padding[0] = _710.allLights[i].padding[0];
        light.padding[1] = _710.allLights[i].padding[1];
        float3 L = fast::normalize(light.lightPosition.xyz - in.v_world.xyz);
        float3 H = fast::normalize(V + L);
        float NdotL = fast::max(dot(N, L), 0.0);
        float visibility = shadow_test(in.v_world, light, NdotL, cubeShadowMap, cubeShadowMapSmplr, shadowMap, shadowMapSmplr, globalShadowMap, globalShadowMapSmplr);
        float lightToSurfDist = length(L);
        float lightToSurfAngle = acos(dot(-L, light.lightDirection.xyz));
        float param_3 = lightToSurfAngle;
        int param_4 = light.lightAngleAttenCurveType;
        spvUnsafeArray<float4, 2> param_5 = light.lightAngleAttenCurveParams;
        float atten = apply_atten_curve(param_3, param_4, param_5);
        float param_6 = lightToSurfDist;
        int param_7 = light.lightDistAttenCurveType;
        spvUnsafeArray<float4, 2> param_8 = light.lightDistAttenCurveParams;
        atten *= apply_atten_curve(param_6, param_7, param_8);
        float3 radiance = light.lightColor.xyz * (light.lightIntensity * atten);
        float3 param_9 = N;
        float3 param_10 = H;
        float param_11 = rough;
        float NDF = DistributionGGX(param_9, param_10, param_11);
        float3 param_12 = N;
        float3 param_13 = V;
        float3 param_14 = L;
        float param_15 = rough;
        float G = GeometrySmithDirect(param_12, param_13, param_14, param_15);
        float param_16 = fast::max(dot(H, V), 0.0);
        float3 param_17 = F0;
        float3 F = fresnelSchlick(param_16, param_17);
        float3 kS = F;
        float3 kD = float3(1.0) - kS;
        kD *= (1.0 - meta);
        float3 numerator = F * (NDF * G);
        float denominator = (4.0 * fast::max(dot(N, V), 0.0)) * NdotL;
        float3 specular = numerator / float3(fast::max(denominator, 0.001000000047497451305389404296875));
        Lo += ((((((kD * albedo) / float3(3.1415927410125732421875)) + specular) * radiance) * NdotL) * visibility);
    }
    float ambientOcc = aoMap.sample(aoMapSmplr, texCoords).x;
    float param_18 = fast::max(dot(N, V), 0.0);
    float3 param_19 = F0;
    float param_20 = rough;
    float3 F_1 = fresnelSchlickRoughness(param_18, param_19, param_20);
    float3 kS_1 = F_1;
    float3 kD_1 = float3(1.0) - kS_1;
    kD_1 *= (1.0 - meta);
    float4 _999 = float4(N, 0.0);
    float3 irradiance = skybox.sample(skyboxSmplr, _999.xyz, uint(rint(_999.w)), level(1.0)).xyz;
    float3 diffuse = irradiance * albedo;
    float4 _1012 = float4(R, 1.0);
    float3 prefilteredColor = skybox.sample(skyboxSmplr, _1012.xyz, uint(rint(_1012.w)), level(rough * 9.0)).xyz;
    float2 envBRDF = brdfLUT.sample(brdfLUTSmplr, float2(fast::max(dot(N, V), 0.0), rough)).xy;
    float3 specular_1 = prefilteredColor * ((F_1 * envBRDF.x) + float3(envBRDF.y));
    float3 ambient = ((kD_1 * diffuse) + specular_1) * ambientOcc;
    float3 linearColor = ambient + Lo;
    float3 param_21 = linearColor;
    linearColor = reinhard_tone_mapping(param_21);
    float3 param_22 = linearColor;
    linearColor = gamma_correction(param_22);
    out.outputColor = float4(linearColor, 1.0);
    return out;
}

