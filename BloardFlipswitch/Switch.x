#import "FSSwitchDataSource.h"
#import "FSSwitchPanel.h"

#define prefsChanged() CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), CFSTR("com.gnos.bloard.preferences.changed"), NULL, NULL, YES);

static NSString* const preferencesFilePath = @"/var/mobile/Library/Preferences/com.gnos.bloard.plist";


static BOOL tweakIsEnabled(void) {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	NSDictionary *prefs = [[NSDictionary alloc] initWithContentsOfFile:preferencesFilePath];
	BOOL enabled = (prefs)? [prefs[@"enabled"] boolValue] : NO;
	[prefs release];
	[pool release];
	return enabled;
}

static void tweakSetEnabled(BOOL b) {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	// Overwrite the preferences file
	NSMutableDictionary *prefs = [[NSMutableDictionary alloc] initWithContentsOfFile:preferencesFilePath];
	[prefs setObject:[NSNumber numberWithBool:b] forKey:@"enabled"];
	[prefs writeToFile:preferencesFilePath atomically:YES];
	[prefs release];
	// Kill keyboard cache
	NSFileManager *manager = [NSFileManager defaultManager];
	NSString *path = @"/var/mobile/Library/Caches/com.apple.keyboards";
	BOOL isDir;
	NSLog(@"BLOARD ---- removing folder");
	// Make sure the folder exists
	if ([manager fileExistsAtPath:path isDirectory:&isDir]) {
		NSLog(@"BLOARD ---- folder exists");
		if (isDir) {
			NSLog(@"BLOARD --- is folder");
			// Remove the folder and all of its contents
			[manager removeItemAtPath:path error:nil];
		}
	}
	// Post notification
	prefsChanged();
	[pool release];
	return;
}

@interface BloardFlipswitchSwitch : NSObject <FSSwitchDataSource>
@end

@implementation BloardFlipswitchSwitch

- (FSSwitchState)stateForSwitchIdentifier:(NSString *)switchIdentifier {
	return tweakIsEnabled() ? FSSwitchStateOn : FSSwitchStateOff;
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
