#import "FSSwitchDataSource.h"
#import "FSSwitchPanel.h"

#define CFNCPN(n) CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), CFSTR(n), NULL, NULL, YES);

static NSString* const preferencesFilePath = @"/var/mobile/Library/Preferences/com.gnos.bloard.plist";
#define preferencesChangedNotification "com.gnos.bloard.preferences.changed"

static BOOL tweakIsEnabled(void) {
	NSAutoreleasePool *p = [[NSAutoreleasePool alloc] init];

	NSDictionary *d = [[NSDictionary alloc] initWithContentsOfFile:preferencesFilePath];
	BOOL r = (d)? [[d objectForKey:@"enabled"] boolValue]:NO;
	[d release];

	[p release];
	return r;
}

static void tweakSetEnabled(BOOL b) {
	NSAutoreleasePool *p = [[NSAutoreleasePool alloc] init];

	//set value
	NSMutableDictionary *d = [[NSMutableDictionary alloc] initWithContentsOfFile:preferencesFilePath];
	[d setObject:[NSNumber numberWithBool:b] forKey:@"enabled"];
	[d writeToFile:preferencesFilePath atomically:YES];
	[d release];

	//post notification
	CFNCPN(preferencesChangedNotification);

	[p release];
	return;
}

@interface BloardFlipswitchSwitch : NSObject <FSSwitchDataSource>
@end

@implementation BloardFlipswitchSwitch

- (FSSwitchState)stateForSwitchIdentifier:(NSString *)switchIdentifier {
	return tweakIsEnabled()? FSSwitchStateOn : FSSwitchStateOff;
}

- (void)applyState:(FSSwitchState)newState forSwitchIdentifier:(NSString *)switchIdentifier {
	switch (newState) {
	case FSSwitchStateIndeterminate:
		break;
	case FSSwitchStateOn:
		tweakSetEnabled(YES);
		break;
	case FSSwitchStateOff:
		tweakSetEnabled(NO);
		break;
	}
	return;
}

- (NSString *)titleForSwitchIdentifier:(NSString *)switchIdentifier {
	return @"Bloard";
}

@end
