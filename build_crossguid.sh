#!/bin/bash
git submodule update --init external/src/crossguid
mkdir -p external/build/crossguid
cd external/build/crossguid
cmake -DCMAKE_INSTALL_PREFIX=../../Linux -DXG_TESTS=OFF ../../src/crossguid
cmake --build . --config release --target install