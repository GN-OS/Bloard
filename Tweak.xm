#define ENABLED @"/var/mobile/Library/Preferences/com.gnos.bloard.enabled.plist"

#import <UIKit/UITextInputTraits.h>

@interface GNBloardPreferences : NSObject

- (void)createDefaultPreferences;
- (BOOL)isEnabled;

@end

@implementation GNBloardPreferences

- (void)createDefaultPreferences {
    NSDictionary *d = [[NSDictionary alloc] initWithObjects:[NSArray arrayWithObjects:[NSNumber numberWithBool:YES],nil] forKeys:[NSArray arrayWithObjects:@"enabled",nil]];
    [d writeToFile:ENABLED atomically:YES];
    [d release];
}

- (BOOL)isEnabled {
    NSDictionary *prefs = nil;
    prefs = [[NSDictionary alloc] initWithContentsOfFile:ENABLED]; // Load the plist
    //Is ENABLED not existent?
    if (prefs == nil) { // create new plist
        [self createDefaultPreferences];
        // Load the plist again
        prefs = [[NSDictionary alloc] initWithContentsOfFile:ENABLED];
    }
    BOOL value = [[prefs objectForKey:@"enabled"] boolValue];
    [prefs release];
    return value;
}

@end

%hook UITextInputTraits

- (int) keyboardAppearance {
    GNBloardPreferences *prefs =  [[GNBloardPreferences alloc] init];
    if ([prefs isEnabled]) {
        [prefs release];
        return 1;
    } else {
        [prefs release];
        return %orig;
    }
    
}

%end
