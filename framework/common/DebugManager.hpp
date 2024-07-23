#pragma once
#ifdef DEBUG
#include "IRuntimeModule.hpp"

namespace qg {
    class DebugManager : implements IRuntimeModule
    {
    public:
        int Initialize();
        void Finalize();
        void Tick();

        void ToggleDebugInfo();

        void DrawDebugInfo();

    protected:
        void DrawAxis();
        void DrawGrid();

        bool m_bDrawDebugInfo = false;
    };

    extern DebugManager* g_pDebugManager;
}

#endif