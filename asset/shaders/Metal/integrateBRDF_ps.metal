#pragma clang diagnostic ignored "-Wmissing-prototypes"

#include <metal_stdlib>
#include <simd/simd.h>

using namespace metal;

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
    Light allLights[100];
};

struct PerBatchConstants
{
    float4x4 modelMatrix;
};

struct main0_out
{
    float2 FragColor [[color(0)]];
};

struct main0_in
{
    float2 UV [[user(locn0)]];
};

static inline __attribute__((always_inline))
float RadicalInverse_VdC(thread uint& bits)
{
    bits = (bits << 16u) | (bits >> 16u);
    bits = ((bits & 1431655765u) << 1u) | ((bits & 2863311530u) >> 1u);
    bits = ((bits & 858993459u) << 2u) | ((bits & 3435973836u) >> 2u);
    bits = ((bits & 252645135u) << 4u) | ((bits & 4042322160u) >> 4u);
    bits = ((bits & 16711935u) << 8u) | ((bits & 4278255360u) >> 8u);
    return float(bits) * 2.3283064365386962890625e-10;
}

static inline __attribute__((always_inline))
float2 Hammersley(thread const uint& i, thread const uint& N)
{
    uint param = i;
    float _156 = RadicalInverse_VdC(param);
    return float2(float(i) / float(N), _156);
}

static inline __attribute__((always_inline))
float3 ImportanceSampleGGX(thread const float2& Xi, thread const float3& N, thread const float& roughness)
{
    float a = roughness * roughness;
    float phi = 6.283185482025146484375 * Xi.x;
    float cosTheta = sqrt((1.0 - Xi.y) / (1.0 + (((a * a) - 1.0) * Xi.y)));
    float sinTheta = sqrt(1.0 - (cosTheta * cosTheta));
    float3 H;
    H.x = cos(phi) * sinTheta;
    H.y = sin(phi) * sinTheta;
    H.z = cosTheta;
    float3 up = select(float3(1.0, 0.0, 0.0), float3(0.0, 0.0, 1.0), bool3(abs(N.z) < 0.999000012874603271484375));
    float3 tangent = fast::normalize(cross(up, N));
    float3 bitangent = cross(N, tangent);
    float3 sampleVec = ((tangent * H.x) + (bitangent * H.y)) + (N * H.z);
    return fast::normalize(sampleVec);
}

static inline __attribute__((always_inline))
float GeometrySchlickGGXIndirect(thread const float& NdotV, thread const float& roughness)
{
    float a = roughness;
    float k = (a * a) / 2.0;
    float nom = NdotV;
    float denom = (NdotV * (1.0 - k)) + k;
    return nom / denom;
}

static inline __attribute__((always_inline))
float GeometrySmithIndirect(thread const float3& N, thread const float3& V, thread const float3& L, thread const float& roughness)
{
    float NdotV = fast::max(dot(N, V), 0.0);
    float NdotL = fast::max(dot(N, L), 0.0);
    float param = NdotV;
    float param_1 = roughness;
    float ggx2 = GeometrySchlickGGXIndirect(param, param_1);
    float param_2 = NdotL;
    float param_3 = roughness;
    float ggx1 = GeometrySchlickGGXIndirect(param_2, param_3);
    return ggx1 * ggx2;
}

static inline __attribute__((always_inline))
float2 IntegrateBRDF(thread const float& NdotV, thread const float& roughness)
{
    float3 V;
    V.x = sqrt(1.0 - (NdotV * NdotV));
    V.y = 0.0;
    V.z = NdotV;
    float A = 0.0;
    float B = 0.0;
    float3 N = float3(0.0, 0.0, 1.0);
    for (uint i = 0u; i < 1024u; i++)
    {
        uint param = i;
        uint param_1 = 1024u;
        float2 Xi = Hammersley(param, param_1);
        float2 param_2 = Xi;
        float3 param_3 = N;
        float param_4 = roughness;
        float3 H = ImportanceSampleGGX(param_2, param_3, param_4);
        float3 L = fast::normalize((H * (2.0 * dot(V, H))) - V);
        float NdotL = fast::max(L.z, 0.0);
        float NdotH = fast::max(H.z, 0.0);
        float VdotH = fast::max(dot(V, H), 0.0);
        if (NdotL > 0.0)
        {
            float3 param_5 = N;
            float3 param_6 = V;
            float3 param_7 = L;
            float param_8 = roughness;
            float G = GeometrySmithIndirect(param_5, param_6, param_7, param_8);
            float G_Vis = (G * VdotH) / (NdotH * NdotV);
            float Fc = powr(1.0 - VdotH, 5.0);
            A += ((1.0 - Fc) * G_Vis);
            B += (Fc * G_Vis);
        }
    }
    A /= 1024.0;
    B /= 1024.0;
    return float2(A, B);
}

fragment main0_out main0(main0_in in [[stage_in]])
{
    main0_out out = {};
    float param = in.UV.x;
    float param_1 = in.UV.y;
    float2 integratedBRDF = IntegrateBRDF(param, param_1);
    out.FragColor = integratedBRDF;
    return out;
}

