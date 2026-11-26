#import <Preferences/PSListController.h>

@interface XMFRootListController : PSListController
@end

@implementation XMFRootListController
- (NSArray *)specifiers {
    if (!_specifiers) {
        _specifiers = [self loadSpecifiersFromPlistName:@"Root" target:self];
    }
    return _specifiers;
}
- (void)respring {
    system("killall -9 SpringBoard");
}
@end
