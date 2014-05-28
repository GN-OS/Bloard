export ARCHS := armv7 arm64
export THEOS_BUILD_DIR := packages

#$(shell if [[ ! -f theos ]]; then ln -s $(THEOS) theos; fi)

include theos/makefiles/common.mk

TWEAK_NAME = Bloard
Bloard_FRAMEWORKS = UIKit
uroboro_SOURCES = sources
uroboro_FILES += $(wildcard $(uroboro_SOURCES)/*.c)
uroboro_FILES += $(wildcard $(uroboro_SOURCES)/*.cpp)
uroboro_FILES += $(wildcard $(uroboro_SOURCES)/*.m)
uroboro_FILES += $(wildcard $(uroboro_SOURCES)/*.mm)
uroboro_FILES += $(wildcard $(uroboro_SOURCES)/*.x)
uroboro_FILES += $(wildcard $(uroboro_SOURCES)/*.xm)
Bloard_FILES = $(uroboro_FILES)

SUBPROJECTS += BloardPreferences
SUBPROJECTS += BloardFlipswitch

include $(THEOS_MAKE_PATH)/tweak.mk
include $(THEOS_MAKE_PATH)/aggregate.mk

after-install::
	install.exec "killall -9 SpringBoard"
