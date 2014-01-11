export ARCHS = armv7 arm64
export SDKVERSION = 7.0
export THEOS_BUILD_DIR = packages

include theos/makefiles/common.mk

TWEAK_NAME = Bloard
Bloard_FRAMEWORKS = UIKit
Bloard_FILES = Tweak.xm

include $(THEOS_MAKE_PATH)/tweak.mk


after-install::
	install.exec "killall -9 SpringBoard"

SUBPROJECTS += BloardPrefs
include $(THEOS_MAKE_PATH)/aggregate.mk
