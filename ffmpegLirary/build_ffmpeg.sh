#!/bin/bash

FFMPEG_PATH=/Users/luojie/studySpace
NDK_PATH=/Users/luojie/Library/Android/sdk/ndk-bundle
PREFIX_PATH=/Users/luojie/workspace/FFmpegbuild

#lame静态库的位置
LAMEDIR=`pwd`/lame
SHINE=`pwd`/shine
echo "local: ${LAMEDIR}"

HOST_PLATFORM="darwin-x86_64"
TOOLCHAIN_PREFIX="${NDK_PATH}/toolchains/llvm/prebuilt/${HOST_PLATFORM}/bin"
GCC_PREFIX="${NDK_PATH}/toolchains/llvm/prebuilt/${HOST_PLATFORM}/lib/gcc"

OPTIMIZE_CFLAGS="-marm -Wno-multichar -fno-exceptions"

COMMON_MERGE_OPTIONS="
    libavcodec/libavcodec.a
    libavfilter/libavfilter.a
    libavformat/libavformat.a
    libavutil/libavutil.a
    libswresample/libswresample.a
    libswscale/libswscale.a
    -lc -lm -lz -ldl -llog --dynamic-linker=/system/bin/linker
"

COMMON_OPTIONS="
    --target-os=android
    --enable-neon
    --enable-hwaccels
    --enable-static
    --disable-shared
    --disable-doc
    --enable-asm
    --enable-small
    --disable-ffmpeg
    --disable-ffplay
    --disable-ffprobe
    --disable-debug
    --disable-everything
    --disable-gpl
    --disable-avdevice
    --disable-indevs
    --disable-outdevs
    --disable-avresample
    --enable-avcodec
    --enable-avformat
    --enable-avutil
    --enable-swresample
    --enable-swscale
    --enable-avfilter
    --disable-network
    --enable-bsfs
    --enable-filters
    --enable-encoders
    --enable-libmp3lame
    --enable-encoder=libmp3lame
    --disable-decoders
    --enable-decoder=mp3,mp3float,mp3,mp3_at,mp3adufloat,mp3adu,mp3on4float,mp3on4,aac_fixed,aac_at,aac_latm,aac,m4a
    --enable-muxers
    --enable-parsers
    --enable-protocols
    --disable-demuxers
    --enable-demuxer=matroska,concat,rtsp,mp3,ogg,wav,aac,mov,mp4,m4a,3gp,3g2,mj
"

# git clone git://source.ffmpeg.org/ffmpeg ffmpeg
cd "${FFMPEG_PATH}/ffmpeg"
#git checkout release/4.2


function buildTask() {
    ./configure \
    --prefix=$PREFIX \
    --arch=ARCH \
    --cpu=CPU \
    --cross-prefix="${TOOLCHAIN_PREFIX}/${ANDROID_ABI}-" \
    --nm="${TOOLCHAIN_PREFIX}/${ANDROID_ABI}-nm" \
    --cc="${CC}" \
    --extra-ldexeflags=-pie \
    --extra-ldflags="${EXTRA_LDFLAGS}" \
    --extra-cflags="${EXTRA_CFLAGS}" \
    ${COMMON_OPTIONS}

  [ $? -eq 0 ]  || exit 1
  make -j8
  make install

# 打包成一个 so
  ${TOOLCHAIN_PREFIX}/${ANDROID_ABI}-ld \
    -rpath-link=$SYSROOT/usr/lib \
    -L$SYSROOT/usr/lib \
    -L$PREFIX/lib \
    -soname libffmpeg.so -shared -nostdlib -Bsymbolic --whole-archive --no-undefined -o \
    $PREFIX/libffmpeg.so \
    "${LAMED_LIB}" \
    ${COMMON_MERGE_OPTIONS} \
    ${GCC_PREFIX}/${ANDROID_ABI}/4.9.x/libgcc_real.a
  ${TOOLCHAIN_PREFIX}/${ANDROID_ABI}-strip  $PREFIX/libffmpeg.so
  make clean
}

function buildArm64() {
  ARCH="aarch64"
  ABI="arm64-v8a"
  CPU="armv8-a"
  SYSROOT="${NDK_PATH}/platforms/android-26/arch-arm64"
  PREFIX="${PREFIX_PATH}/android-libs/${ABI}"
  ANDROID_ABI="aarch64-linux-android"

  EXTRA_LDFLAGS="-L$LAMEDIR/obj/local/arm64-v8a"
  EXTRA_CFLAGS="-fPIC -I${NDK_PATH}/sysroot/usr/include -I$LAMEDIR/include"
  CC="${TOOLCHAIN_PREFIX}/aarch64-linux-android26-clang"
  LAMED_LIB="${LAMEDIR}/obj/local/${ABI}/libmp3lame.a"
  buildTask
}

function buildArmeV7() {
  ARCH="arm"
  ABI="armeabi-v7a"
  CPU="armv7-a"
  SYSROOT="${NDK_PATH}/platforms/android-26/arch-arm"
  PREFIX="${PREFIX_PATH}/android-libs/${ABI}"
  ANDROID_ABI="arm-linux-androideabi"

  EXTRA_LDFLAGS="-Wl,--fix-cortex-a8 -L$LAMEDIR/obj/local/${ABI}"
  EXTRA_CFLAGS="-march=armv7-a -mfloat-abi=softfp -fPIC -I${NDK_PATH}/sysroot/usr/include -I$LAMEDIR/include"
  CC="${TOOLCHAIN_PREFIX}/armv7a-linux-androideabi26-clang"
  LAMED_LIB="${LAMEDIR}/obj/local/${ABI}/libmp3lame.a"
  buildTask
}

function buildx86() {
  ARCH="x86"
  ABI="x86"
  CPU="i686"
  # 修改成 26 ？
  SYSROOT="${NDK_PATH}/platforms/android-26/arch-x86"
  PREFIX="${PREFIX_PATH}/android-libs/${ABI}"
  ANDROID_ABI="i686-linux-android"

  EXTRA_LDFLAGS="-L$LAMEDIR/obj/local/${ABI}"
  EXTRA_CFLAGS="-I${NDK_PATH}/sysroot/usr/include -I$LAMEDIR/include"
  CC="${TOOLCHAIN_PREFIX}/i686-linux-android26-clang"
  LAMED_LIB="${LAMEDIR}/obj/local/${ABI}/libmp3lame.a"
  COMMON_OPTIONS="${COMMON_OPTIONS} --disable-asm"

  buildTask
}

function buildX86_64() {
  ARCH="x86_64"
  ABI="x86_64"
  CPU="i386"
  SYSROOT="${NDK_PATH}/platforms/android-29/arch-x86_64"
  PREFIX="${PREFIX_PATH}/android-libs/${ABI}"
  ANDROID_ABI="x86_64-linux-android"

  EXTRA_LDFLAGS="-L$LAMEDIR/obj/local/${ABI} "
  EXTRA_CFLAGS="-I${NDK_PATH}/sysroot/usr/include -I$LAMEDIR/include"
  CC="${TOOLCHAIN_PREFIX}/x86_64-linux-android29-clang"
  LAMED_LIB="${LAMEDIR}/obj/local/${ABI}/libmp3lame.a"
#  COMMON_OPTIONS="${COMMON_OPTIONS} --disable-asm"
  OPTIMIZE_CFLAGS="-march=$CPU -msse4.2 -mpopcnt -m64 -mtune=intel"

  buildTask

  TOOLCHAIN_PREFIX="${NDK_PATH}/toolchains/llvm/prebuilt/${HOST_PLATFORM}/bin"
}

buildArm64
buildArmeV7
buildx86
#buildX86_64



