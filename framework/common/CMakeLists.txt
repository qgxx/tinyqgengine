add_library(common 
Allocator.cpp 
MemoryManager.cpp 
BaseApplication.cpp 
GraphicsManager.cpp 
main.cpp
)
target_link_libraries(common GeomMath)