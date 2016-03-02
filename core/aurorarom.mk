# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# Base Source JustArchi's ArchiDroid Optimizations V4.1
# Copyright 2015 Łukasz "JustArchi" Domeradzki
#
# AuroraROM Optimizations v1.0
# Copyright 2016 Adriano Martins

#######################
#### O3/O2 SECTION ####
#######################

ifeq ($(USE_O3),true)
	# General optimization level of target ARM compiled with GCC. Default: -O2
	AURORAROM_GCC_CFLAGS_ARM := -O3

	# General optimization level of target THUMB compiled with GCC. Default: -Os
	AURORAROM_GCC_CFLAGS_THUMB := -O3

	# Additional flags passed to all C targets compiled with GCC
	AURORAROM_GCC_CFLAGS := -O3 -fgcse-las -fgcse-sm -fipa-pta -fivopts -fomit-frame-pointer -frename-registers -fsection-anchors -ftracer -ftree-loop-im -ftree-loop-ivcanon -funsafe-loop-optimizations -funswitch-loops -fweb -Wno-error=array-bounds -Wno-error=clobbered -Wno-error=maybe-uninitialized -Wno-error=strict-overflow
else
	# General optimization level of target ARM compiled with GCC. Default: -O2
	AURORAROM_GCC_CFLAGS_ARM := -O2

	# General optimization level of target THUMB compiled with GCC. Default: -Os
	AURORAROM_GCC_CFLAGS_THUMB := -Os
endif

############################
### EXPERIMENTAL SECTION ###
############################

# Flags in this section are highly experimental
# Current setup is based on proposed androideabi toolchain
# Results with other toolchains may vary

# These flags have been disabled because of assembler errors
# AURORAROM_GCC_CFLAGS += -fmodulo-sched -fmodulo-sched-allow-regmoves

####################
### MISC SECTION ###
####################

# Flags passed to GCC preprocessor for C and C++
AURORAROM_GCC_CPPFLAGS := $(AURORAROM_GCC_CFLAGS)

#####################
### CLANG SECTION ###
#####################

ifeq ($(USE_O3),true)
	# Flags passed to all C targets compiled with CLANG
	AURORAROM_CLANG_CFLAGS := -O3 -Qunused-arguments -Wno-unknown-warning-option
else
	AURORAROM_CLANG_CFLAGS := -O2 -Qunused-arguments -Wno-unknown-warning-option
endif

# Flags passed to CLANG preprocessor for C and C++
AURORAROM_CLANG_CPPFLAGS := $(AURORAROM_CLANG_CFLAGS)

# Flags that are used by GCC, but are unknown to CLANG. If you get "argument unused during compilation" error, add the flag here
AURORAROM_CLANG_UNKNOWN_FLAGS := \
  -mvectorize-with-neon-double \
  -mvectorize-with-neon-quad \
  -fgcse-after-reload \
  -fgcse-las \
  -fgcse-sm \
  -fgraphite \
  -fgraphite-identity \
  -fipa-pta \
  -floop-block \
  -floop-interchange \
  -floop-nest-optimize \
  -floop-parallelize-all \
  -ftree-parallelize-loops=2 \
  -ftree-parallelize-loops=4 \
  -ftree-parallelize-loops=8 \
  -ftree-parallelize-loops=16 \
  -floop-strip-mine \
  -fmodulo-sched \
  -fmodulo-sched-allow-regmoves \
  -frerun-cse-after-loop \
  -frename-registers \
  -fsection-anchors \
  -ftree-loop-im \
  -ftree-loop-ivcanon \
  -funsafe-loop-optimizations \
  -fweb
  
#####################
### HACKS SECTION ###
#####################

# Most of the flags are increasing code size of the output binaries, especially O3 instead of Os for target THUMB
# This may become problematic for small blocks, especially for boot or recovery blocks (ramdisks)
# If you don't care about the size of recovery.img, e.g. you have no use of it, and you want to silence the
# error "image too large" for recovery.img, use this definition
#
# NOTICE: It's better to use device-based flag TARGET_NO_RECOVERY instead, but some devices may have
# boot + recovery combo (e.g. Sony Xperias), and we must build recovery for them, so we can't set TARGET_NO_RECOVERY globally
# Therefore, this seems like a safe approach (will only ignore check on recovery.img, without doing anything else)
# However, if you use compiled recovery.img for your device, please disable this flag (comment or set to false), and lower
# optimization levels instead
AURORAROM_IGNORE_RECOVERY_SIZE := true

########################
### GRAPHITE SECTION ###
########################

DISABLE_GRAPHITE := \
	libunwind \
	libFFTEm \
	libicui18n \
	libskia \
	libvpx \
	libmedia_jni \
	libstagefright_mp3dec \
	libart \
	libstagefright_amrwbenc \
	libpdfium \
	libpdfiumcore \
	libwebviewchromium \
	libwebviewchromium_loader \
	libwebviewchromium_plat_support \
	libjni_filtershow_filters \
	fio \
	libwebrtc_spl \
	libpcap \
	libsigchain \
	libFraunhoferAAC \
	libavcodec \
	libavformat \
	libavutil \
	libswscale

ifeq ($(USE_GRAPHITE),true)
ifndef LOCAL_IS_HOST_MODULE
ifneq ($(filter $(DISABLE_GRAPHITE), $(LOCAL_MODULE)),)
	AURORAROM_GCC_CFLAGS += -fgraphite -fgraphite-identity -floop-flatten -floop-parallelize-all -ftree-loop-linear -floop-interchange -floop-strip-mine -floop-block
endif
endif
endif

#######################
### FLOOP ALIASING ###
#######################

DISABLE_FLOOP := \

ifeq ($(USE_FLOOP),true)
ifndef LOCAL_IS_HOST_MODULE
ifneq ($(filter $(DISABLE_FLOOP), $(LOCAL_MODULE)),)
	AURORAROM_GCC_CFLAGS += -floop-flatten -floop-parallelize-all -ftree-loop-linear -floop-interchange -floop-strip-mine -floop-block
endif
endif
endif

#######################
### STRICT ALIASING ###
#######################

DISABLE_STRICT := \
    third_party_libyuv_libyuv_gyp \
    third_party_WebKit_Source_wtf_wtf_gyp \
    ipc_ipc_gyp \
    third_party_webrtc_base_rtc_base_gyp \
    courgette_courgette_lib_gyp \
    third_party_WebKit_Source_platform_blink_common_gyp \
    cc_cc_surfaces_gyp \
    net_http_server_gyp \
    base_base_gyp \
    ui_gfx_gfx_gyp \
    android_webview_native_webview_native_gyp \
    jingle_jingle_glue_gyp \
    ui_native_theme_native_theme_gyp \
    third_party_WebKit_Source_core_webcore_dom_gyp \
    third_party_WebKit_Source_core_webcore_html_gyp \
    third_party_WebKit_Source_core_webcore_rendering_gyp \
    third_party_WebKit_Source_core_webcore_svg_gyp \
    components_autofill_content_browser_gyp \
    ui_surface_surface_gyp \
    printing_printing_gyp \
    third_party_WebKit_Source_web_blink_web_gyp \
    third_party_webrtc_modules_media_file_gyp \
    cc_cc_gyp \
    storage_storage_gyp \
    android_webview_android_webview_common_gyp \
    content_content_browser_gyp \
    content_content_common_gyp \
    content_content_child_gyp \
    third_party_webrtc_modules_webrtc_utility_gyp \
    third_party_webrtc_modules_iLBC_gyp \
    third_party_webrtc_modules_neteq_gyp \
    third_party_webrtc_modules_audio_device_gyp\
    third_party_webrtc_modules_rtp_rtcp_gyp \
    components_data_reduction_proxy_browser_gyp \
    libunwind \
    libc_bionic \
    libc_malloc \
    e2fsck \
    mke2fs \
    tune2fs \
    mkfs.exfat \
    fsck.exfat \
    mount.exfat \
    mkfs.f2fs \
    fsck.f2fs \
    fibmap.f2fs \
    libc_dns \
    libc_tzcode \
    libtwrpmtp \
    libfusetwrp \
    libguitwrp \
    busybox \
    toolbox \
    clatd \
    ip \
    libuclibcrpc \
    libpdfiumcore \
    libandroid_runtime \
    libmedia \
    libpdfiumcore \
    libpdfium \
    bluetooth.default \
    logd \
    mdnsd \
    libfuse \
    libcutils \
    liblog \
    healthd \
    adbd \
    libunwind \
    libsync \
    libnetutils \
    libusbhost \
    libfs_mgr \
    libvold \
    net_net_gyp \
    libstagefright_webm \
    libaudioflinger \
    libmediaplayerservice \
    libstagefright \
    libstagefright_avcenc \
    libstagefright_avc_common \
    libstagefright_httplive \
    libstagefright_rtsp \
    sdcard \
    ping \
    libnetlink \
    ping6 \
    libfdlibm \
    libvariablespeed \
    librtp_jni \
    libwilhelm \
    debuggerd \
    libbt-brcm_bta \
    libbt-brcm_stack \
    libdownmix \
    libldnhncr \
    libqcomvisualizer \
    libvisualizer \
    libutils \
    libandroidfw \
    dnsmasq \
    static_busybox \
    libstagefright_foundation \
    content_content_renderer_gyp \
    third_party_WebKit_Source_modules_modules_gyp \
    third_party_WebKit_Source_platform_blink_platform_gyp \
    third_party_WebKit_Source_core_webcore_remaining_gyp \
    third_party_angle_src_translator_lib_gyp \
    third_party_WebKit_Source_core_webcore_generated_gyp \
    libc_gdtoa \
    libc_openbsd \
    libc \
    libc_nomalloc \
    patchoat \
    dex2oat \
    libart \
    libart-compiler \
    oatdump \
    libart-disassembler \
    mm-vdec-omx-test \
    libziparchive-host \
    libziparchive \
    libdiskconfig \
    logd \
    linker \
    libjavacore \
    camera.msm8084 \
    libmmcamera_interface \
    camera.hammerhead \
    tcpdump

ifeq ($(USE_STRICT),true)
ifndef LOCAL_IS_HOST_MODULE
ifneq ($(filter $(DISABLE_STRICT), $(LOCAL_MODULE)),)
	AURORAROM_GCC_CFLAGS += -fstrict-aliasing -Wno-error=strict-aliasing -Wstrict-aliasing=2
else
	AURORAROM_GCC_CFLAGS += -fno-strict-aliasing
endif
endif
endif
