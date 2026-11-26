TARGET = iphone:clang:16.5:16.0

include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = XiaomiFolderPrefs
XiaomiFolderPrefs_FILES = XMFRootListController.m
XiaomiFolderPrefs_INSTALL_PATH = /Library/PreferenceBundles
XiaomiFolderPrefs_FRAMEWORKS = UIKit
XiaomiFolderPrefs_PRIVATE_FRAMEWORKS = Preferences
XiaomiFolderPrefs_RESOURCE_FILES = Resources/Root.plist
XiaomiFolderPrefs_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/bundle.mk
