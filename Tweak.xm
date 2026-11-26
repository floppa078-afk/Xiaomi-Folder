#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <objc/runtime.h>

static NSString *const kXMFDefaultsDomain = @"com.floppa078afk.xiaomifolder";
static NSString *const kXMFModeKey = @"XMFMode";
static const void *kXMFContainerKey = &kXMFContainerKey;

static NSInteger XMFCurrentMode(void) {
    NSUserDefaults *defaults =
        [[NSUserDefaults alloc] initWithSuiteName:kXMFDefaultsDomain];
    NSInteger mode = [defaults integerForKey:kXMFModeKey];
    return (mode >= 0 && mode <= 2) ? mode : 0;
}

@interface SBIcon : NSObject
- (void)launchFromLocation:(id)location context:(id)context;
@end

@interface SBFolder : NSObject
- (NSArray<SBIcon *> *)icons;
@end

@interface SBFolderIcon : SBIcon
- (SBFolder *)folder;
- (NSUInteger)gridSizeClass;
@end

@interface SBFolderIconImageView : UIView
- (SBFolderIcon *)folderIcon;
@end

@interface SBFolderIconView : UIView
- (SBFolderIcon *)folderIcon;
- (SBFolderIconImageView *)folderIconImageView;
@end

@interface XMFFolderGridView : UIView
@property (nonatomic, weak) SBFolderIcon *folderIcon;
@property (nonatomic, assign) NSInteger mode;
- (void)reloadIcons;
@end

@implementation XMFFolderGridView

- (void)reloadIcons {
    for (UIView *subview in [self.subviews copy]) {
        [subview removeFromSuperview];
    }

    if (!self.folderIcon || self.mode == 0) {
        return;
    }

    NSArray<SBIcon *> *icons = self.folderIcon.folder.icons;
    if (icons.count == 0) {
        return;
    }

    NSInteger gridDim = (self.mode == 2) ? 3 : 2;
    NSInteger largeCount = (gridDim * gridDim) - 1;

    CGFloat padding = (gridDim == 3) ? 12.0 : 14.0;
    CGFloat spacing = (gridDim == 3) ? 10.0 : 12.0;
    CGFloat totalW = self.bounds.size.width;
    CGFloat totalH = self.bounds.size.height;

    if (totalW <= 0 || totalH <= 0) {
        return;
    }

    CGFloat cellW =
        (totalW - padding * 2 - spacing * (gridDim - 1)) / gridDim;
    CGFloat cellH =
        (totalH - padding * 2 - spacing * (gridDim - 1)) / gridDim;
    CGFloat iconSize = MIN(cellW, cellH);

    for (NSInteger i = 0;
         i < largeCount && i < (NSInteger)icons.count;
         i++) {
        NSInteger row = i / gridDim;
        NSInteger col = i % gridDim;

        CGRect frame = CGRectMake(
            padding + col * (iconSize + spacing),
            padding + row * (iconSize + spacing),
            iconSize,
            iconSize
        );

        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = frame;
        button.tag = i;
        button.layer.cornerRadius = iconSize * 0.225;
        button.clipsToBounds = YES;

        SBIcon *appIcon = icons[i];
        UIImage *image = nil;

        @try {
            image = [appIcon valueForKey:@"iconImage"];
        } @catch (__unused NSException *exception) {
            image = nil;
        }

        if (image) {
            [button setImage:image forState:UIControlStateNormal];
        }

        [button addTarget:self
                   action:@selector(xmfAppTapped:)
         forControlEvents:UIControlEventTouchUpInside];

        [self addSubview:button];
    }

    if ((NSInteger)icons.count > largeCount) {
        NSInteger lastIdx = gridDim - 1;
        CGRect miniBox = CGRectMake(
            padding + lastIdx * (iconSize + spacing),
            padding + lastIdx * (iconSize + spacing),
            iconSize,
            iconSize
        );

        UIView *miniContainer = [[UIView alloc] initWithFrame:miniBox];
        miniContainer.userInteractionEnabled = NO;
        [self addSubview:miniContainer];

        CGFloat miniSpacing = 4.0;
        CGFloat miniSize = (iconSize - miniSpacing) / 2.0;

        for (NSInteger j = 0; j < 4; j++) {
            NSInteger iconIndex = largeCount + j;
            if (iconIndex >= (NSInteger)icons.count) {
                break;
            }

            NSInteger miniRow = j / 2;
            NSInteger miniCol = j % 2;

            UIImageView *imageView = [[UIImageView alloc] initWithFrame:
                CGRectMake(
                    miniCol * (miniSize + miniSpacing),
                    miniRow * (miniSize + miniSpacing),
                    miniSize,
                    miniSize
                )
            ];

            imageView.layer.cornerRadius = miniSize * 0.225;
            imageView.clipsToBounds = YES;

            UIImage *image = nil;
            @try {
                image = [icons[iconIndex] valueForKey:@"iconImage"];
            } @catch (__unused NSException *exception) {
                image = nil;
            }

            if (image) {
                imageView.image = image;
            }

            [miniContainer addSubview:imageView];
        }
    }
}

- (void)xmfAppTapped:(UIButton *)sender {
    NSArray<SBIcon *> *icons = self.folderIcon.folder.icons;

    if (sender.tag >= (NSInteger)icons.count) {
        return;
    }

    SBIcon *icon = icons[sender.tag];
    if ([icon respondsToSelector:@selector(launchFromLocation:context:)]) {
        [icon launchFromLocation:@"SBIconLocationRoot" context:nil];
    }
}

@end

%group XiaomiFolder

%hook SBFolderIcon

- (NSUInteger)gridSizeClass {
    NSInteger mode = XMFCurrentMode();

    if (mode == 1) {
        return 1;
    }

    if (mode == 2) {
        return 2;
    }

    return %orig;
}

%end

%hook SBFolderIconView

- (void)layoutSubviews {
    %orig;

    NSInteger mode = XMFCurrentMode();
    SBFolderIconImageView *imageView = [self folderIconImageView];

    if (!imageView) {
        return;
    }

    XMFFolderGridView *gridView =
        objc_getAssociatedObject(self, kXMFContainerKey);

    if (mode == 0) {
        if (gridView) {
            gridView.hidden = YES;
        }

        for (UIView *subview in imageView.subviews) {
            subview.hidden = NO;
        }

        return;
    }

    for (UIView *subview in imageView.subviews) {
        if (subview != gridView) {
            subview.hidden = YES;
        }
    }

    if (!gridView) {
        gridView = [[XMFFolderGridView alloc] initWithFrame:imageView.bounds];
        gridView.autoresizingMask =
            UIViewAutoresizingFlexibleWidth |
            UIViewAutoresizingFlexibleHeight;

        [imageView addSubview:gridView];

        objc_setAssociatedObject(self,
                                 kXMFContainerKey,
                                 gridView,
                                 OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }

    gridView.hidden = NO;
    gridView.frame = imageView.bounds;
    gridView.folderIcon = [self folderIcon];
    gridView.mode = mode;
    [gridView reloadIcons];
}

%end

%end

%ctor {
    %init(XiaomiFolder);
}
