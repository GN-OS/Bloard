include $(THEOS)/makefiles/common.mk

TWEAK_NAME = Bloard
Bloard_FRAMEWORKS = UIKit
Bloard_FILES = Tweak.xm

SUBPROJECTS += BloardPreferences
SUBPROJECTS += BloardFlipswitch

include $(THEOS)/tweak.mk

after-install::
	install.exec "killall -9 SpringBoard"
