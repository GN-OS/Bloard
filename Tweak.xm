#import "substrate.h"
#import "preferences.h"

//start specific tweak code

static NSString *const preferencesFilePath = @"/var/mobile/Library/Preferences/com.gnos.bloard.plist";
#define preferencesChangedNotification "com.gnos.bloard.preferences.changed"

unsigned long long deepness = 0;

#define logStart0() do { NSLog(@"uroboro %d; %s {", deepness, __PRETTY_FUNCTION__); deepness++; } while (0)
#define logStart() do { NSLog(@"uroboro %lld; class: %@; method: %@; {", deepness, NSStringFromClass([self class]), NSStringFromSelector(_cmd)); deepness++; } while (0)
#define logEnd() do { deepness--; NSLog(@"uroboro; }%s", deepness?"":" //so deep"); } while (0)

#define logBlock(block) logStart(); block; logEnd();

// Dark keyboard background
%hook UIKBRenderConfig

- (BOOL)lightKeyboard {
	BOOL light = %orig();
	if (tweakIsEnabled()) {
		light = NO;
	}
	return light;
}

%end

// Dark PIN keypad in Settings
%hook DevicePINKeypad

-(id)initWithFrame:(CGRect)arg1 {
    id keypad = %orig;
    if (tweakIsEnabled()) {
		[self setBackgroundColor:[UIColor colorWithWhite:40/255.0 alpha:0.7]];
	}
	return keypad;
}

%end

// White UIPickerView text entries
@interface UIPickerTableViewTitledCell : UITableViewCell
-(void)setAttributedTitle:(NSAttributedString *)arg1;
@end

%hook UIPickerTableViewTitledCell

-(void)setAttributedTitle:(NSAttributedString *)arg1 {
	if (tweakIsEnabled()) {
		// white UIPickerView text
		NSAttributedString *title = [[NSAttributedString alloc] initWithString:[arg1 string] attributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];
		%orig(title);
	}
	else {
		%orig(arg1);
	}
}

%end

// White chevrons and done button
%hook UIWebFormAccessory

-(void)layoutSubviews {
    %orig;
    if (tweakIsEnabled()) {
    	// Previous chevron
   		UIBarButtonItem *item = MSHookIvar<UIBarButtonItem *>(self, "_previousItem");
		[item setTintColor: [UIColor whiteColor]];
		// Next chevron
		item = MSHookIvar<UIBarButtonItem *>(self, "_nextItem");
		[item setTintColor: [UIColor whiteColor]];
	}
}

%end