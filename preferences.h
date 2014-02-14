static NSString *const preferencesFilePath = @"/var/mobile/Library/Preferences/com.gnos.bloard.plist";
#define preferencesChangedNotification "com.gnos.bloard.preferences.changed"
 
#define addObserver(c, n) CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (c), CFSTR(n), NULL, CFNotificationSuspensionBehaviorCoalesce)
#define preferencesChanged() preferencesChangedCallback(NULL, NULL, NULL, NULL, NULL)

static NSDictionary *prefs = nil;

static void preferencesChangedCallback(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) {
	// Reload prefs
	[prefs release];
	prefs = [[NSDictionary alloc] initWithContentsOfFile:preferencesFilePath];
}

static BOOL tweakIsEnabled(void) {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	BOOL enabled = (prefs)? [prefs[@"enabled"] boolValue] : NO;
	[pool release];
	return enabled;
}
