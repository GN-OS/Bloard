#define ENABLED @"/var/mobile/Library/Preferences/com.gnos.bloard.enabled.plist"

#import "UIKBRenderConfig.h"

@interface GNBloard : NSObject
- (void)createDefaultPreferences;
- (BOOL)isEnabled;
@end

@implementation GNBloard

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
    //get the value of enabled
    BOOL value = [[prefs objectForKey:@"enabled"] boolValue];
    [prefs release];
    return value;
}

@end


%hook UIKBRenderConfig

- (BOOL) lightKeyboard {
    GNBloard *prefs =  [[GNBloard alloc] init];
    if ([prefs isEnabled]) {
        [prefs release];
        return NO;
    } 
    else {
        [prefs release];
         return %orig;
    }
}

%end
