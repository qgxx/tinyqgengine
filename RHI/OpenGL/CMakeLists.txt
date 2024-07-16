add_library(OpenGLRHI 
OpenGLGraphicsManager.cpp 
${PROJECT_SOURCE_DIR}/external/GL/src/glad.c 
)
target_include_directories(OpenGLRHI PRIVATE "${PROJECT_SOURCE_DIR}/external/GL/include")