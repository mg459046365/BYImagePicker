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
#import "BYImageManager.h"

@interface BYPickerRootController ()
@property (nonatomic, strong) BYPhotoPickerController *photoController;
@property (nonatomic, strong) BYAlbumPickerController *albumController;
@property (nonatomic, strong) UIViewController *currentController;
@property (nonatomic, strong) UIButton *rightButton;
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
        NSString *title = [NSString stringWithFormat:@"%@/%@继续",@([BYImageManager manager].selectedAssetsCount),@([BYImageManager manager].maxImagesCount)];
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
    [button setTitle:@"所有照片" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [button sizeToFit];
    [button addTarget:self action:@selector(didClickedTitleButton:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.titleView = button;
    
    self.rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.rightButton setTitle:[NSString stringWithFormat:@"0/%@继续",@([BYImageManager manager].maxImagesCount)] forState:UIControlStateNormal];
    [self.rightButton setTitleColor:RGB(0x00aaf7) forState:UIControlStateNormal];
    self.rightButton.titleLabel.font = [UIFont systemFontOfSize:15.0f];
    [self.rightButton sizeToFit];
    [self.rightButton addTarget:self action:@selector(didClickedRightButton:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.rightButton];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    NSString *title = [NSString stringWithFormat:@"%@/%@继续",@([BYImageManager manager].selectedAssetsCount),@([BYImageManager manager].maxImagesCount)];
    [self.rightButton setTitle:title forState:UIControlStateNormal];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)didClickedRightButton:(id)sender
{
    BYImagePickerController *picker = (BYImagePickerController *)self.navigationController;
    if ([BYImageManager manager].selectedAssets.count == 0) {
        if (picker.pickerDelegate && [picker.pickerDelegate respondsToSelector:@selector(by_imagePickerController:didFinishPickingPhotos:)]) {
            [picker.pickerDelegate by_imagePickerController:picker didFinishPickingPhotos:[BYImageManager manager].selectedAssets];
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
            [asset fetchOriginImageCompletion:^(UIImage *image) {
                [tmpArray replaceObjectAtIndex:i withObject:image];
            }];
        });
    }
    __weak typeof(self) weakSelf = self;
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        BYImagePickerController *picker = (BYImagePickerController *)weakSelf.navigationController;
        if (picker.pickerDelegate && [picker.pickerDelegate respondsToSelector:@selector(by_imagePickerController:didFinishPickingPhotos:)]) {
            [picker.pickerDelegate by_imagePickerController:picker didFinishPickingPhotos:tmpArray];
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
            }
        }];
    }
}
@end
