//
//  BYAlbumCell.m
//  BYImagePicker
//
//  Created by Beryter on 2017/2/13.
//  Copyright © 2017年 Beryter. All rights reserved.
//

#import "BYAlbumCell.h"
#import "UIView+BYLayout.h"
#import "BYAlbum.h"

@interface BYAlbumCell ()
@property (nonatomic, strong) UIImageView *albumLogoView;
@property (nonatomic, strong) UILabel *albumNameLabel;
@end

static const CGFloat cellHeight = 90.0f;
@implementation BYAlbumCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self setupView];
    }
    return self;
}

- (void)setupView
{
    [self.contentView addSubview:self.albumLogoView];
    [self.contentView addSubview:self.albumNameLabel];
}

- (void)updateView
{
    __weak typeof(self) weakSelf = self;
    [self.album fetchCover:^(UIImage *image) {
        weakSelf.albumLogoView.image = image;
    }];
    NSString *tmp = [NSString stringWithFormat:@"%@ (%@)",self.album.name,@(self.album.count)];
    self.albumNameLabel.text = tmp;
    [self.albumNameLabel sizeToFit];
    self.albumNameLabel.by_left = self.albumLogoView.by_right + 8.0f;
    self.albumNameLabel.by_centerY = cellHeight/2;
}

- (void)setAlbum:(BYAlbum *)album
{
    _album = album;
    [self updateView];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}
#pragma mark - View
- (UIImageView *)albumLogoView
{
    if (!_albumLogoView) {
        _albumLogoView = [[UIImageView alloc] init];
        _albumLogoView.bounds = CGRectMake(0, 0, cellHeight - 20, cellHeight - 20);
        _albumLogoView.by_left = 10.0f;
        _albumLogoView.by_centerY = cellHeight/2;
        _albumLogoView.clipsToBounds = YES;
        _albumLogoView.contentMode = UIViewContentModeScaleAspectFill;
    }
    return _albumLogoView;
}

- (UILabel *)albumNameLabel
{
    if (!_albumNameLabel) {
        _albumNameLabel = [[UILabel alloc] init];
        _albumNameLabel.font = [UIFont systemFontOfSize:15.0f];
        _albumNameLabel.textAlignment = NSTextAlignmentCenter;
        _albumNameLabel.textColor = [UIColor grayColor];
    }
    return _albumNameLabel;
}
@end
