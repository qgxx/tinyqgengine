@echo off
git submodule update --init external\src\opengex
mkdir external\build\opengex
pushd external\build\opengex
rm -rf *
cmake -DCMAKE_INSTALL_PREFIX=..\..\Windows -G "Visual Studio 17 2022" -Thost=x64 ..\..\src\opengex
cmake --build . --config debug
popd
copy external\build\opengex\OpenDDL\Debug\OpenDDL.lib external\Windows\lib
copy external\build\opengex\OpenGEX\Debug\OpenGEX.lib external\Windows\lib