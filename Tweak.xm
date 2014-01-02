#import <UIKit/UITextInputTraits.h>

%hook UITextInputTraits

- (int) keyboardAppearance {

    return 1;
    
}

%end