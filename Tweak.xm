#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

static NSString *const kXMFDefaults = @"com.floppa078afk.xiaomifolder";
static NSInteger XMFMode(void) {
    return [[NSUserDefaults standardUserDefaults] integerForKey:@"XMFMode"];
}

@interface SBFolderIcon : UIView
@end

@interface SBFolderIconImageView : UIView
@end

%group XiaomiFolder

%hook SBFolderIconImageView

- (CGRect)bounds {
    CGRect bounds = %orig;
    NSInteger mode = XMFMode();

    if (mode == 1) {
        bounds.size.width *= 1.10;
        bounds.size.height *= 1.10;
    } else if (mode == 2) {
        bounds.size.width *= 1.28;
        bounds.size.height *= 1.28;
    }

    return bounds;
}

%end

%end

%ctor {
    NSUserDefaults *defaults = [[NSUserDefaults alloc] initWithSuiteName:kXMFDefaults];
    NSInteger mode = [defaults integerForKey:@"XMFMode"];
    if (mode >= 0) {
        %init(XiaomiFolder);
    }
}
