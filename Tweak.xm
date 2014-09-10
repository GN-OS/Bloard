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

// We need to monitor when the Mail compose view is open so we can disable white UIPickerView text
// The UIPickerView it shows for `From: email' selection has a white background, and white text on white background is not pleasant :p
static BOOL mailComposeViewIsOpen = NO;

%hook MFMailComposeView

- (void)layoutSubviews {
	mailComposeViewIsOpen = YES;
	%orig();
}

- (void)willDisappear {
	mailComposeViewIsOpen = NO;
	%orig();
}

%end

// Black background in mail compose pickerView
%hook UIPickerView

-(void)setBackgroundColor:(UIColor *)color {
	if (enabled && mailComposeViewIsOpen) {
		%orig([UIColor colorWithWhite:40.0/255 alpha:0.7]);
	} else {
		%orig();
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

%hook UIWebFormAccessory

// White chevrons
+ (id)toolbarWithItems:(NSArray *)items {
	if (enabled) {
		for (UIBarButtonItem *item in items) {
			[item setTintColor:[UIColor whiteColor]];
		}
	}
	return %orig();
}

// White Done button
- (void)layoutSubviews {
	if (enabled) {
		[[UIBarButtonItem appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]} forState:0];
	}
	%orig();
}

%end
