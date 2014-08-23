export ARCHS := armv7 arm64
export THEOS_PACKAGE_DIR_NAME := packages

#$(shell if [[ ! -f theos ]]; then ln -s $(THEOS) theos; fi)

include theos/makefiles/common.mk

TWEAK_NAME = Bloard
Bloard_FRAMEWORKS = UIKit
Bloard_FILES = Tweak.xm

SUBPROJECTS += BloardPreferences
SUBPROJECTS += BloardFlipswitch

include $(THEOS_MAKE_PATH)/tweak.mk
include $(THEOS_MAKE_PATH)/aggregate.mk

after-install::
	install.exec "killall -9 SpringBoard"
