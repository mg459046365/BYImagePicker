//
//  BYPhotoPreviewController.m
//  BYImagePicker
//
//  Created by Beryter on 2017/2/15.
//  Copyright © 2017年 Beryter. All rights reserved.
//

#import "BYPhotoPreviewController.h"
#import "BYImagePickerController.h"
#import "BYPhotoPreviewCell.h"
#import "UIView+BYLayout.h"
#import "BYImageManager.h"
#import "BYDefine.h"
#import "BYAsset.h"

@interface BYPhotoPreviewController ()<UICollectionViewDelegate,UICollectionViewDataSource>
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, assign) NSInteger currentIndex;
@property (nonatomic, strong) UIView *topView;
@property (nonatomic, strong) UIView *bottomView;
@property (nonatomic, strong) UIButton *backButton;
@property (nonatomic, strong) UIButton *selectButton;
@property (nonatomic, strong) UILabel *countLabel;
@property (nonatomic, strong) BYAsset *currentAsset;
@property (nonatomic, assign) BOOL menuHidden;

@end

@implementation BYPhotoPreviewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self.view addSubview:self.collectionView];
    [self.view addSubview:self.topView];
    [self.view addSubview:self.bottomView];
    [self.collectionView reloadData];
    [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:self.showIndex inSection:0] atScrollPosition:UICollectionViewScrollPositionNone animated:NO];
    self.view.clipsToBounds = YES;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES];
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Function
- (void)didClickedBackButton:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)didClickedSelectButton:(id)sender
{
    BYImagePickerController *picker = (BYImagePickerController *)self.navigationController;
    if ([BYImageManager manager].selectedAssetsCount >= [BYImageManager manager].maxImagesCount && !self.currentAsset.isSelected) {
        if (picker.pickerDelegate && [picker.pickerDelegate respondsToSelector:@selector(by_imagePickerControllerBeyondMaximum:)]) {
            [picker.pickerDelegate by_imagePickerControllerBeyondMaximum:picker];
        }
        return;
    }
    
    [self.selectButton setSelected:!self.currentAsset.isSelected];
    self.currentAsset.isSelected = !self.currentAsset.isSelected;
    self.countLabel.text = [NSString stringWithFormat:@"%@",@([BYImageManager manager].selectedAssetsCount)];
    if (self.currentAsset.isSelected) {
        [UIView showShakeAnimationLayer:self.countLabel.layer type:BYShakeAnimationTypeBig];
    }else{
        [UIView showShakeAnimationLayer:self.countLabel.layer type:BYShakeAnimationTypeSmall];
    }
    
    if (self.currentAsset.isSelected) {
        if (picker.pickerDelegate && [picker.pickerDelegate respondsToSelector:@selector(by_imagePickerController:didSelectPhoto:)]) {
            [picker.pickerDelegate by_imagePickerController:picker didSelectPhoto:self.currentAsset.asset];
        }
    }else{
        if (picker.pickerDelegate && [picker.pickerDelegate respondsToSelector:@selector(by_imagePickerController:didDeselectPhoto:)]) {
            [picker.pickerDelegate by_imagePickerController:picker didDeselectPhoto:self.currentAsset.asset];
        }
    }
}

- (void)photoSingleTapHandler
{
    self.menuHidden = !self.menuHidden;
    [UIView animateWithDuration:0.2 animations:^{
        self.topView.alpha = self.menuHidden;
        self.bottomView.alpha = self.menuHidden;
    } completion:^(BOOL finished) {
        
    }];
}

- (void)tapCompleteView:(UITapGestureRecognizer *)gesture
{
    BYImagePickerController *picker = (BYImagePickerController *)self.navigationController;
    if ([BYImageManager manager].selectedAssetsCount == 0) {
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
            [asset fetchImageCompletion:^(UIImage *image) {
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

#pragma mark - UICollectionViewDelegate,UICollectionViewDataSource
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    BYPhotoPreviewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([BYPhotoPreviewCell class]) forIndexPath:indexPath];
    BYAsset *asset = self.assets[indexPath.item];
    cell.asset = asset;
    __weak typeof(self) weakSelf = self;
    cell.singleTapBlock = ^{
        [weakSelf photoSingleTapHandler];
    };
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath
{
    BYAsset *asset = self.assets[indexPath.item];
    self.currentAsset = asset;
    [self.selectButton setSelected:asset.isSelected];
}

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    BYPhotoPreviewCell *tmpCell = (BYPhotoPreviewCell *)cell;
    [tmpCell resetSubviews];
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath
{
    
}

- (BOOL)collectionView:(UICollectionView *)collectionView canFocusItemAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.assets.count;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(self.view.by_width + 20.0f, self.view.by_height);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    //top,left,bottom,right
    return UIEdgeInsetsMake(0, 0, 0, 0);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 0.0f;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 0.0f;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
{
    return CGSizeMake(0, 0);
}

#pragma mark - view

- (UIView *)topView
{
    if (!_topView) {
        _topView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.by_width, 64)];
        _topView.backgroundColor = RGBA(0x323740, 0.8);
        
        UIButton *backButton = [[UIButton alloc] init];
        [backButton setImage:[UIImage imageNamed:@"backIcon"] forState:UIControlStateNormal];
        backButton.bounds = CGRectMake(0, 0, 44, 44);
        [backButton addTarget:self action:@selector(didClickedBackButton:) forControlEvents:UIControlEventTouchUpInside];
        backButton.by_left = 0;
        backButton.by_centerY = 32;
        [_topView addSubview:backButton];
        
        _selectButton = [[UIButton alloc] init];
        [_selectButton setImage:[UIImage imageNamed:@"photo_unselect_icon"] forState:UIControlStateNormal];
        [_selectButton setImage:[UIImage imageNamed:@"photo_selected_icon"] forState:UIControlStateSelected];
        _selectButton.bounds = CGRectMake(0, 0, 44, 44);
        [_selectButton addTarget:self action:@selector(didClickedSelectButton:) forControlEvents:UIControlEventTouchUpInside];
        _selectButton.by_right = self.view.by_width;
        _selectButton.by_centerY = 32;
        [_topView addSubview:_selectButton];
    }
    return _topView;
}
- (UIView *)bottomView
{
    if (!_bottomView) {
        _bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.by_height - 64, self.view.by_width, 64)];
        _bottomView.backgroundColor = RGBA(0x323740, 0.8);
        
        
        UIView *completeView = [[UIView alloc] init];
        
        _countLabel = [[UILabel alloc] init];
        _countLabel.bounds = CGRectMake(0, 0, 22.0f, 22.0f);
        _countLabel.clipsToBounds = YES;
        _countLabel.layer.masksToBounds = YES;
        _countLabel.layer.cornerRadius = 11.0f;
        _countLabel.backgroundColor = RGB(0x00aaf7);
        _countLabel.textAlignment = NSTextAlignmentCenter;
        _countLabel.textColor = [UIColor whiteColor];
        _countLabel.font = [UIFont systemFontOfSize:15.0f];
        _countLabel.text = [NSString stringWithFormat:@"%@",@([BYImageManager manager].selectedAssetsCount)];
        _countLabel.by_left = 0;
        
        UILabel *label = [[UILabel alloc] init];
        label.textColor = RGB(0x00aaf7);
        label.font = [UIFont systemFontOfSize:15.0f];
        label.text = @"完成";
        [label sizeToFit];
        label.by_left = _countLabel.by_right + 8.0f;
        
        completeView.bounds = CGRectMake(0, 0, _countLabel.by_width + 8 + label.by_width, MAX(_countLabel.by_height, label.by_height));
        _countLabel.by_centerY = completeView.by_height/2;
        label.by_centerY = completeView.by_height/2;
        [completeView addSubview:_countLabel];
        [completeView addSubview:label];
        completeView.by_right = _bottomView.by_width - 20.0f;
        completeView.by_bottom = _bottomView.by_height - 14.0f;
        [_bottomView addSubview:completeView];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapCompleteView:)];
        [completeView addGestureRecognizer:tap];
    }
    return _bottomView;
}
- (UICollectionView *)collectionView
{
    if (!_collectionView) {
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(-10, 0, self.view.by_width + 20, self.view.by_height) collectionViewLayout:flowLayout];
        [_collectionView registerClass:[BYPhotoPreviewCell class] forCellWithReuseIdentifier:NSStringFromClass([BYPhotoPreviewCell class])];
        _collectionView.scrollEnabled = YES;
        _collectionView.pagingEnabled = YES;
        _collectionView.directionalLockEnabled = YES;
        _collectionView.showsHorizontalScrollIndicator = NO;
        _collectionView.showsVerticalScrollIndicator = NO;
        _collectionView.scrollsToTop = NO;
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
    }
    return _collectionView;
}

@end
