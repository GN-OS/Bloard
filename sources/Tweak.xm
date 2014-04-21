#include "GNSharedCode.h"

static const char *bloardNotification = "com.gnos.bloard";
static const char *enabledKey = "enabled";

%ctor {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	GNOSpreferencesSetup(bloardNotification);
	[pool release];
}

//see MFMailComposeView %hook
static BOOL mailComposeViewIsOpen = NO;


// Dark keyboard background
%hook UIKBRenderConfig

- (BOOL)lightKeyboard {
	BOOL light = %orig();
	if (GNOSpreferencesGetBoolKey(bloardNotification, enabledKey)) {
		light = NO;
	}
	return light;
}

%end

// Dark PIN keypad in Settings
%hook DevicePINKeypad

- (id)initWithFrame:(CGRect)frame {
    id keypad = %orig();
    if (GNOSpreferencesGetBoolKey(bloardNotification, enabledKey)) {
		[keypad setBackgroundColor:[UIColor colorWithWhite:40/255.0 alpha:0.7]];
	}
	return keypad;
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
	if (GNOSpreferencesGetBoolKey(bloardNotification, enabledKey)) {
		// white UIPickerView text
		NSDictionary *attributes = @{ NSForegroundColorAttributeName: [UIColor whiteColor] };
		NSAttributedString *title = [[NSAttributedString alloc] initWithString:[attributedString string] attributes:attributes];
		%orig(title);
		[title release];
	} else {
		%orig();
	}
}

%end

//black background in mail compose pickerView
%hook UIPickerView

-(void)setBackgroundColor:(UIColor *)color {
    if (GNOSpreferencesGetBoolKey(bloardNotification, enabledKey) && mailComposeViewIsOpen) {
        %orig([UIColor colorWithWhite:40/255.0 alpha:0.7]);
    } else {
        %orig(color);
    }
}

%end

#if 0
@interface UIWebFormAccessory : UIInputView 
@end
#endif

%hook UIWebFormAccessory

// White chevrons
+ (id)toolbarWithItems:(NSArray *)items {
	if (GNOSpreferencesGetBoolKey(bloardNotification, enabledKey)) {
		for (UIBarButtonItem *item in items) {
			[item setTintColor:[UIColor whiteColor]];
		}
	}
	return %orig(items);
}

// White Done button
- (void)layoutSubviews {
	if (GNOSpreferencesGetBoolKey(bloardNotification, enabledKey)) {
		NSDictionary *attributes = @{NSForegroundColorAttributeName: [UIColor whiteColor]};
		//what is going on here? Why is this using a class method?
		[[UIBarButtonItem appearance] setTitleTextAttributes:attributes forState:0];
	}
	%orig();

}

%end

// We need to monitor when the Mail compose view is open so we can disable white UIPickerView text
// The UIPickerView it shows for From: email selection has a white background, and white text on white background is not pleasant :p
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
