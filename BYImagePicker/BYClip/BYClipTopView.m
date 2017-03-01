//
//  BYClipTopView.m
//  BYImagePicker
//
//  Created by Beryter on 2017/3/1.
//  Copyright © 2017年 Beryter. All rights reserved.
//

#import "BYClipTopView.h"
#import "UIView+BYLayout.h"
#import "BYClipView.h"

@interface BYClipTopView ()
@property (nonatomic, strong) BYClipView *clipView;
@end

@implementation BYClipTopView

- (instancetype)initWithFrame:(CGRect)frame clipRect:(CGRect)clipRect
{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
        _clipView = [[BYClipView alloc] initWithFrame:clipRect];
        [self addSubview:_clipView];
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGRect rct = self.bounds;
    CGContextSetFillColorWithColor(context, [[UIColor blackColor] colorWithAlphaComponent:0.5].CGColor);
    CGContextFillRect(context, rct);
    CGContextClearRect(context, self.clipRect);
    CGContextStrokePath(context);
}

- (void)setWidthRate:(NSInteger)widthRate
{
    self.clipView.widthRate = widthRate;
}

- (void)setHeightRate:(NSInteger)heightRate
{
    self.clipView.heightRate = heightRate;
}
- (void)setClipRect:(CGRect)clipRect
{
    self.clipView.frame = clipRect;
    [self.clipView setNeedsDisplay];
    [self setNeedsDisplay];
}

- (CGRect)clipRect
{
    return self.clipView.frame;
}
@end
