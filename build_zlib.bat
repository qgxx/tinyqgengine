@echo off
git submodule update --init external\src\zlib
mkdir external\build\zlib
pushd external\build\zlib
rm -rf *
cmake -DCMAKE_INSTALL_PREFIX=..\..\ -G "Visual Studio 17 2022" -Thost=x64 ..\..\src\zlib
cmake --build . --config release --target install
popd
copy external\build\zlib\Release\zlib.lib external\Windows\lib