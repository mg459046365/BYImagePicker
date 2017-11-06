//
//  BYPickerRootController.m
//  BYImagePicker
//
//  Created by Beryter on 2017/2/17.
//  Copyright © 2017年 Beryter. All rights reserved.
//

#import "BYPickerRootController.h"
#import "BYImagePickerController.h"
#import "BYPhotoPickerController.h"
#import "BYAlbumPickerController.h"
#import "UIView+BYLayout.h"
#import "BYImageManager.h"
#import "BYDefine.h"

@interface BYPickerRootController ()
@property (nonatomic, strong) BYPhotoPickerController *photoController;
@property (nonatomic, strong) BYAlbumPickerController *albumController;
@property (nonatomic, strong) UIViewController *currentController;
@property (nonatomic, strong) UIButton *rightButton;
@property (nonatomic, strong) UIView *titleView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIImageView *titleImageView;
@end

@implementation BYPickerRootController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.view.backgroundColor = [UIColor whiteColor];
    _photoController = [[BYPhotoPickerController alloc] init];
    _photoController.firstItemIsCamera = YES;
    _photoController.columnNumber = 3;
    __weak typeof(self) weakSelf = self;
    _photoController.updateAssetCount = ^{
        NSString *title = [NSString stringWithFormat:@"%@/%@继续",@([BYImageManager manager].selectedAssetsCount),@([BYImageManager manager].maxPhotoCount)];
        [weakSelf.rightButton setTitle:title forState:UIControlStateNormal];
    };
    BYAlbum *album = [BYImageManager fetchCameraRollAlbumMediaType:PHAssetMediaTypeImage];
    _photoController.album = album;
    _photoController.view.frame = self.view.bounds;
    _currentController = _photoController;
    [self addChildViewController:_photoController];
    [_photoController didMoveToParentViewController:self];
    [self.view addSubview:_photoController.view];
    
    _albumController = [[BYAlbumPickerController alloc] init];
    _albumController.columnNumber = 4;
    _albumController.mediaType = PHAssetMediaTypeImage;
    _albumController.view.frame = self.view.bounds;
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(didClickedLeftItem:)];
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setTitle:@"相册" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [button sizeToFit];
    [button addTarget:self action:@selector(didClickedTitleButton:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.titleView = self.titleView;
    
    self.rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.rightButton setTitle:[NSString stringWithFormat:@"0/%@继续",@([BYImageManager manager].maxPhotoCount)] forState:UIControlStateNormal];
    [self.rightButton setTitleColor:RGB(0x00aaf7) forState:UIControlStateNormal];
    self.rightButton.titleLabel.font = [UIFont systemFontOfSize:15.0f];
    [self.rightButton sizeToFit];
    [self.rightButton addTarget:self action:@selector(didClickedRightButton:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.rightButton];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    NSString *title = [NSString stringWithFormat:@"%@/%@继续",@([BYImageManager manager].selectedAssetsCount),@([BYImageManager manager].maxPhotoCount)];
    [self.rightButton setTitle:title forState:UIControlStateNormal];
    [self.rightButton sizeToFit];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)didClickedRightButton:(id)sender
{
    BYImagePickerController *picker = (BYImagePickerController *)self.navigationController;
    if ([BYImageManager manager].selectedAssets.count == 0) {
        if (picker.pickerDelegate && [picker.pickerDelegate respondsToSelector:@selector(by_imagePickerController:didFinishPickedAssets:)]) {
            [picker.pickerDelegate by_imagePickerController:picker didFinishPickedAssets:[BYImageManager manager].selectedAssets];
        }
        [[BYImageManager manager] clear];
        [picker dismissViewControllerAnimated:YES completion:nil];
    }else{
        [self fetchOriginPhotos];
    }
}

- (void)fetchOriginPhotos
{
    NSArray *array = [BYImageManager manager].selectedAssets;
    NSMutableArray *tmpArray = [NSMutableArray arrayWithArray:array];
    dispatch_group_t group = dispatch_group_create();
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    for (NSInteger i = 0;i < array.count;i++) {
        BYAsset *asset = array[i];
        dispatch_group_async(group, queue, ^{
            [asset fetchImageCompletion:^(UIImage *image) {
                [tmpArray replaceObjectAtIndex:i withObject:image];
            }];
        });
    }
    __weak typeof(self) weakSelf = self;
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        BYImagePickerController *picker = (BYImagePickerController *)weakSelf.navigationController;
        if (picker.pickerDelegate && [picker.pickerDelegate respondsToSelector:@selector(by_imagePickerController:didFinishPickedAssets:)]) {
            [picker.pickerDelegate by_imagePickerController:picker didFinishPickedAssets:tmpArray];
        }
        [[BYImageManager manager] clear];
        [picker dismissViewControllerAnimated:YES completion:nil];
    });
}

- (void)didClickedLeftItem:(id)sender
{
    BYImagePickerController *picker = (BYImagePickerController *)self.navigationController;
    if (picker && [picker.pickerDelegate respondsToSelector:@selector(by_imagePickerControllerDismiss:)]) {
        [picker.pickerDelegate by_imagePickerControllerDismiss:picker];
    }
    [[BYImageManager manager] clear];
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)singleTapTitle:(UITapGestureRecognizer *)gesture
{
    [self didClickedTitleButton:nil];
}

- (void)didClickedTitleButton:(id)sender
{
    if ([self.currentController isEqual:self.photoController]) {
        [self addChildViewController:self.albumController];
        [self transitionFromViewController:self.photoController toViewController:self.albumController duration:1 options:UIViewAnimationOptionTransitionFlipFromLeft animations:^{
            
        } completion:^(BOOL finished) {
            if (finished) {
                self.albumController.view.frame = self.view.bounds;
                [self.albumController didMoveToParentViewController:self];
                [self.photoController willMoveToParentViewController:nil];
                [self.photoController removeFromParentViewController];
                self.currentController = self.albumController;
                [self updateTitleView];
            }
        }];
    }else{
        [self addChildViewController:self.photoController];
        [self transitionFromViewController:self.albumController toViewController:self.photoController duration:1 options:UIViewAnimationOptionTransitionFlipFromRight animations:^{
            
        } completion:^(BOOL finished) {
            if (finished) {
                [self.photoController didMoveToParentViewController:self];
                [self.albumController willMoveToParentViewController:nil];
                [self.albumController removeFromParentViewController];
                self.currentController = self.photoController;
                [self updateTitleView];
            }
        }];
    }
}

- (void)updateTitleView
{
    NSString *title = nil;
    if ([self.currentController isEqual:self.photoController]) {
        title = @"相册";
    }else{
        title = @"全部照片";
    }
    self.titleLabel.text = title;
    [self.titleLabel sizeToFit];
    _titleView.bounds = CGRectMake(0, 0, _titleLabel.by_width + _titleImageView.by_width, MAX(_titleLabel.by_height, _titleImageView.by_height));
    _titleLabel.by_left = 0.0f;
    _titleLabel.by_centerY = _titleView.by_height/2;
    _titleImageView.by_left = _titleLabel.by_right;
    _titleImageView.by_centerY = _titleView.by_height/2;
    [self.titleView setNeedsLayout];
    [self.titleView layoutIfNeeded];
}

- (UIView *)titleView
{
    if (!_titleView) {
        _titleView = [[UIView alloc] init];
        
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = [UIFont systemFontOfSize:17.0f];
        _titleLabel.textColor = RGB(0x666666);
        _titleLabel.text = @"相册";
        [_titleLabel sizeToFit];
        
        _titleImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_next"]];
        [_titleImageView sizeToFit];
        
        _titleView.bounds = CGRectMake(0, 0, _titleLabel.by_width + _titleImageView.by_width, MAX(_titleLabel.by_height, _titleImageView.by_height));
        _titleLabel.by_left = 0.0f;
        _titleLabel.by_centerY = _titleView.by_height/2;
        _titleImageView.by_left = _titleLabel.by_right;
        _titleImageView.by_centerY = _titleView.by_height/2;
        [_titleView addSubview:_titleLabel];
        [_titleView addSubview:_titleImageView];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapTitle:)];
        [_titleView addGestureRecognizer:tap];
    }
    return _titleView;
}
@end
