#define ENABLED @"/var/mobile/Library/Preferences/com.gnos.bloard.enabled.plist"
#define COLOUR @"/var/mobile/Library/Preferences/com.gnos.bloard.colour.plist"

#import <UIKit/UITextInputTraits.h>

@interface GNBloardPreferences : NSObject

- (void)createDefaultPreferences;
- (BOOL)isEnabled;
- (void)createColourPreferences;
- (int)colour;

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

- (void)createColourPreferences {
    int colour;
    NSDictionary *d = [[NSDictionary alloc] initWithObjects:colour forKeys:[NSArray arrayWithObjects:@"colour",nil]];
    [d writeToFile:COLOUR atomically:YES];
    [d release];
}

- (int)colour {
    
    
    NSDictionary *prefs = nil;
    prefs = [[NSDictionary alloc] initWithContentsOfFile:COLOUR]; // Load the plist
    //Is ENABLED not existent?
    if (prefs == nil) { // create new plist
        [self createColourPreferences];
        // Load the plist again
        prefs = [[NSDictionary alloc] initWithContentsOfFile:COLOUR];
    }
    
    int value = [prefs objectForKey:@"colour"];
    [prefs release];
    
    return value;
}

@end

%hook UITextInputTraits

- (int) keyboardAppearance {
    GNBloardPreferences *prefs =  [[GNBloardPreferences alloc] init];
    if ([prefs isEnabled]) {
        if ([prefs colour] == 1) {
            [prefs release];
            int color = [[UIColor blackColor] colorCode];
            return color;
        } else  if ([prefs colour] == 2) {
            [prefs release];
            int color = [[UIColor darkGrayColor] colorCode];
            return color;
        } else  if ([prefs colour] == 3) {
            [prefs release];
            int color = [[UIColor lightGrayColor] colorCode];
            return color;
        } else  if ([prefs colour] == 4) {
            [prefs release];
            int color = [[UIColor whiteColor] colorCode];
            return color;
        } else  if ([prefs colour] == 5) {
            [prefs release];
            int color = [UIColor grayColor] colorCode];
            return color;
        } else  if ([prefs colour] == 6) {
            [prefs release];
            int color = [UIColor redColor] colorCode];
            return color;
        } else  if ([prefs colour] == 7) {
            [prefs release];
            int color = [UIColor greenColor] colorCode];
            return color;
        } else  if ([prefs colour] == 8) {
            [prefs release];
            int color = [UIColor blueColor] colorCode];
            return color;
        } else  if ([prefs colour] == 9) {
            [prefs release];
            int color = [UIColor cyanColor] colorCode];
            return color;
        } else  if ([prefs colour] == 10) {
            [prefs release];
            int color = [UIColor yellowColor] colorCode];
            return color;
        } else  if ([prefs colour] == 11) {
            [prefs release];
            int color = [UIColor magentaColor] colorCode];
            return color;
        } else  if ([prefs colour] == 12) {
            [prefs release];
            int color = [UIColor orangeColor] colorCode];
            return color;
        } else  if ([prefs colour] == 13) {
            [prefs release];
            int color = [UIColor purpleColor] colorCode];
            return color;
        } else  if ([prefs colour] == 14) {
            [prefs release];
            int color = [UIColor brownColor] colorCode];
            return color;
        }

        
    } else {
        [prefs release];
        return %orig;
    }
    
}

%end
