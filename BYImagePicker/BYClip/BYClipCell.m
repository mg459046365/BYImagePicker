//
//  BYClipCell.m
//  BYImagePicker
//
//  Created by Beryter on 2017/2/23.
//  Copyright © 2017年 Beryter. All rights reserved.
//

#import "BYClipCell.h"
#import "BYDefine.h"

@interface BYClipCell ()
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UILabel *label;

@end

@implementation BYClipCell
- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self.contentView addSubview:self.label];
    }
    return self;
}

- (void)setImage:(UIImage *)image selected:(BOOL)selected
{
    self.imageView.image = image;
}

- (void)setText:(NSString *)text
{
    _label.text = text;
}

- (void)setSelected:(BOOL)selected
{
    self.label.layer.borderColor = selected ? RGB(0x00aaf7).CGColor : [UIColor whiteColor].CGColor;
}

#pragma mark - view
- (UILabel *)label
{
    if (!_label) {
        _label = [[UILabel alloc] init];
        _label.frame = CGRectInset(self.bounds, 10, 10);
        _label.layer.borderWidth = LineHeight;
        _label.layer.borderColor = [UIColor whiteColor].CGColor;
        _label.font = [UIFont systemFontOfSize:12.0f];
        _label.textColor = [UIColor whiteColor];
        _label.textAlignment = NSTextAlignmentCenter;
    }
    return _label;
}
- (UIImageView *)imageView
{
    if (!_imageView) {
        _imageView = [[UIImageView alloc] init];
        _imageView.contentMode = UIViewContentModeScaleToFill;
    }
    return _imageView;
}

@end
