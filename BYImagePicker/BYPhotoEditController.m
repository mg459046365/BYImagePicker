//
//  BYPhotoEditController.m
//  BYImagePicker
//
//  Created by Beryter on 2017/2/21.
//  Copyright © 2017年 Beryter. All rights reserved.
//

#import "BYPhotoEditController.h"
#import "BYCropTestController.h"
#import "UIImage+BYImageCrop.h"
#import "UIView+BYLayout.h"
#import "BYClipListView.h"
#import "BYClipTopView.h"
#import "BYDefine.h"
#import "BYAsset.h"

@interface BYPhotoEditController ()
@property (nonatomic, strong) UIView *menuView;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIImage *originImage;
@property (nonatomic, assign) BOOL statusBarHidden;
@property (nonatomic, strong) BYClipTopView *clipView;
@end

@implementation BYPhotoEditController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"裁剪";
    self.view.backgroundColor = [UIColor blueColor];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(didClickedCancelItem:)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"确定" style:UIBarButtonItemStylePlain target:self action:@selector(didClickedConfirmItem:)];
    
    [self.view addSubview:self.imageView];
    [self.view addSubview:self.menuView];
    
    __weak typeof(self) weakSelf = self;
    [self.asset fetchImageCompletion:^(UIImage *image) {
        weakSelf.originImage = image;
        weakSelf.imageView.image = image;
        [weakSelf resizeImageView];
    }];
    
    self.imageView.userInteractionEnabled = YES;
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

- (void)selectedWidthRate:(NSInteger)widthRate heightRate:(NSInteger)heightRate
{
    CGSize size = self.imageView.by_size;
    CGSize tmpSize = size;
    if (widthRate / heightRate > size.width / size.height) {
        tmpSize.height = size.width * heightRate / widthRate;
        if (tmpSize.height > size.height) {
            tmpSize.height = size.height;
            tmpSize.width = size.height * widthRate / heightRate;
        }
    }else{
        tmpSize.width = size.height * widthRate / heightRate;
        if (tmpSize.width > size.width) {
            tmpSize.width = size.width;
            tmpSize.height = size.width * heightRate / widthRate;
        }
    }
    
    CGRect frame = CGRectMake((self.imageView.by_width - tmpSize.width)/2, (self.imageView.by_height - tmpSize.height)/2, tmpSize.width, tmpSize.height);
    
    if (self.clipView) {
        self.clipView.clipRect = frame;
    }else{
        self.clipView = [[BYClipTopView alloc] initWithFrame:self.imageView.bounds clipRect:frame];
        self.clipView.userInteractionEnabled = YES;
        [self.imageView addSubview:self.clipView];
    }
    self.clipView.widthRate = widthRate;
    self.clipView.heightRate = heightRate;
}

- (void)didClickedCancelItem:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didClickedConfirmItem:(id)sender
{
    CGFloat zoomScale = self.imageView.by_width / self.imageView.image.size.width;
    CGRect rct = self.clipView.clipRect;
    rct.size.width  /= zoomScale;
    rct.size.height /= zoomScale;
    rct.origin.x    /= zoomScale;
    rct.origin.y    /= zoomScale;
    UIImage *cropImage = [self.originImage crop:rct];
    
    BYCropTestController *test = [[BYCropTestController alloc] init];
    test.image = cropImage;
    [self.navigationController pushViewController:test animated:YES];
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
        __weak typeof(self) weakSelf = self;
        listView.selectedClipRate = ^(NSInteger widthRate,NSInteger heightRate)
        {
            [weakSelf selectedWidthRate:widthRate heightRate:heightRate];
        };
        [_menuView addSubview:listView];
    }
    return _menuView;
}
@end
