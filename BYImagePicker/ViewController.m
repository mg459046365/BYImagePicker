//
//  ViewController.m
//  BYImagePicker
//
//  Created by Beryter on 2017/2/12.
//  Copyright © 2017年 Beryter. All rights reserved.
//

#import "ViewController.h"
#import "BYAlbumPickerController.h"
#import "BYImagePickerController.h"
#import "BYPhotoCell.h"
#import "UIView+BYLayout.h"
@interface ViewController ()<BYImagePickerDelegate,UICollectionViewDelegate,UICollectionViewDataSource>
@property (nonatomic, strong)NSMutableArray *photos;
@property (nonatomic, strong)UICollectionView *collectionView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.photos = [NSMutableArray array];
    self.title = @"测试demo";
    self.view.backgroundColor = [UIColor whiteColor];
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(100, 100, 100, 60);
    [button setTitle:@"相册" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(test:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    
    UIButton *button1 = [UIButton buttonWithType:UIButtonTypeCustom];
    button1.frame = CGRectMake(button.by_right + 40, 100, 100, 60);
    [button1 setTitle:@"清空" forState:UIControlStateNormal];
    [button1 setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [button1 addTarget:self action:@selector(clear:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button1];
    [self.view addSubview:self.collectionView];
}

- (void)clear:(id)sender
{
    [self.photos removeAllObjects];
    [self.collectionView reloadData];
}

- (void)test:(id)sender
{
    BYImagePickerController *picker = [[BYImagePickerController alloc] init];
    picker.pickerDelegate = self;
    picker.lastSelectedAssets = [NSMutableArray arrayWithArray:self.photos];
    [self presentViewController:picker animated:YES completion:nil];
}

- (void)by_imagePickerControllerDismiss:(BYImagePickerController *)picker
{
    
}

- (void)by_imagePickerControllerBeyondMaximum:(BYImagePickerController *)picker
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"超出图片可选最大数目" message:nil preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil];
    [alert addAction:action];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)by_imagePickerController:(BYImagePickerController *)picker didFinishPickedAssets:(NSArray<BYAsset *> *)assets
{
    [self.photos removeAllObjects];
    [self.photos addObjectsFromArray:assets];
    [self.collectionView reloadData];
}


- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat cellWidth = (self.view.by_width - 3.0*(4 + 1))/4;
    return CGSizeMake(cellWidth, cellWidth);
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

- (UICollectionViewCell *)collectionView:(nonnull UICollectionView *)collectionView cellForItemAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    BYPhotoCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([BYPhotoCell class]) forIndexPath:indexPath];
    BYAsset *asset = self.photos[indexPath.item];
    [cell setAsset:asset isTakePicItem:NO];
    return cell;
}

- (NSInteger)collectionView:(nonnull UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.photos.count;
}
#pragma mark - View
- (UICollectionView *)collectionView
{
    if (!_collectionView) {
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0,160, self.view.by_width, self.view.by_height - 160-64) collectionViewLayout:flowLayout];
        [_collectionView registerClass:[BYPhotoCell class] forCellWithReuseIdentifier:NSStringFromClass([BYPhotoCell class])];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.backgroundColor = [UIColor whiteColor];
        _collectionView.showsVerticalScrollIndicator = NO;
    }
    return _collectionView;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
