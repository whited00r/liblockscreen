THEOS_DEVICE_IP = 192.168.1.19
GO_EASY_ON_ME = 1
include $(THEOS)/makefiles/common.mk
ARCHS = armv7
TWEAK_NAME = liblockscreen
liblockscreen_FILES = Tweak.xm NSData+Base64.m
liblockscreen_FRAMEWORKS = UIKit CoreGraphics QuartzCore Foundation Security

include $(THEOS_MAKE_PATH)/tweak.mk
SUBPROJECTS += liblssettings
include $(THEOS_MAKE_PATH)/aggregate.mk
