#!/bin/sh

cpus=$(sysctl hw.ncpu | awk '{print $2}')
 
ls | grep -v build.sh | xargs rm -rf
rm -rf .deps

../configure --disable-tests --disable-shared-js --enable-llvm-hacks \
    --without-intl-api \
    --disable-threadsafe \
    --enable-exact-rooting --enable-gcgenerational \
    --enable-gczeal --enable-root-analysis \
    --enable-debug --enable-debug-symbols \
 
xcrun make -j$cpus

xcrun lipo -info dist/lib/libjs_static.a
