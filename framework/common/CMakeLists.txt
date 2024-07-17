add_library(common
Allocator.cpp
BaseApplication.cpp
GraphicsManager.cpp
MemoryManager.cpp
main.cpp
)
target_link_libraries(common GeomMath)