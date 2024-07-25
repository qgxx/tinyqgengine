@echo off
git submodule update --init External\src\zlib
mkdir External\build\zlib
pushd External\build\zlib
rm -rf *
cmake -DCMAKE_INSTALL_PREFIX=../../ -G "Visual Studio 17 2022" -DBUILD_SHARED_LIBS=off -Thost=x64 ../../src/zlib
cmake --build . --config release --target install
popd
