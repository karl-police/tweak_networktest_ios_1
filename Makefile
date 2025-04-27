TARGET := iphone:clang:latest:13.0

# To support rootless remove "#"

export THEOS_PACKAGE_SCHEME = #rootless

ARCHS = arm64 arm64e

DEBUG = 0
FINALPACKAGE = 1
include $(THEOS)/makefiles/common.mk

TWEAK_NAME = tweak_test_1


$(TWEAK_NAME)_FILES = $(wildcard *.x) $(wildcard fishhook/*.c) $(wildcard fishhook/*.h)
$(TWEAK_NAME)_CFLAGS = -fobjc-arc
#$(TWEAK_NAME)_LOGOS_DEFAULT_GENERATOR = internal

# Add frameworks
$(TWEAK_NAME)_FRAMEWORKS = Foundation
# if using UIKit
$(TWEAK_NAME)_FRAMEWORKS += UIKit


include $(THEOS_MAKE_PATH)/tweak.mk
