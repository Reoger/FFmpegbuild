#!/bin/bash

FFMPEG_PATH=/Users/luojie/studySpace
NDK_PATH=/Users/luojie/Library/Android/sdk/ndk-bundle
PREFIX_PATH=/Users/luojie/workspace/FFmpegbuild/

#lame静态库的位置
LAMEDIR=`pwd`/lame
SHINE=`pwd`/shine
echo "local: ${LAMEDIR}"

HOST_PLATFORM="darwin-x86_64"
TOOLCHAIN_PREFIX="${NDK_PATH}/toolchains/llvm/prebuilt/${HOST_PLATFORM}/bin"
GCC_PREFIX="${NDK_PATH}/toolchains/llvm/prebuilt/${HOST_PLATFORM}/lib/gcc"

OPTIMIZE_CFLAGS="-marm -Wno-multichar -fno-exceptions"

# libmp3lame
# libshine
#

COMMON_OPTIONS_NEW="
    --target-os=android
    --enable-small
    --enable-static
    --enable-libmp3lame
    --enable-encoder=libmp3lame
    --enable-encoder=png
    --enable-decoder=h264
    --enable-decoder=png
    --enable-decoder=mp3
    --enable-muxers
    --enable-muxer=ogg
    --enable-muxer=opus
    --enable-muxer=webm
    --enable-muxer=webm_chunk
    --enable-muxer=webm_dash_manifest
    --enable-muxer=wav
    --enable-muxer=h264
    --enable-muxer=mp4
    --enable-muxer=matroska
    --enable-muxer=image2
    --enable-muxer=mp3
    --enable-demuxers 
    --enable-demuxer=ogg
    --enable-demuxer=mp3
    --enable-demuxer=wav
    --enable-demuxer=matroska
    --enable-demuxer=matroska
    --enable-demuxer=concat
    --enable-demuxer=rtsp
    --enable-parsers
    --enable-parser=opus
    --enable-parser=vp8
    --enable-parser=vp9 
    --enable-protocol=file
    --enable-filter=scale
    --enable-filter=format
    --enable-filter=trim
    --enable-filter=null
    --enable-cross-compile
    --enable-asm
    --enable-bsfs
    --enable-bsf=mp3_header_decompress
    --disable-shared
    --disable-doc
    --disable-everything
    --disable-programs
    --disable-protocols
    --disable-parsers
    --disable-filters
    --disable-avdevice
    --disable-postproc
    --disable-symver
    --enable-debug
    --logfile=ffmpegConfig.log
    "

COMMON_MERGE_OPTIONS="
    libavcodec/libavcodec.a
    libavfilter/libavfilter.a
    libavformat/libavformat.a
    libavutil/libavutil.a
    libswresample/libswresample.a
    libswscale/libswscale.a
    -lc -lm -lz -ldl -llog --dynamic-linker=/system/bin/linker
"

ENABLED_ENCODERS=(png libmp3lame)
ENABLED_DECODERS=(h264 png mp3)
ENABLED_MUXERS=(h264 mp4 matroska image2 mp3)
ENABLED_DEMUXERS=(matroska concat rtsp)
ENABLED_PROTOCOLS=(file)
ENABLED_FILTERS=(scale format trim null)
COMMON_OPTIONS="
    --target-os=android
    --enable-small
    --enable-static
    --enable-libmp3lame
    --enable-encoder=libmp3lame
    --disable-shared
    --disable-doc
    --disable-everything
    --disable-programs
    --disable-protocols
    --disable-parsers
    --disable-filters
    --disable-avdevice
    --disable-postproc
    --disable-symver
    --enable-debug
    --logfile=ffmpegConfig.log
    "

for encoder in "${ENABLED_ENCODERS[@]}"
do
    COMMON_OPTIONS="${COMMON_OPTIONS} --enable-encoder=${encoder}"
done
for decoder in "${ENABLED_DECODERS[@]}"
do
    COMMON_OPTIONS="${COMMON_OPTIONS} --enable-decoder=${decoder}"
done
for muxer in "${ENABLED_MUXERS[@]}"
do
    COMMON_OPTIONS="${COMMON_OPTIONS} --enable-muxer=${muxer}"
done
for demuxer in "${ENABLED_DEMUXERS[@]}"
do
    COMMON_OPTIONS="${COMMON_OPTIONS} --enable-demuxer=${demuxer}"
done
for protocol in "${ENABLED_PROTOCOLS[@]}"
do
    COMMON_OPTIONS="${COMMON_OPTIONS} --enable-protocol=${protocol}"
done
for filter in "${ENABLED_FILTERS[@]}"
do
    COMMON_OPTIONS="${COMMON_OPTIONS} --enable-filter=${filter}"
done

# git clone git://source.ffmpeg.org/ffmpeg ffmpeg
cd "${FFMPEG_PATH}/ffmpeg"
#git checkout release/4.2


function buildOne() {
  SYSROOT="${NDK_PATH}/platforms/android-26/arch-arm64"
  PREFIX="${PREFIX_PATH}/android-libs/arch-arm64"

  EXTRA_LDFLAGS="-L$LAMEDIR/obj/local/arm64-v8a"
  EXTRA_CFLAGS="-fPIC -I${NDK_PATH}/sysroot/usr/include -I$LAMEDIR/include"

  ./configure \
    --prefix=$PREFIX \
    --arch=aarch64 \
    --cpu=armv8-a \
    --cross-prefix="${TOOLCHAIN_PREFIX}/aarch64-linux-android-" \
    --nm="${TOOLCHAIN_PREFIX}/aarch64-linux-android-nm" \
    --cc="${TOOLCHAIN_PREFIX}/aarch64-linux-android26-clang" \
    --extra-ldexeflags=-pie \
    --extra-ldflags="${EXTRA_LDFLAGS}" \
    --extra-cflags="${EXTRA_CFLAGS}" \
    ${COMMON_OPTIONS}

  [ $? -eq 0 ]  || exit 1
  make -j8
  make install

  # sed -i '' 's/HAVE_LRINT 0/HAVE_LRINT 1/g' config.h
  # sed -i '' 's/HAVE_LRINTF 0/HAVE_LRINTF 1/g' config.h
  # sed -i '' 's/HAVE_ROUND 0/HAVE_ROUND 1/g' config.h
  # sed -i '' 's/HAVE_ROUNDF 0/HAVE_ROUNDF 1/g' config.h
  # sed -i '' 's/HAVE_TRUNC 0/HAVE_TRUNC 1/g' config.h
  # sed -i '' 's/HAVE_TRUNCF 0/HAVE_TRUNCF 1/g' config.h
  # sed -i '' 's/HAVE_CBRT 0/HAVE_CBRT 1/g' config.h
  # sed -i '' 's/HAVE_RINT 0/HAVE_RINT 1/g' config.h

# 打包成一个 so
  ${TOOLCHAIN_PREFIX}/aarch64-linux-android-ld \
    -rpath-link=$SYSROOT/usr/lib \
    -L$SYSROOT/usr/lib \
    -L$PREFIX/lib \
    -soname libffmpeg.so -shared -nostdlib -Bsymbolic --whole-archive --no-undefined -o \
    $PREFIX/libffmpeg.so \
    "${LAMEDIR}/obj/local/arm64-v8a/libmp3lame.a" \
    ${COMMON_MERGE_OPTIONS} \
    ${GCC_PREFIX}/aarch64-linux-android/4.9.x/libgcc_real.a
  ${TOOLCHAIN_PREFIX}/aarch64-linux-android-strip  $PREFIX/libffmpeg.so
  make clean

}

buildOne

