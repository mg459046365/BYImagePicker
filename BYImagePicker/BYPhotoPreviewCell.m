//
//  BYPhotoPreviewCell.m
//  BYImagePicker
//
//  Created by Beryter on 2017/2/16.
//  Copyright © 2017年 Beryter. All rights reserved.
//

#import "BYPhotoPreviewCell.h"
#import "UIView+BYLayout.h"
#import "BYAsset.h"

@interface BYPhotoPreviewCell ()<UIScrollViewDelegate, UIGestureRecognizerDelegate>
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIImageView *imageView;
@end

@implementation BYPhotoPreviewCell

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self setupView];
    }
    return self;
}

- (void)setupView
{
    [self.contentView addSubview:self.scrollView];
    
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTap:)];
    [self addGestureRecognizer:singleTap];
    
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTap:)];
    doubleTap.numberOfTapsRequired = 2;
    [self addGestureRecognizer:doubleTap];
    
    [singleTap requireGestureRecognizerToFail:doubleTap];
}

#pragma mark - Fountion

- (void)updateView
{
    [self.scrollView setZoomScale:1.0 animated:NO];
}

- (void)resizeImageView:(UIImage *)image
{
    CGSize size = image.size;
    if (size.height / size.width > self.scrollView.by_height / self.scrollView.by_width) {
        CGFloat multiplier = self.scrollView.by_height / image.size.height;
        CGFloat width = size.width * multiplier;
        self.imageView.frame = CGRectMake((self.scrollView.by_width - width) / 2, 0, width, self.scrollView.by_height);
    } else {
        CGFloat multiplier = self.scrollView.by_width / size.width;
        CGFloat height = size.height * multiplier;
        self.imageView.frame = CGRectMake(0, (self.scrollView.by_height - height) / 2, self.scrollView.by_width, height);
    }
    self.scrollView.contentSize = CGSizeMake(self.scrollView.by_width, MAX(self.imageView.by_height, self.scrollView.by_height));
    [self.scrollView scrollRectToVisible:self.bounds animated:NO];
}

- (void)setAsset:(BYAsset *)asset
{
    _asset = asset;
    __weak typeof(self) weakSelf = self;
    [asset fetchImageWidth:self.by_width complete:^(UIImage *image) {
        weakSelf.imageView.image = image;
        [weakSelf resizeImageView:image];
    }];
}

- (void)singleTap:(UITapGestureRecognizer *)gesture
{
    if (self.singleTapBlock) {
        self.singleTapBlock();
    }
}

- (void)doubleTap:(UITapGestureRecognizer *)gesture
{
    
}

#pragma mark - UIScrollViewDelegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.imageView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView
{
}

#pragma mark - view
- (UIScrollView *)scrollView
{
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] init];
        _scrollView.frame = CGRectMake(10, 0, self.by_width - 20, self.by_height);
        _scrollView.bouncesZoom = YES;
        _scrollView.maximumZoomScale = 2.5;
        _scrollView.minimumZoomScale = 1.0;
        _scrollView.multipleTouchEnabled = YES;
        _scrollView.delegate = self;
        _scrollView.scrollsToTop = NO;
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.showsVerticalScrollIndicator = NO;
        _scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _scrollView.delaysContentTouches = NO;
        _scrollView.canCancelContentTouches = YES;
        _scrollView.alwaysBounceVertical = NO;
        [_scrollView addSubview:self.imageView];
    }
    return _scrollView;
}

- (UIImageView *)imageView
{
    if (!_imageView) {
        _imageView = [[UIImageView alloc] init];
        _imageView.clipsToBounds = YES;
    }
    return _imageView;
}

@end
