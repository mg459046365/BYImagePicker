//
//  BYPhotoPickerController.m
//  BYImagePicker
//
//  Created by Beryter on 2017/2/13.
//  Copyright © 2017年 Beryter. All rights reserved.
//

#import "BYPhotoPickerController.h"
#import "BYPhotoPreviewController.h"
#import "BYImagePickerController.h"
#import "BYPhotoEditController.h"
#import "UIView+BYLayout.h"
#import "BYImageManager.h"
#import "BYPhotoCell.h"
#import "BYDefine.h"
#import "BYAlbum.h"
#import "BYAsset.h"

@interface BYPhotoPickerController ()<UICollectionViewDelegate,UICollectionViewDataSource, UINavigationControllerDelegate, UIImagePickerControllerDelegate>
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, assign) CGFloat cellWidth;
@property (nonatomic, strong) NSArray *assets;
@end

@implementation BYPhotoPickerController

- (instancetype)init
{
    if (self = [super init]) {
        _columnNumber = 4;
    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.cellWidth = (self.view.by_width - 3.0*(self.columnNumber + 1))/self.columnNumber;
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self.view addSubview:self.collectionView];
    [self.collectionView reloadData];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Functions

- (void)didClickedLeftItem:(id)sender
{
    if (self.navigationController.childViewControllers.count == 1) {
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    }else{
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)setAlbum:(BYAlbum *)album
{
    _album = album;
    self.title = album.name;
    self.assets = album.photoAssets;
}

- (void)didSelectedAssetAtIndex:(NSInteger)index
{
    BYImagePickerController *picker = (BYImagePickerController *)self.navigationController;
    
    NSInteger tmp = index;
    if (self.firstItemIsCamera) {
        tmp = index - 1;
    }
    BYAsset *asset = self.assets[tmp];
    
    if ([BYImageManager manager].selectedAssetsCount >= [BYImageManager manager].maxImagesCount && !asset.isSelected) {
        if (picker.pickerDelegate && [picker.pickerDelegate respondsToSelector:@selector(by_imagePickerControllerBeyondMaximum:)]) {
            [picker.pickerDelegate by_imagePickerControllerBeyondMaximum:picker];
        }
        return;
    }
    asset.isSelected = !asset.isSelected;
    [self.collectionView reloadItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:index inSection:0]]];
    if (self.updateAssetCount) {
        self.updateAssetCount();
    }
    if (asset.isSelected) {
        if (picker.pickerDelegate && [picker.pickerDelegate respondsToSelector:@selector(by_imagePickerController:didSelectPhoto:)]) {
            [picker.pickerDelegate by_imagePickerController:picker didSelectPhoto:asset.asset];
        }
    }else{
        if (picker.pickerDelegate && [picker.pickerDelegate respondsToSelector:@selector(by_imagePickerController:didDeselectPhoto:)]) {
            [picker.pickerDelegate by_imagePickerController:picker didDeselectPhoto:asset.asset];
        }
    }
}


#pragma mark - UIPickerViewDelegate

// 打开相机拍照
- (void)takePhoto
{
    UIImagePickerControllerSourceType sourceType = UIImagePickerControllerSourceTypeCamera;
    if ([UIImagePickerController isSourceTypeAvailable: sourceType]) {
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        [picker.navigationBar setBarTintColor:RGB(0xf1f1f1)];
        [picker.navigationBar setTranslucent:NO];
        [picker.navigationBar setTintColor:RGB(0x666666)];
        picker.delegate = self;
        // 设置拍照后的图片可被编辑
        picker.allowsEditing = NO;
        picker.sourceType = sourceType;
        [self presentViewController:picker animated:YES completion:nil];
    }
}

// 当选择一张图片后进入这里
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    NSString *type = [info objectForKey:UIImagePickerControllerMediaType];
    // 当选择的类型是图片
    if ([type isEqualToString:@"public.image"]) {
        [picker dismissViewControllerAnimated:YES completion:nil];
//        UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - UICollectionViewDataSource,UICollectionViewDelegate
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if (self.firstItemIsCamera) {
        return self.assets.count + 1;
    }
    return self.assets.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    BYPhotoCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([BYPhotoCell class]) forIndexPath:indexPath];
    
    if (self.firstItemIsCamera && indexPath.item == 0) {
        [cell setAsset:nil isTakePicItem:YES];
    }else{
        NSInteger index = 0;
        if (self.firstItemIsCamera) {
            index = indexPath.item - 1;
        }else{
            index = indexPath.item;
        }
        BYAsset *asset = self.assets[index];
        [cell setAsset:asset isTakePicItem:NO];
        __weak typeof(self) weakSelf = self;
        cell.didClickedSelectIcon = ^{
            [weakSelf didSelectedAssetAtIndex:indexPath.item];
        };
    }
    return cell;
}

- (BOOL)collectionView:(UICollectionView *)collectionView canMoveItemAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.firstItemIsCamera && indexPath.item == 0) {
        [self takePhoto];
        return;
    }
    
    BYPhotoPreviewController *controller = [[BYPhotoPreviewController alloc] init];
    controller.assets = self.assets;
    NSInteger index = 0;
    if (self.firstItemIsCamera) {
        index = indexPath.item - 1;
    }else{
        index = indexPath.item;
    }
    controller.showIndex = index;
    [self.navigationController pushViewController:controller animated:YES];
    
//    BYPhotoEditController *controller = [[BYPhotoEditController alloc] init];
//    NSInteger index = 0;
//    if (self.firstItemIsCamera) {
//        index = indexPath.item - 1;
//    }else{
//        index = indexPath.item;
//    }
//    controller.asset = self.assets[index];
//    [self.navigationController pushViewController:controller animated:YES];
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(self.cellWidth, self.cellWidth);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    //top,left,bottom,right
    return UIEdgeInsetsMake(3, 3, 3, 3);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 3.0f;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 3.0f;
}

#pragma mark - View
- (UICollectionView *)collectionView
{
    if (!_collectionView) {
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0,64, self.view.by_width, self.view.by_height - 64) collectionViewLayout:flowLayout];
        [_collectionView registerClass:[BYPhotoCell class] forCellWithReuseIdentifier:NSStringFromClass([BYPhotoCell class])];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.backgroundColor = [UIColor whiteColor];
        _collectionView.showsVerticalScrollIndicator = NO;
    }
    return _collectionView;
}

@end
