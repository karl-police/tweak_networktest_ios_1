TARGET := iphone:clang:latest:12.4

# To support rootless remove "#"

export THEOS_PACKAGE_SCHEME = #rootless

ARCHS = arm64 arm64e

DEBUG = 0
FINALPACKAGE = 1
include $(THEOS)/makefiles/common.mk

TWEAK_NAME = tweak_test_1


$(TWEAK_NAME)_FILES = $(wildcard *.x)
$(TWEAK_NAME)_CFLAGS = -fobjc-arc
$(TWEAK_NAME)_LOGOS_DEFAULT_GENERATOR = internal

include $(THEOS_MAKE_PATH)/tweak.mk
