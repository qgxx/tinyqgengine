#pragma once
#include "IRuntimeModule.hpp"
#include "portable.hpp"
#include <memory>

namespace qg {
    ENUM(DefaultShaderIndex)
    {
        ShadowMap = "SHMP"_i32,
        OmniShadowMap = "OSHM"_i32,
        Basic     = "BSIC"_i32,
        Pbr       = " PBR"_i32,
        PbrBrdf   = "BRDF"_i32,
        PbrBrdfPs = "BRPS"_i32,
        Debug     = "DEBG"_i32,
        DepthCopy = "DCPY"_i32,
        DepthCopyCube  = "DCPC"_i32,
        Copy      =  "COPY"_i32,
        CopyCube  =  "COPC"_i32,
        SkyBox    = "SKYB"_i32,
        Terrain   = "TERN"_i32
    };

    Interface IShaderManager : implements IRuntimeModule
    {
    public:
        virtual ~IShaderManager() = default;

        virtual bool InitializeShaders() = 0;
        virtual void ClearShaders() = 0;

        virtual intptr_t GetDefaultShaderProgram(DefaultShaderIndex index) = 0;
    };

    extern IShaderManager* g_pShaderManager;
}