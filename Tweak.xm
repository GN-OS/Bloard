#define PreferencesChangedNotification "com.gnos.bloard.prefs-changed"
#define PreferencesFilePath @"/var/mobile/Library/Preferences/com.gnos.bloard.plist"

static NSDictionary *prefs = nil;

static void prefsChanged(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) {
		NSLog(@"bloard prefs changed");
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
		NSLog(@"bloard enabled: %d", [[prefs objectForKey:@"enabled"] boolValue]);
		return [[prefs objectForKey:@"enabled"] boolValue];
	}
	else {
		// prefs don't exist, default to NO
		return NO;
	}
}

@interface UIKBRenderConfig : NSObject
- (BOOL) lightKeyboard;
@end

%hook UIKBRenderConfig

- (BOOL) lightKeyboard {
    return enabled();
}

%end