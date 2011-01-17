#!/bin/sh

# Defines to set up environment
export DEVROOT=${ROOTDIR}/Platforms/${PLATFORM}.platform/Developer
export SDKROOT=${DEVROOT}/SDKs/${PLATFORM}${MAX_VERSION}.sdk
export CC=$DEVROOT/usr/bin/gcc
export LD=$DEVROOT/usr/bin/ld
export CPP=$DEVROOT/usr/bin/cpp
export CXX=$DEVROOT/usr/bin/g++
export AR=$DEVROOT/usr/bin/ar
export LIBTOOL=$DEVROOT/usr/bin/libtool
export AS=$DEVROOT/usr/bin/as
export NM=$DEVROOT/usr/bin/nm
export CXXCPP=$DEVROOT/usr/bin/cpp
export RANLIB=$DEVROOT/usr/bin/ranlib
export OPTFLAG="-O${OPT}"
export COMMONFLAGS="${ARCH} -pipe $OPTFLAG -gdwarf-2 -no-cpp-precomp -mthumb -isysroot ${SDKROOT} -miphoneos-version-min=${MIN_VERSION}"
export LDFLAGS="${COMMONFLAGS} -L${HOME}${SDKROOT}/usr/lib"
export CFLAGS="${COMMONFLAGS} -fvisibility=hidden"
export CXXFLAGS="${COMMONFLAGS} -fvisibility=hidden -fvisibility-inlines-hidden"

