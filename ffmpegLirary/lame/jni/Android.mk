LOCAL_PATH := $(call my-dir)

include $(CLEAR_VARS)

LOCAL_MODULE := mp3lame
LOCAL_CFLAGS := -DSTDC_HEADERS

LOCAL_SRC_FILES := ./libmp3lame/bitstream.c ./libmp3lame/encoder.c ./libmp3lame/fft.c ./libmp3lame/gain_analysis.c \
	./libmp3lame/id3tag.c ./libmp3lame/lame.c ./libmp3lame/mpglib_interface.c ./libmp3lame/newmdct.c \
	./libmp3lame/presets.c ./libmp3lame/psymodel.c ./libmp3lame/quantize.c ./libmp3lame/quantize_pvt.c \
	./libmp3lame/reservoir.c ./libmp3lame/set_get.c ./libmp3lame/tables.c ./libmp3lame/takehiro.c \
	./libmp3lame/util.c ./libmp3lame/vbrquantize.c ./libmp3lame/VbrTag.c ./libmp3lame/version.c

LOCAL_C_INCLUDES := $(LOCAL_PATH)/libmp3lame $(LOCAL_PATH)/include

ifeq ($(TARGET_ARCH_ABI), armeabi-v7a)
# 采用NEON优化技术    
LOCAL_ARM_NEON := true
LOCAL_CFLAGS += -mfpu=neon -mfpu=vfpv3-d16
endif

ifeq ($(TARGET_ARCH_ABI), armeabi)
LOCAL_CFLAGS += -marm -mfpu=vfp -mfpu=vfpv3 -DCMP_HAVE_VFP
endif

include $(BUILD_STATIC_LIBRARY)
