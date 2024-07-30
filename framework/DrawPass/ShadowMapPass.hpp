#pragma once
#include "IDrawPass.hpp"

namespace qg {
    class ShadowMapPass: implements IDrawPass
    {
    public:
        ~ShadowMapPass() = default;
        void Draw(Frame& frame) final;
    };
}