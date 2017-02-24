//
//  BYPhotoEditController.m
//  BYImagePicker
//
//  Created by Beryter on 2017/2/21.
//  Copyright © 2017年 Beryter. All rights reserved.
//

#import "BYPhotoEditController.h"
#import "UIView+BYLayout.h"
#import "BYClipListView.h"
#import "BYDefine.h"
#import "BYAsset.h"

@interface BYPhotoEditController ()
@property (nonatomic, strong) UIView *menuView;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIImage *originImage;
@property (nonatomic, assign) BOOL statusBarHidden;
@end

@implementation BYPhotoEditController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"裁剪";
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(didClickedCancelItem:)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"确定" style:UIBarButtonItemStylePlain target:self action:@selector(didClickedConfirmItem:)];
    
    [self.view addSubview:self.imageView];
    [self.view addSubview:self.menuView];
    
    __weak typeof(self) weakSelf = self;
    [self.asset fetchOriginImageCompletion:^(UIImage *image) {
        weakSelf.originImage = image;
        weakSelf.imageView.image = image;
        [weakSelf resizeImageView];
    }];
}

- (UIStatusBarAnimation)preferredStatusBarUpdateAnimation
{
    return UIStatusBarAnimationFade;
}

- (BOOL)prefersStatusBarHidden
{
    return self.statusBarHidden;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Action

- (void)didClickedCancelItem:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didClickedConfirmItem:(id)sender
{
    
}

- (void)didClickedTest:(id)sender
{
//    self.statusBarHidden = !self.statusBarHidden;
//    self.navigationController.navigationBar.hidden = self.statusBarHidden;
//    self.imageView.by_top = self.statusBarHidden ? 0 : 64;
//    self.statusBarHidden = self.statusBarHidden;;
//    [self setNeedsStatusBarAppearanceUpdate];
}

- (void)resizeImageView
{
    CGSize size = self.originImage.size;
    if (size.height / size.width > (self.view.by_height - 64*2) / self.view.by_width) {
        CGFloat multiplier = (self.view.by_height - 64*2) / size.height;
        CGFloat width = size.width * multiplier;
        self.imageView.frame = CGRectMake((self.view.by_width - width) / 2, 64, width, self.view.by_height - 64*2);
    } else {
        CGFloat multiplier = self.view.by_width / size.width;
        CGFloat height = size.height * multiplier;
        self.imageView.frame = CGRectMake(0, (self.view.by_height - height) / 2, self.view.by_width, height);
    }
}

#pragma mark - view

- (UIImageView *)imageView
{
    if (!_imageView) {
        _imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 64, self.view.by_width, self.view.by_height - 64 - 64)];
        _imageView.contentMode = UIViewContentModeScaleToFill;
    }
    return _imageView;
}

- (UIView *)menuView
{
    if (!_menuView) {
        
        _menuView = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.by_height - 64, self.view.by_width, 64)];
        _menuView.backgroundColor = RGBA(0x323740, 0.8);
        
        UIView *topLine = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.by_width, LineHeight)];
        topLine.backgroundColor = RGB(0xe5e5e5);
        [_menuView addSubview:topLine];
        
        BYClipListView *listView = [[BYClipListView alloc] initWithFrame:_menuView.bounds];
        [_menuView addSubview:listView];
    }
    return _menuView;
}
@end
