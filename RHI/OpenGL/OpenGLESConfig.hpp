#pragma once
#include "OpenGL/OpenGLESGraphicsManager.hpp"
#include "OpenGL/OpenGLESShaderManager.hpp"

namespace qg {
    GraphicsManager* g_pGraphicsManager = static_cast<GraphicsManager*>(new OpenGLESGraphicsManager);
    IShaderManager*  g_pShaderManager   = static_cast<IShaderManager*>(new OpenGLESShaderManager);
}