#!/bin/sh

MIN_IOS_VERSION=5.1.1
IOS_SDK=8.1

LIPO="xcrun -sdk iphoneos lipo"

cpus=$(sysctl hw.ncpu | awk '{print $2}')


### ARM-V7 ###

ls | grep -v build.sh | xargs rm -rf
rm -rf .deps

../configure --with-ios-target=iPhoneOS --with-ios-version=$IOS_SDK --with-ios-min-version=$MIN_IOS_VERSION --with-ios-arch=armv7 \
    --disable-shared-js --disable-tests --without-intl-api --enable-llvm-hacks \
    --disable-threadsafe \
    --disable-root-analysis --disable-exact-rooting --enable-gcincremental \
    --disable-ion --disable-jm --disable-tm --disable-methodjit --disable-monoic --disable-polyic --disable-yarr-jit \
    --enable-optimize=-O3 --with-thumb=yes \
    --disable-debug --disable-debug-symbols --enable-strip --enable-install-strip

make -j$cpus

if (( $? )) ; then
    echo "error when compiling iOS version (armv7) of the library"
    exit -1
fi

mv js/src/libjs_static.a libjs_static.armv7.a


### ARM-64 ###

ls | grep -v libjs_static.armv7.a | grep -v build.sh | xargs rm -rf
rm -rf .deps

../configure --with-ios-target=iPhoneOS --with-ios-version=$IOS_SDK --with-ios-min-version=$MIN_IOS_VERSION --with-ios-arch=arm64 \
    --disable-shared-js --disable-tests --without-intl-api --enable-llvm-hacks \
    --disable-threadsafe \
    --disable-root-analysis --disable-exact-rooting --enable-gcincremental \
    --disable-ion --disable-jm --disable-tm --disable-methodjit --disable-monoic --disable-polyic --disable-yarr-jit \
    --enable-optimize=-O3 --with-thumb=yes \
    --disable-debug --disable-debug-symbols --enable-strip --enable-install-strip

make -j$cpus

if (( $? )) ; then
   echo "error when compiling iOS version (arm64) of the library"
   exit
fi

mv js/src/libjs_static.a libjs_static.arm64.a


### LIPO + INFO ###

$LIPO -create -output libjs_static.a libjs_static.armv7.a libjs_static.arm64.a
$LIPO -info libjs_static.a


### PACKAGING ###

if [ -z $RELEASE_DIR ]; then
    echo "RELEASE_DIR MUST BE DEFINED!"
    echo "e.g. export RELEASE_DIR=../../../blocks/Spidermonkey25"
    exit -1  
fi

rm -rf "$RELEASE_DIR/ios/include"
mkdir -p "$RELEASE_DIR/ios/include"
cp -RL dist/include/* "$RELEASE_DIR/ios/include/"

rm -rf "$RELEASE_DIR/ios/lib"
mkdir -p "$RELEASE_DIR/ios/lib"
cp -L libjs_static.a "$RELEASE_DIR/ios/lib/"
