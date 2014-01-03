#define ENABLED @"/var/mobile/Library/Preferences/com.gnos.bloard.enabled.plist"

#import <UIKit/UITextInputTraits.h>

@interface GNBloardPreferences : NSObject

+ (id)sharedInstance;

- (void)createDefaultPreferences;
- (BOOL)keyIsEnabled;

@end

%hook UITextInputTraits

- (int) keyboardAppearance {
    
    BOOL enabledBool =  [[GNBloardPreferences sharedInstance] keyIsEnabled];
    
    if (enabledBool) {
        
        return 1;
        
    } else {
        
        return %orig;
    }
    
}

%end

@implementation GNBloardPreferences

+ (id)sharedInstance {
    static id sharedInstance = nil;
    
    if (sharedInstance == nil) {
        sharedInstance = [[GNBloardPreferences alloc] init];
    }
    
    return sharedInstance;
}

- (void)createDefaultPreferences {
    
    NSDictionary *d = [[NSDictionary alloc] initWithObjects:[NSArray arrayWithObjects:[NSNumber numberWithBool:YES],nil] forKeys:[NSArray arrayWithObjects:@"enabled",nil]];
    
    [d writeToFile:ENABLED atomically:YES];
    [d release];
}

- (BOOL)keyIsEnabled {
    
    NSDictionary *prefs = nil;
    prefs = [[NSDictionary alloc] initWithContentsOfFile:ENABLED]; // Load the plist
    //Is ENABLED not existent?
    if (prefs == nil) { // create new plist
        [[GNBloardPreferences sharedInstance] createDefaultPreferences];
        // Load the plist again
        prefs = [[NSDictionary alloc] initWithContentsOfFile:ENABLED];
    }
    
    BOOL value = [[prefs objectForKey:@"enabled"] boolValue];
    [prefs release];
    
    return value;
}

@end