#!/bin/sh

echo Building shaders...
xcrun -sdk macosx metal -c Triangle.metal -o Triangle.air
xcrun -sdk macosx metallib Triangle.air -o Triangle.metallib

echo Compiling and linking...
clang++ *.mm \
   -x objective-c++ \
   -std=c++17 \
   -framework Metal \
   -framework MetalKit \
   -framework Cocoa
