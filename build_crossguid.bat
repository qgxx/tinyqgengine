@echo off
git submodule update --init external\src\crossguid
mkdir external\build\crossguid
pushd external\build\crossguid
rm -rf *
cmake -DCMAKE_INSTALL_PREFIX=..\..\Windows -G "Visual Studio 17 2022" -Thost=x64 ..\..\src\crossguid
cmake --build . --config debug
popd
copy external\build\crossguid\Debug\xg.lib external\Windows\lib