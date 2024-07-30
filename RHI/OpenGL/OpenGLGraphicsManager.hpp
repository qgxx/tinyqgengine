#pragma once
#include "glad/glad.h"
#include "OpenGLGraphicsManagerCommonBase.hpp"

namespace qg {
    class OpenGLGraphicsManager : public OpenGLGraphicsManagerCommonBase
    {
        int Initialize();
    };
}