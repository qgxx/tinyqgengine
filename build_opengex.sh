#!/bin/bash
git submodule update --init external/src/opengex
mkdir -p external/build/opengex
cd external/build/opengex
cmake -DCMAKE_INSTALL_PREFIX=../../Linux ../../src/opengex
cmake --build . --config release --target install