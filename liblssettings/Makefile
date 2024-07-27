include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = LibLSSettings
LibLSSettings_FILES = LibLSSettings.mm
LibLSSettings_INSTALL_PATH = /Library/PreferenceBundles
LibLSSettings_FRAMEWORKS = UIKit Foundation
LibLSSettings_PRIVATE_FRAMEWORKS = Preferences

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/LibLSSettings.plist$(ECHO_END)
