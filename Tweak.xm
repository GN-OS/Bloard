static BOOL tweakIsEnabled(void);

//start specific tweak code

static BOOL accessoryExists = NO;
static BOOL isAllowedToSetAccessoryExistsForPickerView = YES;

static NSString *const preferencesFilePath = @"/var/mobile/Library/Preferences/com.gnos.bloard.plist";
#define preferencesChangedNotification "com.gnos.bloard.preferences.changed"

//////////////////

unsigned long long deepness = 0;

#define logStart0() do { NSLog(@"uroboro %d; %s {", deepness, __PRETTY_FUNCTION__); deepness++; } while (0)
#define logStart() do { NSLog(@"uroboro %lld; class: %@; method: %@; {", deepness, NSStringFromClass([self class]), NSStringFromSelector(_cmd)); deepness++; } while (0)
#define logEnd() do { deepness--; NSLog(@"uroboro; }%s", deepness?"":" //so deep"); } while (0)

#define logBlock(block) logStart(); block; logEnd();

%hook UIKeyboard
-(void)geometryChangeDone:(BOOL)arg1{
    if (tweakIsEnabled()) {
        if (arg1 == NO) {
            accessoryExists = NO;
            isAllowedToSetAccessoryExistsForPickerView = YES;
        } else {
            accessoryExists = YES;
            isAllowedToSetAccessoryExistsForPickerView = NO;
        }
    }
    
    return %orig(arg1);
}
%end

%hook UIKBRenderConfig

- (BOOL)lightKeyboard {
	BOOL r = %orig();
	if (tweakIsEnabled()) {
		r = NO;
	}
	return r;
}

%end

// dark PIN keypad in Settings
%hook DevicePINKeypad

-(id)initWithFrame:(CGRect)arg1 {
    id keypad = %orig;
    if (tweakIsEnabled()) {
		[self setBackgroundColor:[UIColor colorWithWhite:40/255.0 alpha:0.7]];
	}
	return keypad;
}

%end

//white UIPickerView text entries
@interface UIPickerTableViewTitledCell : UITableViewCell
-(void)setAttributedTitle:(NSAttributedString *)arg1;
@end

%hook UIPickerTableViewTitledCell

-(void)setAttributedTitle:(NSAttributedString *)arg1 {
	if (tweakIsEnabled()) {
		// white UIPickerView text
		NSAttributedString *title = [[NSAttributedString alloc] initWithString:[arg1 string] attributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];
		%orig(title);
	}9
	else {
		%orig(arg1);
	}
}

%end

// set whether UIWebFormAccessory is visible or not
%hook UIWebFormAccessory

-(void)layoutSubviews{
    //this if statement will alow us to determine if it was hidden or launched by a simple bool. The first part is it being shown and second hidden. This allows us to set accessoryExists
    if (isAllowedToSetAccessoryExistsForPickerView) {
        accessoryExists = YES;
        NSLog(@"        accessoryExists = YES;______________________________");
        isAllowedToSetAccessoryExistsForPickerView = NO;
        %orig;
    } else {
        accessoryExists = NO;
        NSLog(@"        accessoryExists = NO;______________________________");
        isAllowedToSetAccessoryExistsForPickerView = YES;
        %orig;
    }
}


//detect when the pickerView was killed through these buttons we use these to set the Bool used up there^^ to detect when it is shown
-(void)done:(id)arg1 {
    accessoryExists = NO;
    //set frame to make sure layoutSubviews gets caleld because it has to reset it
    [self setFrame:CGRectMake(0,0,0,0)];
    %orig(arg1);
}

%end

// white chevrons
%hook _UIToolbarNavigationButton

-(void)updateImageIfNeededWithTintColor:(UIColor *)arg1 {
	if (accessoryExists && tweakIsEnabled()) {
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
	if (accessoryExists && tweakIsEnabled()) {
		%orig([UIColor whiteColor]);
	}
	else {
		%orig(arg1);
	}
}

%end

//end of specific tweak code

//start general tweak code

#define CFNCAO(c, n) CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (c), CFSTR(n), NULL, CFNotificationSuspensionBehaviorCoalesce)
#define preferencesChanged() preferencesChangedCallback(NULL, NULL, NULL, NULL, NULL)

static NSDictionary *prefs = nil;

static void createPreferencessFileIfNonExistent(void) {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	if ([[NSFileManager defaultManager] fileExistsAtPath:preferencesFilePath]) {
		return;
	}
	NSDictionary *d = [[NSDictionary alloc] initWithObjects:[NSArray arrayWithObjects:[NSNumber numberWithBool:YES], nil] forKeys:[NSArray arrayWithObjects:@"enabled", nil]];
	[d writeToFile:preferencesFilePath atomically:YES];
	[d release];
	[pool release];
	return;
}

static void preferencesChangedCallback(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) {
	// reload prefs
	[prefs release];
	prefs = [[NSDictionary alloc] initWithContentsOfFile:preferencesFilePath];
}

static BOOL tweakIsEnabled(void) {
	NSAutoreleasePool *p = [[NSAutoreleasePool alloc] init];
	BOOL r = (prefs)? [[prefs objectForKey:@"enabled"] boolValue]:NO;
	[p release];
	return r;
}

%ctor {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	createPreferencessFileIfNonExistent();
	preferencesChanged(); //not really

	// register to receive changed notifications
	CFNCAO(preferencesChangedCallback, preferencesChangedNotification);

	[pool release];
}
