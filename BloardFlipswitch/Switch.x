#import "FSSwitchDataSource.h"
#import "FSSwitchPanel.h"

#define PreferencesChangedNotification "com.gnos.bloard.prefs-changed"
#define PreferencesFilePath @"/var/mobile/Library/Preferences/com.gnos.bloard.plist"

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

static void GNSetEnabled(BOOL b) {
	NSAutoreleasePool *p = [[NSAutoreleasePool alloc] init];

	//set value
	NSMutableDictionary *d = [[NSMutableDictionary alloc] initWithContentsOfFile:PreferencesFilePath];
	[d setObject:[NSNumber numberWithBool:b] forKey:@"enabled"];
	[d writeToFile:PreferencesFilePath atomically:YES];
	[d release];

	//post notification
	CFNotificationCenterPostNotification(
		CFNotificationCenterGetDarwinNotifyCenter(),
		CFSTR(GNPreferencesChangedNotification),
		NULL,
		NULL,
		YES
	)

	[p release];
	return;
}	

@interface BloardFlipswitchSwitch : NSObject <FSSwitchDataSource>
@end

@implementation BloardFlipswitchSwitch

- (FSSwitchState)stateForSwitchIdentifier:(NSString *)switchIdentifier {
	return return GNIsEnabled()? FSSwitchStateOn : FSSwitchStateOff;
}

- (void)applyState:(FSSwitchState)newState forSwitchIdentifier:(NSString *)switchIdentifier {
	switch (newState) {
	case FSSwitchStateIndeterminate:
		break;
	case FSSwitchStateOn:
		GNSetEnabled(YES);
		break;
	case FSSwitchStateOff:
		GNSetEnabled(NO);
		break;
	}
	return;
}

- (NSString *)titleForSwitchIdentifier:(NSString *)switchIdentifier {
	return @"Bloard";
}

@end