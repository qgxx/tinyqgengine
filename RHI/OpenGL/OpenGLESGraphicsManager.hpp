#pragma once
#include  <GLES3/gl32.h>
#include "OpenGLGraphicsManagerCommonBase.hpp"

namespace qg {
    class OpenGLESGraphicsManager : public OpenGLGraphicsManagerCommonBase
    {
        int Initialize();
    };
}