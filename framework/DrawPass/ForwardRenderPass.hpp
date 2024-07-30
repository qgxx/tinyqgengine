#pragma once
#include "IDrawPass.hpp"

namespace qg {
    class ForwardRenderPass : implements IDrawPass
    {
    public:
        ~ForwardRenderPass() = default;
        void Draw(Frame& frame) final;
    };
}