#pragma once
#include "IDrawPass.hpp"

namespace qg {
    class HUDPass : implements IDrawPass
    {
    public:
        ~HUDPass() = default;
        void Draw(Frame& frame) final;
    };
}