THEOS_PACKAGE_SCHEME = rootless

ARCHS = arm64 arm64e
TARGET = iphone:clang:latest:16.0
INSTALL_TARGET_PROCESSES = SpringBoard

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = XiaomiFolder
XiaomiFolder_FILES = Tweak.xm
XiaomiFolder_FRAMEWORKS = UIKit
XiaomiFolder_CFLAGS = -fobjc-arc

SUBPROJECTS += Preferences

include $(THEOS_MAKE_PATH)/tweak.mk
include $(THEOS_MAKE_PATH)/aggregate.mk
