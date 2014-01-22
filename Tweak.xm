#include "substrate.h"

#define PreferencesChangedNotification "com.gnos.bloard.prefs-changed"
#define PreferencesFilePath @"/var/mobile/Library/Preferences/com.gnos.bloard.plist"

static NSDictionary *prefs = nil;

static void GNPreferencesChanged(void) {
	// reload prefs
	if (prefs != nil) {
		[prefs release];
	}
	prefs = [NSDictionary dictionaryWithContentsOfFile:PreferencesFilePath];
	return;
}

static void GNPreferencesChangedCallback(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) {
	GNPreferencesChanged();
}

%ctor {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	GNPreferencesChanged();

	// register to receive changed notifications 
	CFNotificationCenterAddObserver(
		CFNotificationCenterGetDarwinNotifyCenter(),
		NULL,
		GNPreferencesChangedCallback,
		CFSTR(GNPreferencesChangedNotification),
		NULL,
		CFNotificationSuspensionBehaviorCoalesce
	);
	[pool release];
}

static BOOL GNIsEnabled(void) {
	NSAutoreleasePool *p = [[NSAutoreleasePool alloc] init];
	BOOL r;
	if (prefs != nil) {
		r = [[prefs objectForKey:@"enabled"] boolValue];
	}
	else {
		// prefs don't exist, default to NO
		r = NO;
	}
	[p release];
	return r;
}

@interface UIKBRenderConfig : NSObject {
}
@property float blurRadius;

- (BOOL)lightKeyboard;

@end

%hook UIKBRenderConfig

- (BOOL)lightKeyboard {
	BOOL r;
	float blurRadius = MSHookIvar<float>(self, "_blurRadius");
	NSLog(@"Bloard: blurRadius = %f", blurRadius);
	if (GNIsEnabled() && [self blurRadius] != 0.9) { // if blurRadius is 0.9 then it is a passcode view, do not affect that
		r = NO;
	} else {
		r = %orig();
	}
	return r;
}

%end
