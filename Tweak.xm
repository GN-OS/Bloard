#include <CoreFoundation/CFNotificationCenter.h>
#import <Foundation/NSUserDefaults.h>
#import <Foundation/NSString.h>

@interface NSUserDefaults (UFS_Category)
- (id)objectForKey:(NSString *)key inDomain:(NSString *)domain;
- (void)setObject:(id)value forKey:(NSString *)key inDomain:(NSString *)domain;
@end

static NSString *domainString = @"com.gnos.bloard";
static NSString *notificationString = @"com.gnos.bloard/preferences.changed";
static BOOL enabled;

static void notificationCallback(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) {
	NSNumber *n = (NSNumber *)[[NSUserDefaults standardUserDefaults] objectForKey:@"enabled" inDomain:domainString];
	enabled = (n)? [n boolValue]:YES;
}

%ctor {
	NSAutoreleasePool *pool = [NSAutoreleasePool new];
	//set initial `enable' variable
	notificationCallback(NULL, NULL, NULL, NULL, NULL);

	//register for notifications
	CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, notificationCallback, (CFStringRef)notificationString, NULL, CFNotificationSuspensionBehaviorCoalesce);
	[pool release];
}

// Black background in pickerView
%hook UIPickerView

-(void)setBackgroundColor:(UIColor *)color {
	if (enabled) {
		color = [UIColor colorWithWhite:40.0/255 alpha:0.7];
	}
    %orig(color);
}

%end

%hook UIDatePickerContentView

// White text in date picker
-(UILabel *)titleLabel {
    if (enabled) {
        // white UIPickerView text
        UILabel *titleLabel = %orig();
        titleLabel.textColor = [UIColor whiteColor];
        return titleLabel;

    } else {
        return %orig();
    }
}

%end

// White UIPickerView text entries

%hook UIPickerTableViewTitledCell

- (void)setAttributedTitle:(NSAttributedString *)attributedString {
	if (enabled) {
		// white UIPickerView text
		NSAttributedString *title = [[NSAttributedString alloc] initWithString:[attributedString string] attributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];
		%orig(title);
		[title release];
        
	} else {
		%orig();
	}
}

%end

// Dark keyboard background
%hook UIKBRenderConfig

- (BOOL)lightKeyboard {
	BOOL light = %orig();
	if (enabled) {
		light = NO;
	}
	return light;
}

%end

// Dark PIN keypad in Settings
%hook DevicePINKeypad

- (id)initWithFrame:(CGRect)frame {
	id keypad = %orig();
	if (enabled) {
		[keypad setBackgroundColor:[UIColor colorWithWhite:40.0/255 alpha:0.7]];
	}
	return keypad;
}

%end