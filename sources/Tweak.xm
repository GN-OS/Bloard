#include "UFSSharedCode.h"

static const char *bloardNotification = "com.gnos.bloard";
static const char *enabledKey = "enabled";

static BOOL enabled;

notificationCallback() {
	NSNumber *n = (NSNumber *)NSPGetKey(bloardNotification, enabledKey);
	enabled = (n)? [n boolValue]:YES;
}

%ctor {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	//set initial `enable' variable
	NSNumber *n = (NSNumber *)NSPGetKey(bloardNotification, enabledKey);
	enabled = (n)? [n boolValue]:YES;
	//register for notifications
	CFNCAddObserver(bloardNotification, notificationCallback);
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
        %orig(color);
    }
}

%end

// White UIPickerView text entries
#if 0
@interface UIPickerTableViewTitledCell : UITableViewCell
-(void)setAttributedTitle:(NSAttributedString *)attributedString;
@end
#endif

%hook UIPickerTableViewTitledCell

- (void)setAttributedTitle:(NSAttributedString *)attributedString {
	if (enabled) {
		// white UIPickerView text
		NSDictionary *attributes = @{NSForegroundColorAttributeName:[UIColor whiteColor]};
		NSAttributedString *title = [[NSAttributedString alloc] initWithString:[attributedString string] attributes:attributes];
		%orig(title);
		[title release];
	} else {
		%orig(attributedString);
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
    id keypad = %orig(frame);
    if (enabled) {
		[keypad setBackgroundColor:[UIColor colorWithWhite:40.0/255 alpha:0.7]];
	}
	return keypad;
}

%end

#if 0
@interface UIWebFormAccessory : UIInputView 
@end
#endif

%hook UIWebFormAccessory

// White chevrons
+ (id)toolbarWithItems:(NSArray *)items {
	if (enabled) {
		for (UIBarButtonItem *item in items) {
			[item setTintColor:[UIColor whiteColor]];
		}
	}
	return %orig(items);
}

// White Done button
- (void)layoutSubviews {
	if (enabled) {
		NSDictionary *attributes = @{NSForegroundColorAttributeName:[UIColor whiteColor]};
		//what is going on here? Why is this using a class method?
		[[UIBarButtonItem appearance] setTitleTextAttributes:attributes forState:0]; //can we get an enum for the state?
	}
	%orig();
}

%end
