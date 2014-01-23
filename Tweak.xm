#define CFNCAO(c, n) CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (c), CFSTR(n), NULL, CFNotificationSuspensionBehaviorCoalesce)

static const char *PreferencesChangedNotification "com.gnos.bloard.prefs-changed"
static NSString *const PreferencesFilePath @"/var/mobile/Library/Preferences/com.gnos.bloard.plist"

static NSDictionary *prefs = nil;

static void GNCreatePreferencessFileIfNonExistent(void) {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	if ([[NSFileManager defaultManager] fileExistsAtPath:PreferencesFilePath]) {
		return;
	}
	NSDictionary *d = [[NSDictionary alloc] initWithObjects:[NSArray arrayWithObjects:[NSNumber numberWithBool:YES], nil] forKeys:[NSArray arrayWithObjects:@"enabled", nil]];
	[d writeToFile:PreferencesFile atomically:YES];
	[d release];
	[p release];
	return;
}

static void GNPreferencesChanged(void) {
	// reload prefs
	if (prefs != nil) {
		[prefs release];
	}
	prefs = [[NSDictionary alloc] initWithContentsOfFile:PreferencesFilePath];
	return;
}

static void GNPreferencesChangedCallback(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) {
	GNPreferencesChanged();
}

%ctor {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	GNCreatePreferencessFileIfNonExistent();
	GNPreferencesChanged(); //not really

	// register to receive changed notifications
	CFNCAO(GNPreferencesChangedCallback, GNPreferencesChangedNotification);
	[pool release];
}

static BOOL GNIsEnabled(void) {
	NSAutoreleasePool *p = [[NSAutoreleasePool alloc] init];
	BOOL r = NO;
	if (prefs != nil) {
		r = [[prefs objectForKey:@"enabled"] boolValue];
	}
	[p release];
	return r;
}

%hook UIKBRenderConfig

- (BOOL)lightKeyboard {
	BOOL r = %orig();
	if (GNIsEnabled()) {
		r = NO;
	}
	return r;
}

%end
