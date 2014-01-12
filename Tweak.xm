#define PreferencesChangedNotification "com.gnos.bloard.prefs-changed"
#define PreferencesFilePath @"/var/mobile/Library/Preferences/com.gnos.bloard.plist"

static NSDictionary *prefs = nil;

static void prefsChanged(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) {
        // reload prefs
        [prefs release];
        prefs = [[NSDictionary alloc] initWithContentsOfFile:PreferencesFilePath];
}

%ctor {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	prefs = [[NSDictionary alloc] initWithContentsOfFile:PreferencesFilePath];
	// register to receive changed notifications 
    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, prefsChanged, CFSTR(PreferencesChangedNotification), NULL, CFNotificationSuspensionBehaviorCoalesce);
    [pool release];
}

static BOOL enabled() {
	if (prefs != nil) {
		return [[prefs objectForKey:@"enabled"] boolValue];
	}
	else {
		// prefs don't exist, default to NO
		return NO;
	}
}

@interface UIKBRenderConfig : NSObject
@property float blurRadius;
- (BOOL) lightKeyboard;
@end

%hook UIKBRenderConfig

- (BOOL) lightKeyboard {
    if (enabled() && [self blurRadius] != 0.9) { // if blurRadius is 0.9 then it is a passcode view, do not affect that
    	return NO;
    }
    return %orig;
}

%end