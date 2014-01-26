//notifications!
#define registerNotification(c, n) CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (c), CFSTR(n), NULL, CFNotificationSuspensionBehaviorCoalesce);
#define PreferencesChangedNotification "com.gnos.bloard.prefs-changed"
#define PreferencesFilePath @"/var/mobile/Library/Preferences/com.gnos.bloard.plist"

static NSDictionary *prefs = nil;

static void prefsChanged(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) {
	// reload prefs
	[prefs release];
	if ((prefs = [[NSDictionary alloc] initWithContentsOfFile:PreferencesFilePath]) == nil) {
		prefs = @{@"enabled": @YES};
		[prefs writeToFile:PreferencesFilePath atomically:YES];
		prefs = [[NSDictionary alloc] initWithContentsOfFile:PreferencesFilePath];
	}
}


static BOOL isEnabled(void) {
	return (prefs) ? [prefs[@"enabled"] boolValue] : NO; 
}

//make keyboard black
%hook UIKBRenderConfig

- (BOOL)lightKeyboard {
	BOOL isLight = %orig();
	if (isEnabled()) {
		isLight = NO;
	}
	return isLight;
}

%end

//make pickerView text black
@interface UIPickerTableViewTitledCell : UITableViewCell
-(void)setAttributedTitle:(NSAttributedString *)arg1;
@end

%hook UIPickerTableViewTitledCell

-(void)setAttributedTitle:(NSAttributedString *)arg1 {
	if (isEnabled()) {
		NSAttributedString *title = [[NSAttributedString alloc] initWithString:[arg1 string] attributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];
		%orig(title);
	}
	else {
		%orig(arg1);
	}
}

%end

//make settings keypad black
%hook UIKeyboard

-(id)initWithFrame:(CGRect)arg1 {
    id meow = %orig;//variable name courtesy of fr0st
    if (isEnabled()) {
        [self setBackgroundColor:[UIColor blackColor]];
    }
    return meow;
}
%end

//register for notifications
%ctor {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	prefsChanged(NULL, NULL, NULL, NULL, NULL); // initialize prefs
	// register to receive changed notifications
	registerNotification(prefsChanged, PreferencesChangedNotification);
	[pool release];
}
