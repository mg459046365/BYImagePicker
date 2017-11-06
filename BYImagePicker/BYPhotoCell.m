//
//  BYPhotoCell.m
//  BYImagePicker
//
//  Created by Beryter on 2017/2/14.
//  Copyright © 2017年 Beryter. All rights reserved.
//

#import "BYPhotoCell.h"
#import "UIView+BYLayout.h"
#import "BYAsset.h"

@interface BYPhotoCell ()
@property (nonatomic, strong) UIImageView *photoView;
@property (nonatomic, strong) BYPhotoCellSelectView *selectedView;
@property (nonatomic, strong) BYAsset *asset;
@end

@implementation BYPhotoCell

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self setupView];
    }
    return self;
}

- (void)setupView
{
    [self.contentView addSubview:self.photoView];
    [self.contentView addSubview:self.selectedView];
}

- (void)setAsset:(BYAsset *)asset isTakePicItem:(BOOL)isTakePicItem
{
    _asset = asset;
    self.selectedView.hidden = isTakePicItem;
    if (isTakePicItem) {
        self.photoView.image = [UIImage imageNamed:@"takePicture"];
    }else{
        __weak typeof(self) weakSelf = self;
        [asset fetchImageWidth:self.by_width complete:^(UIImage *image) {
            weakSelf.photoView.image = image;
        }];
    }
    self.selectedView.image = asset.isSelected ? [UIImage imageNamed:@"photo_selected_icon"] : [UIImage imageNamed:@"photo_unselect_icon"];
}

- (void)singleTapSelectView:(UITapGestureRecognizer *)gesture
{
    if (self.didClickedSelectIcon) {
        self.didClickedSelectIcon();
    }
}

#pragma mark - view

- (UIImageView *)photoView
{
    if (!_photoView) {
        _photoView = [[UIImageView alloc] initWithFrame:self.bounds];
        _photoView.contentMode = UIViewContentModeScaleAspectFill;
        _photoView.clipsToBounds = YES;
    }
    return _photoView;
}

- (UIImageView *)selectedView
{
    if (!_selectedView) {
        _selectedView = [[BYPhotoCellSelectView alloc] init];
        _selectedView.bounds = CGRectMake(0, 5, 22, 22);
        _selectedView.contentMode = UIViewContentModeScaleToFill;
        _selectedView.by_top = 5.0f;
        _selectedView.by_right = self.by_width - 5.0f;
        _selectedView.userInteractionEnabled = YES;
        
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapSelectView:)];
        [_selectedView addGestureRecognizer:singleTap];
    }
    return _selectedView;
}
@end

@implementation BYPhotoCellSelectView
- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent*)event
{
    CGRect bounds = self.bounds;
    //若原热区小于44x44，则放大热区，否则保持原大小不变
    CGFloat widthDelta = MAX(44.0 - bounds.size.width, 0);
    CGFloat heightDelta = MAX(44.0 - bounds.size.height, 0);
    bounds = CGRectInset(bounds, -0.5 * widthDelta, -0.5 * heightDelta);
    return CGRectContainsPoint(bounds, point);
}
@end


