#pragma once
#include <iostream>
#include "Interface.hpp"
#include "FrameStructure.hpp"

namespace qg {
    Interface IDrawPass
    {
    public:
        IDrawPass() = default;
        virtual ~IDrawPass() {};

        virtual void Draw(Frame& frame) = 0;
    };
}