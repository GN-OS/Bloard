#define ENABLED @"/var/mobile/Library/Preferences/com.gnos.bloard.enabled.plist"
#define COLOR @"/var/mobile/Library/Preferences/com.gnos.bloard.color.plist"

#import <UIKit/UITextInputTraits.h>

@interface GNBloard : NSObject {
    UIImageView *imageView;
}

- (void)createDefaultPreferences;
- (BOOL)isEnabled;
- (void)createColorPreferences;
- (NSString *)color;
- (void)keyboardDidShow:(NSNotification *)notification;
- (void)keyboardDidHide:(NSNotification *)notification;
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

- (void)createColorPreferences {

    NSDictionary *d = @{@"color" : @"Black"};
    [d writeToFile:COLOR atomically:YES];
    [d release];
}

- (NSString *)color {
    
    
    NSDictionary *prefs = nil;
    prefs = [[NSDictionary alloc] initWithContentsOfFile:COLOR]; // Load the plist

    //Is COLOR not existent?
    if (prefs == nil) { // create new plist
        [self createColorPreferences];
        // Load the plist again
        prefs = [[NSDictionary alloc] initWithContentsOfFile:COLOR];
    }
    
    //get the value of color
    NSString *value = [prefs objectForKey:@"color"];
    
    [prefs release];
    
    return value;
}

- (void)keyboardDidShow:(NSNotification *)notification {
    
    //keyboard has appeared. Check if tweak enabled and if the color chosen is anythin gbut the default color add a background with the chosen coour to the keyboard.
    GNBloard *prefs =  [[GNBloard alloc] init];
    if ([prefs isEnabled]) {
        if ([[prefs color] isEqualToString:@"Dark gray"]) {
           
            [prefs release];
            //create the  UIColor and frame
            UIColor *color = [UIColor darkGrayColor];
            // keyboard frame is in window coordinates
            NSDictionary *userInfo = [notification userInfo];
            CGRect keyboardFrame = [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
            
            //alloc and init the UIImageView and set it's backgroundColor
            imageView = [[UIImageView alloc] initWithFrame:keyboardFrame];
            imageView.backgroundColor = color;
            
            UIWindow *window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
            
            [window addSubview:imageView];
            [window bringSubviewToFront:imageView];
            
            return;
        } /*else  if ([prefs colour] == 3) {
            [prefs release];
            UIColor *color = [UIColor lightGrayColor];
            arg1 = color;
            return;
        } else  if ([prefs colour] == 4) {
            [prefs release];
            UIColor *color = [UIColor whiteColor];
            arg1 = color;
            return;
        } else  if ([prefs colour] == 5) {
            [prefs release];
            UIColor *color= [UIColor grayColor];
            arg1 = color;
            return;
        } else  if ([prefs colour] == 6) {
            [prefs release];
            UIColor *color = [UIColor redColor];
            arg1 = color;
            return;
        } else  if ([prefs colour] == 7) {
            [prefs release];
            UIColor *color = [UIColor greenColor];
            arg1 = color;
            return;
        } else  if ([prefs colour] == 8) {
            [prefs release];
            UIColor *color = [UIColor blueColor];
            arg1 = color;
            return;
        } else  if ([prefs colour] == 9) {
            [prefs release];
            UIColor *color = [UIColor cyanColor];
            arg1 = color;
            return;
        } else  if ([prefs colour] == 10) {
            [prefs release];
            UIColor *color = [UIColor yellowColor];
            arg1 = color;
            return;
        } else  if ([prefs colour] == 11) {
            [prefs release];
            UIColor *color = [UIColor magentaColor];
            arg1 = color;
            return;
        } else  if ([prefs colour] == 12) {
            [prefs release];
            UIColor *color = [UIColor orangeColor];
            arg1 = color;
            return;
        } else  if ([prefs colour] == 13) {
            [prefs release];
            UIColor *color = [UIColor purpleColor];
            arg1 = color;
            return;
        } else  if ([prefs colour] == 14) {
            [prefs release];
            UIColor *color = [UIColor brownColor];
            arg1 = color;
            return;
        }*/
    }
}

- (void)keyboardDidHide:(NSNotification *)notification {
    
    
}

- (void)dealloc {
   
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super dealloc];
}
    
@end


%hook UITextInputTraits

- (int) keyboardAppearance {
    
    GNBloard *prefs =  [[GNBloard alloc] init];
    //is the tweak enabled? if so is the color chosen the default lightblack colour? otherwise continue as normal.
    if ([prefs isEnabled]) {
        if ([[prefs color] isEqualToString:@"Black"]) {
            [prefs release];
            return 1;
        } else {
            
            [prefs release];
            return %orig;
        }
    } else {
        [prefs release];
        return %orig;
    }
}

%end

%ctor {
    GNBloard *gnbloard =  [[GNBloard alloc] init];
    
    // Listen for keyboard appearances and disappearances
    [[NSNotificationCenter defaultCenter] addObserver:gnbloard
                                             selector:@selector(keyboardDidShow:)
                                                 name:UIKeyboardDidShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:gnbloard
                                             selector:@selector(keyboardDidHide:)
                                                 name:UIKeyboardDidHideNotification
                                               object:nil];
}

