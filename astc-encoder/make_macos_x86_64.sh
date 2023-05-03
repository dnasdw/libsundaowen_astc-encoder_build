#!/bin/bash

pushd "`dirname "$0"`"
rootdir=`pwd`
tmpdir=/tmp/libsundaowen_astc-encoder
target=macos_x86_64
prefix=$tmpdir/$target
version=astc-encoder_src
rm -rf "$tmpdir/$version"
mkdir -p "$tmpdir/$version"
cp -rf "../$version/"* "$tmpdir/$version"
pushd "$tmpdir/$version"
rm -rf build
mkdir build
cd build
cmake -DBUILD64=ON -C "$rootdir/CMakeLists.txt" -DSHAREDLIB=ON -DCLI=OFF -DBUILD_TESTING=OFF -DCMAKE_INSTALL_PREFIX="$prefix" ..
cmake --build . --target astcenc-native-shared --config Release --clean-first
popd
mkdir -p "../target/include/astc-encoder"
cp -rf "$tmpdir/$version/Source/astcenc.h" "../target/include/astc-encoder"
mkdir -p "../target/lib/$target"
cp -f "$tmpdir/$version/build/Source/"*.dylib "../target/lib/$target"
popd
rm -rf "$tmpdir"
