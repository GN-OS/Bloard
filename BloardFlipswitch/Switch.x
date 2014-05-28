#import "FSSwitchDataSource.h"
#import "FSSwitchPanel.h"
#include "UFSSharedCode.h"

@interface BloardFlipswitchSwitch : NSObject <FSSwitchDataSource>
@end

@implementation BloardFlipswitchSwitch

- (FSSwitchState)stateForSwitchIdentifier:(NSString *)switchIdentifier {
	NSNumber *n = (NSNumber *)NSPGetKey(bloardNotification, enabledKey);
	BOOL enabled = (n)? [n boolValue]:YES;
	return (enabled) ? FSSwitchStateOn : FSSwitchStateOff;
}

- (void)applyState:(FSSwitchState)newState forSwitchIdentifier:(NSString *)switchIdentifier {
	const char *bloardNotification = "com.gnos.bloard";
	const char *enabledKey = "enabled";
	switch (newState) {
	case FSSwitchStateIndeterminate:
		break;
	case FSSwitchStateOn:
		NSPSetKey(bloardNotification, enabledKey, [NSNumber numberWithBool:YES]);
		CFNCPostNotification(bloardNotification);
		break;
	case FSSwitchStateOff:
		NSPSetKey(bloardNotification, enabledKey, [NSNumber numberWithBool:YES]);
		CFNCPostNotification(bloardNotification);
		break;
	}
	return;
}

- (NSString *)titleForSwitchIdentifier:(NSString *)switchIdentifier {
	return @"Bloard";
}

@end
