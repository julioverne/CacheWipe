include theos/makefiles/common.mk

TWEAK_NAME = CacheWipe

CacheWipe_FILES = /mnt/d/codes/cachewipe/CacheWipe.xm
CacheWipe_FRAMEWORKS = CydiaSubstrate UIKit
CacheWipe_LDFLAGS = -Wl,-segalign,4000

export ARCHS = armv7 arm64
CacheWipe_ARCHS = armv7 arm64

include $(THEOS_MAKE_PATH)/tweak.mk
	
all::
	