#pragma once
#include "GraphicsManager.hpp"

namespace qg {
    class OpenGLGraphicsManager : public GraphicsManager
    {
    public:
        virtual int Initialize();
        virtual void Finalize();

        virtual void Tick();
    private:
    };
}
