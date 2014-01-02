#import <UIKit/UIKit.h>

%hook UITextInputTraits

- (int) keyboardAppearance {

    return 1;
    
}

%end