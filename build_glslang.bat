@echo off
git submodule update --init external\src\glslang
python External\src\glslang\update_glslang_sources.py
mkdir External\build\glslang
pushd External\build\glslang
rm -rf *
cmake -DCMAKE_INSTALL_PREFIX=../../Windows/ -DCMAKE_INSTALL_RPATH=../../Windows/ -DCMAKE_BUILD_TYPE=RELEASE ../../src/glslang
cmake --build . --config release --target install
popd
echo "Completed build of glslang"