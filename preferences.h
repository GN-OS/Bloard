#ifndef EXTRA_H
#define EXTRA_H

static NSString *const preferencesFilePath = @"/var/mobile/Library/Preferences/com.gnos.bloard.plist";
static const char *preferencesChangedNotification = "com.gnos.bloard.preferences.changed";
 
#define CFNCAddObserver(c, n)   do { CFStringRef cfStr = CFStringCreateWithCString(NULL, n, kCFStringEncodingUTF8); \
	CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (c), cfStr, NULL, CFNotificationSuspensionBehaviorCoalesce); CFRelease(cfStr); } while (0)
#define CFNCPostNotification(n) do { CFStringRef cfStr = CFStringCreateWithCString(NULL, n, kCFStringEncodingUTF8); \
	CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), cfStr, NULL, NULL, YES); CFRelease(cfStr); } while (0)

#define addObserver(c, n) CFNCAddObserver(c, n)
#define preferencesChanged() preferencesChangedCallback(NULL, NULL, NULL, NULL, NULL)

static NSDictionary *preferences = nil;

static void preferencesChangedCallback(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) {
	// Reload prefs
	[preferences release];
	preferences = [[NSDictionary alloc] initWithContentsOfFile:preferencesFilePath];
}

static BOOL tweakIsEnabled(void) {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	BOOL enabled = [preferences[@"enabled"] boolValue];
	[pool release];
	return enabled;
}

#endif /* EXTRA_H */
