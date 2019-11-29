#!/usr/bin/env bash
# set -e

ARCH="x86_64"
BUILD_DIR=_build/$ARCH

rm -rf $BUILD_DIR

mkdir -p $BUILD_DIR && cd $_
cmake -DCMAKE_EXPORT_COMPILE_COMMANDS=1 ../../
make

