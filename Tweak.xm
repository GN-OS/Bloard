#define ENABLED @"/var/mobile/Library/Preferences/com.gnos.bloard.enabled.plist"

#import <UIKit/UITextInputTraits.h>

%hook UITextInputTraits

- (int) keyboardAppearance {

    return 1;
    
}

%end

- (void)createDefaultPreferences {
	NSDictionary *d = [[NSDictionary alloc] initWithObjects:
		[NSArray arrayWithObjects:
			[NSNumber numberWithBool:YES],
		nil]
	forKeys:
		[NSArray arrayWithObjects:
			@"enabled",
		nil]
	];
	[d writeToFile:ENABLED atomically:YES];
	[d release];
}

- (BOOL)keyIsEnabled:(NSString *)key {
	NSDictionary *prefs = nil;
	prefs = [[NSDictionary alloc] ENABLED]; // Load the plist
	//Is ENABLED not existent?
	if (prefs == nil) { // create new plist
		[[GNSomeUIAlertViewDelegateClass sharedInstance] createDefaultPreferences];
		// Load the plist again
		prefs = [[NSDictionary alloc] initWithContentsOfFile:ENABLED];
	}

	BOOL r = NO;
	NSNumber *num = (NSNumber *)[prefs objectForKey:key];
	if (num != nil) {
		r = [num boolValue];
	}

	[prefs release];

	return r;
}