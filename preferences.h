#define addObserver(c, n) CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (c), CFSTR(n), NULL, CFNotificationSuspensionBehaviorCoalesce)
#define preferencesChanged() preferencesChangedCallback(NULL, NULL, NULL, NULL, NULL)

static NSDictionary *prefs = nil;

static void preferencesChangedCallback(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) {
	// reload prefs
	[prefs release];
	prefs = [[NSDictionary alloc] initWithContentsOfFile:preferencesFilePath];
}

static BOOL tweakIsEnabled(void) {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	BOOL enabled = (prefs)? [prefs[@"enabled"] boolValue] : NO;
	[pool release];
	return enabled;
}

%ctor {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	preferencesChanged();  // Not really
	// Register to receive changed notifications
	addObserver(preferencesChangedCallback, preferencesChangedNotification);
	[pool release];
}
