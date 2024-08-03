#pragma once
#include "IDrawPass.hpp"

namespace qg {
    class TerrainPass : implements IDrawPass
    {
    public:
        ~TerrainPass() = default;
        void Draw(Frame& frame) final;
    };
}