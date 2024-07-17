# Empty
add_subdirectory(empty)
add_subdirectory(OpenGL)
IF(${WIN32})
    # Windows specific code
    add_subdirectory(DirectX2D)
    add_subdirectory(DirectX3D)
ENDIF(${WIN32})