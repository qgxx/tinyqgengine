#pragma once
#include "IDrawPass.hpp"

namespace qg {
    class SkyBoxPass : implements IDrawPass
    {
    public:
        ~SkyBoxPass() = default;
        void Draw(Frame& frame) final;
    };
}