@interface BloardPreferencesListController: PSListController {
    
    id _specifiers;
}
@end

@implementation BloardPreferencesListController
- (id)specifiers {
	if(_specifiers == nil) {
		_specifiers = [[self loadSpecifiersFromPlistName:@"BloardPreferences" target:self] retain];
	}
	return _specifiers;
}

- (void)donation {
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=LAEUC26VGLX2N"]];

}

- (void)twitter {
    
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"twitter://user?screen_name=GN_OS"]]) {
        
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"twitter://user?screen_name=GN_OS"]];
    } else {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://twitter.com/GN_OS"]];
    }
}

@end

// vim:ft=objc
