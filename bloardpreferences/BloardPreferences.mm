#import <Preferences/PSListController.h>

@interface BloardPreferencesListController: PSListController {
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
    
    /*if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"twitter://user?screen_name=GN_OS"]]) {
        
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"twitter://user?screen_name=GN_OS"]];
    } else {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://twitter.com/GN_OS"]];
    }*/
    
    UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Oops" message: @"This is Ge0rges I commented the part that launche twitetr because i wasn't able to test it just look in the .mm. It probably works but I didn't want to take any chances." delegate:nil cencelButtonTitle:@"Ok Ge0rges :|" otherButtontitles:nil, nil];
    
}

@end

// vim:ft=objc
