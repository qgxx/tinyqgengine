mkdir build\Debug 
cd .\build\Debug\ 
cmake -G "Unix Makefiles" -DCMAKE_BUILD_TYPE=Debug ..\.. %generate Makefiles% 
cmake --build . --config Debug --clean-first %compile% 
.\framework\GeomMath\test\GeomMathTest.exe 