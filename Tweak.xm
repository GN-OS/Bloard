#define registerNotification(c, n) CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (c), CFSTR(n), NULL, CFNotificationSuspensionBehaviorCoalesce);
#define PreferencesChangedNotification "com.gnos.bloard.prefs-changed"
#define PreferencesFilePath @"/var/mobile/Library/Preferences/com.gnos.bloard.plist"

static NSDictionary *prefs = nil;

static void prefsChanged(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) {
	// reload prefs
	[prefs release];
	if ((prefs = [[NSDictionary alloc] initWithContentsOfFile:PreferencesFilePath]) == nil) {
		prefs = @{@"enabled": @NO};
		[prefs writeToFile:PreferencesFilePath atomically:YES];
		prefs = [[NSDictionary alloc] initWithContentsOfFile:PreferencesFilePath];
	}
}


static BOOL isEnabled(void) {
	return (prefs) ? [prefs[@"enabled"] boolValue] : NO; 
}

// used to track the state of UIWebFormAccessory
static BOOL accessoryExists = NO;
static BOOL isAllowedToSetAccessoryExists = YES;

// dark keyboard
%hook UIKBRenderConfig

-(BOOL)lightKeyboard {
	BOOL isLight = %orig;
	if (isEnabled()) {
        %log(@"BloardUSShouldBeBlack");
		isLight = NO;
	} else {
        %log(@"BloardUSShouldBeWhite");
    }
	return isLight;
}

%end

// dark PIN keypad in Settings
%hook DevicePINKeypad

-(id)initWithFrame:(CGRect)arg1 {
    id keypad = %orig;
    if (isEnabled()) {
		[self setBackgroundColor:[UIColor colorWithRed:40.0/255.0f green:40.0/255.0f blue:40.0/255.0f alpha:1.0f]];
	}
	return keypad;
}

%end

// white UIPickerView text entries
@interface UIPickerTableViewTitledCell : UITableViewCell
-(void)setAttributedTitle:(NSAttributedString *)arg1;
@end

%hook UIPickerTableViewTitledCell

-(void)setAttributedTitle:(NSAttributedString *)arg1 {
	if (isEnabled()) {
		// white UIPickerView text
		NSAttributedString *title = [[NSAttributedString alloc] initWithString:[arg1 string] attributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];
		%orig(title);
	}
	else {
		%orig(arg1);
	}
}

%end

// set whether UIWebFormAccessory is visible or not
%hook UIWebFormAccessory

-(void)layoutSubviews{
    if (isAllowedToSetAccessoryExists) {
        accessoryExists = YES;
        isAllowedToSetAccessoryExists = NO;
        %log(@"BloardUS");
        %orig;
    } else {
        accessoryExists = NO;
        isAllowedToSetAccessoryExists = YES;
        %log(@"BloardUS");
        %orig;
    }
}


//to here these methods are only called the first time UIWebFormAccessory is created but we need somehting that is called each time a pickerView is shown (each time it is active)
-(void)_previousTapped:(id)arg1 {
	accessoryExists = NO;
    %log(@"BloardUS");
    [self setFrame:CGRectMake(0,0,0,0)];
	%orig(arg1);
}
-(void)_nextTapped:(id)arg1 {
    accessoryExists = NO;
    %log(@"BloardUS");
    [self setFrame:CGRectMake(0,0,0,0)];
	%orig(arg1);
}

-(void)done:(id)arg1 {
    accessoryExists = NO;
    %log(@"BloardUS");
    [self setFrame:CGRectMake(0,0,0,0)];
    %orig(arg1);
}

%end

// white chevrons
%hook _UIToolbarNavigationButton

-(void)updateImageIfNeededWithTintColor:(UIColor *)arg1 {
	if (accessoryExists && isEnabled()) {
		%orig([UIColor whiteColor]);
	}
	else {
		%orig(arg1);
	}
}

%end

// white Done button
%hook UIButtonLabel

-(void)setTextColor:(UIColor *)arg1 {
	if (accessoryExists && isEnabled()) {
		%orig([UIColor whiteColor]);
	}
	else {
		%orig(arg1);
	}
}

%end

%ctor {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	prefsChanged(NULL, NULL, NULL, NULL, NULL); // initialize prefs
	// register to receive changed notifications
	registerNotification(prefsChanged, PreferencesChangedNotification);
	[pool release];
}
