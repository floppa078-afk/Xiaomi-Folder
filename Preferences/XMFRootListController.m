#import <Preferences/PSListController.h>
#import <spawn.h>

extern char **environ;

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
    pid_t pid = 0;
    char *const arguments[] = { (char *)"sbreload", NULL };
    posix_spawn(&pid, "/var/jb/usr/bin/sbreload", NULL, NULL, arguments, environ);
}

@end
