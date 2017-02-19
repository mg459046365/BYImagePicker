//
//  BYImagePickerController.m
//  BYImagePicker
//
//  Created by Beryter on 2017/2/13.
//  Copyright © 2017年 Beryter. All rights reserved.
//

#import "BYImagePickerController.h"
#import "BYPhotoPickerController.h"
#import "BYAlbumPickerController.h"
#import "BYPickerRootController.h"
#import "BYImageManager.h"
#import "BYAlbum.h"

@interface BYImagePickerController ()

@end

@implementation BYImagePickerController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationBar.translucent = NO;
    self.navigationBar.barTintColor = RGB(0xf1f1f1);
    self.navigationBar.titleTextAttributes = @{NSFontAttributeName:[UIFont systemFontOfSize:17],
                                               NSForegroundColorAttributeName:RGB(0x666666)};
    self.navigationBar.tintColor = RGB(0x999999);
    self.navigationBar.translucent = YES;
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.view.backgroundColor = [UIColor whiteColor];
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"yogaMusicDefaultIcon" ofType:@"png"];
    UIImage *image = [UIImage imageWithContentsOfFile:path];
    UIImageView *view = [[UIImageView alloc] init];
    view.frame = self.view.bounds;
    view.image = image;
    view.contentMode = UIViewContentModeScaleAspectFill;
    view.clipsToBounds = YES;
    [self.view addSubview:view];
    [self.view sendSubviewToBack:view];
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}
- (void)dealloc
{
    NSLog(@"图片选择器释放");
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (instancetype)init
{
    BYPickerRootController *rootController = [[BYPickerRootController alloc] init];
    if (self = [super initWithRootViewController:rootController]) {
        [self configureData];
    }
    return self;
}

- (void)configureData
{
    _maxImagesCount = 9;
    _columnNumber = 4;
    [[BYImageManager manager].selectedAssets removeAllObjects];
    [BYImageManager manager].maxImagesCount = 9;
}

- (void)setMaxImagesCount:(NSInteger)maxImagesCount
{
    _maxImagesCount = maxImagesCount >0 ? maxImagesCount : 9;
    [BYImageManager manager].maxImagesCount = _maxImagesCount;
}

//- (void)setBarItemTextFont:(UIFont *)barItemTextFont
//{
//    _barItemTextFont = barItemTextFont;
//    [self configBarButtonItemAppearance];
//}
//- (void)setBarItemTextColor:(UIColor *)barItemTextColor
//{
//    _barItemTextColor = barItemTextColor;
//    [self configBarButtonItemAppearance];
//}

- (void)configBarButtonItemAppearance {
    UIBarButtonItem *barItem;
    if (iOS9Later) {
        barItem = [UIBarButtonItem appearanceWhenContainedInInstancesOfClasses:@[[BYImagePickerController class]]];
    } else {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        barItem = [UIBarButtonItem appearanceWhenContainedIn:[BYImagePickerController class], nil];
#pragma clang diagnostic pop
    }
    NSMutableDictionary *textAttrs = [NSMutableDictionary dictionary];
//    textAttrs[NSForegroundColorAttributeName] = self.barItemTextColor;
//    textAttrs[NSFontAttributeName] = self.barItemTextFont;
    [barItem setTitleTextAttributes:textAttrs forState:UIControlStateNormal];
}

@end
