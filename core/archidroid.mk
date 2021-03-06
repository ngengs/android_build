#     _             _     _ ____            _     _
#    / \   _ __ ___| |__ (_)  _ \ _ __ ___ (_) __| |
#   / _ \ | '__/ __| '_ \| | | | | '__/ _ \| |/ _` |
#  / ___ \| | | (__| | | | | |_| | | | (_) | | (_| |
# /_/   \_\_|  \___|_| |_|_|____/|_|  \___/|_|\__,_|
#
# Copyright 2015-2016 Łukasz "JustArchi" Domeradzki
# Contact: JustArchi@JustArchi.net
#
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

#######################
### GENERAL SECTION ###
#######################

# General optimization level
ARCHIDROID_GCC_CFLAGS_OPTI := -O3

# General optimization level of target ARM compiled with GCC. Default: -O2
ARCHIDROID_GCC_CFLAGS_ARM := $(ARCHIDROID_GCC_CFLAGS_OPTI)

# General optimization level of target THUMB compiled with GCC. Default: -Os
ARCHIDROID_GCC_CFLAGS_THUMB := $(ARCHIDROID_GCC_CFLAGS_OPTI)

# Additional flags passed to all C targets compiled with GCC
ARCHIDROID_GCC_CFLAGS := $(ARCHIDROID_GCC_CFLAGS_OPTI) -pipe -fgcse-las -fgcse-sm -fipa-pta -fivopts -fomit-frame-pointer -frename-registers -fsection-anchors -ftree-loop-im -ftree-loop-ivcanon -ftree-vectorize -funsafe-loop-optimizations -funswitch-loops -fweb

# We also need to disable some warnings to not abort the build - those warning are not critical
ARCHIDROID_GCC_CFLAGS += -Wno-error=array-bounds -Wno-error=clobbered -Wno-error=maybe-uninitialized -Wno-error=parentheses -Wno-error=strict-overflow -Wno-error=unused-variable

# Flags passed to linker (ld) of all C and C++ targets
ARCHIDROID_GCC_LDFLAGS := -Wl,-O3 -Wl,--as-needed -Wl,--gc-sections -Wl,--relax -Wl,--sort-common


# Flags below are applied to specific targets only, use them if your flag is not compatible for both compilers

# We use GCC 5.3 for arm-linux-androideabi, make sure to remove flags below if you decided to stick with 4.9
ARCHIDROID_GCC_CFLAGS_32 := 
#-Wno-error=bool-compare -Wno-error=logical-not-parentheses -Wno-error=sizeof-array-argument

# We use GCC 4.9 for aarch64-linux-android, so we don't have any extra flags for it
ARCHIDROID_GCC_CFLAGS_64 := 

############################
### EXPERIMENTAL SECTION ###
############################

# Flags in this section are highly experimental
# Current setup is based on proposed androideabi toolchain
# Results with other toolchains may vary
# Be careful when changing options in this section

# These flags should work in general, but it's likely that the generated code might be in fact slower than without them
# I suggest to not enable them globally, but they're here for you in case you want to benchmark the OS with and without them
# ARCHIDROID_GCC_CFLAGS += -ftracer -funroll-loops

# These flags may cause ICEs in some compilers, but work fine in other ones, test carefully
ARCHIDROID_GCC_CFLAGS += -fgraphite -fgraphite-identity

# The following flags (-floop) require that your GCC has been configured --with-isl
# Additionally, applying any of them will most likely cause ICE in your compiler, so they're disabled
# ARCHIDROID_GCC_CFLAGS += -floop-block -floop-interchange -floop-nest-optimize -floop-parallelize-all -floop-strip-mine

# These flags have been disabled because of assembler errors
# ARCHIDROID_GCC_CFLAGS += -fmodulo-sched -fmodulo-sched-allow-regmoves

####################
### MISC SECTION ###
####################

# Flags passed to GCC preprocessor for C and C++
ARCHIDROID_GCC_CPPFLAGS := $(ARCHIDROID_GCC_CFLAGS)

#####################
### CLANG SECTION ###
#####################

# Flags passed to all C targets compiled with CLANG
ARCHIDROID_CLANG_CFLAGS := -O3 -Qunused-arguments -Wno-unknown-warning-option

# Flags passed to CLANG preprocessor for C and C++
ARCHIDROID_CLANG_CPPFLAGS := $(ARCHIDROID_CLANG_CFLAGS)

# Flags passed to linker (ld) of all C and C++ targets compiled with CLANG
ARCHIDROID_CLANG_LDFLAGS := $(ARCHIDROID_GCC_LDFLAGS)

# Flags that are used by GCC, but are unknown to CLANG. If you get "argument unused during compilation" error, add the flag here
ARCHIDROID_CLANG_UNKNOWN_FLAGS := \
  -mvectorize-with-neon-double \
  -mvectorize-with-neon-quad \
  -fgcse-after-reload \
  -fgcse-las \
  -fgcse-sm \
  -fgraphite \
  -fgraphite-identity \
  -fipa-pta \
  -fivopts \
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
  -ftracer \
  -ftree-loop-im \
  -ftree-loop-ivcanon \
  -funsafe-loop-optimizations \
  -fweb

#####################
### HACKS SECTION ###
#####################

# Most of the flags are increasing code size of the output binaries, especially O3 instead of Os for target THUMB
# This may become problematic for small blocks, especially for boot or recovery blocks (ramdisks), used in older devices
# For example, i9300 has only 8 MB block for recovery.img, and compiling TWRP for it with above optimizations will fail
#
# If you don't care about the size of recovery.img, e.g. you have no use of it, and you want to silence the
# error "image too large" for recovery.img, use this definition
#
# NOTICE: It's better to use device-based flag TARGET_NO_RECOVERY instead, but some devices may have
# boot + recovery combo (e.g. Sony Xperias), and we must build recovery for them, so we can't set TARGET_NO_RECOVERY globally
# Therefore, this seems like a safe approach (will only ignore check on recovery.img, without doing anything else)
# However, if you use compiled recovery.img for your device, please disable this flag (comment or set to false), and lower
# optimization levels instead, as you need to make sure that recovery.img fits prior to trying to flash it
# Most (if not all) of the builders have no use of recovery.img, therefore this option is enabled by default
ARCHIDROID_IGNORE_RECOVERY_SIZE := true
