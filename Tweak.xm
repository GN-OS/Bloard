#define PREFSPLIST @"/var/mobile/Library/Preferences/com.gnos.bloard.plist"

static void createPrefsFile() {
    NSDictionary *d = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[NSNumber numberWithBool:YES],nil] forKeys:[NSArray arrayWithObjects:@"enabled",nil]];
    
    [d writeToFile:PREFSPLIST atomically:YES];
}

static BOOL isEnabled() {
    NSDictionary *prefs = [NSDictionary dictionaryWithContentsOfFile:PREFSPLIST]; // Load the plist
    
    //Is ENABLED not existent?
                           
    if (!prefs) { // create new plist
        createPrefsFile();
        // Load the plist again
        prefs = [NSDictionary dictionaryWithContentsOfFile:PREFSPLIST];
    }
    //get the value of enabled
    BOOL value = [[prefs objectForKey:@"enabled"] boolValue];
    return value;
}


%hook UIKBRenderConfig

- (BOOL) lightKeyboard {
    
    if (isEnabled()) {
        return NO;
    }
    return YES;
}

%end

%hook UITextInputTraits

- (int)keyboardAppearance {
    if (isEnabled()) {
        return 0;
    }
    return 1;
}

%end