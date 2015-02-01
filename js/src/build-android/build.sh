#!/bin/sh
 
if [ -z $NDK_ROOT ]; then
    echo "NDK_ROOT MUST BE DEFINED!"
    echo "e.g. export NDK_ROOT=$HOME/android-ndk"
    exit -1  
fi
 
host_kernel=$(uname -s | tr "[:upper:]" "[:lower:]")
host_arch=$(uname -m)
cpus=$(sysctl hw.ncpu | awk '{print $2}')
 
TARGET=arm-linux-androideabi
TARGET_ARCH=armv7-a
GCC_VERSION=4.8
 
TOOLCHAIN=$NDK_ROOT/toolchains/${TARGET}-${GCC_VERSION}/prebuilt/${host_kernel}-${host_arch}
 
###
 
ls | grep -v build.sh | xargs rm -rf
rm -rf .deps
 
../configure --with-android-ndk=$NDK_ROOT \
    --with-android-toolchain=$TOOLCHAIN \
    --with-android-gnu-compiler-version=${GCC_VERSION} \
    --with-arch=${TARGET_ARCH} \
    --target=${TARGET} \
    --enable-android-libstdcxx \
    --disable-shared-js --disable-tests --without-intl-api \
    --disable-debug --disable-debug-symbols --enable-strip --enable-install-strip \
    --disable-threadsafe \
    --enable-exact-rooting --enable-gcgenerational
 
make -j$cpu
