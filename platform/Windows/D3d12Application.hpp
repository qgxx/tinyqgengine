#pragma once
#include "WindowsApplication.hpp"

namespace qg {
    class D3d12Application : public WindowsApplication 
    {
        public:
            using WindowsApplication::WindowsApplication;
            void Tick();
    };
}