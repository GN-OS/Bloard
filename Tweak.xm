#define PreferencesFile @"/var/mobile/Library/Preferences/com.gnos.bloard.plist"

static void createPrefsFile() {
    NSDictionary *d = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[NSNumber numberWithBool:YES],nil] forKeys:[NSArray arrayWithObjects:@"enabled",nil]];
    [d writeToFile:PreferencesFile atomically:YES];
}

static BOOL isEnabled() {
    NSDictionary *prefs = [NSDictionary dictionaryWithContentsOfFile:PreferencesFile]; // Load the plist
    
    //Is ENABLED not existent?
                           
    if (!prefs) { // create new plist
        createPrefsFile();
        // Load the plist again
        prefs = [NSDictionary dictionaryWithContentsOfFile:PreferencesFile];
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
