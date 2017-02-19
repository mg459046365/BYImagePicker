//
//  UIView+BYLayout.m
//  BYImagePicker
//
//  Created by Beryter on 2017/2/13.
//  Copyright © 2017年 Beryter. All rights reserved.
//

#import "UIView+BYLayout.h"

@implementation UIView (BYLayout)


- (CGPoint)by_position {
    return self.frame.origin;
}

- (void)setBy_position:(CGPoint)by_position
{
    CGRect rect = self.frame;
    rect.origin = by_position;
    [self setFrame:rect];
}

- (CGFloat)by_left
{
    return self.frame.origin.x;
}

- (void)setBy_left:(CGFloat)by_left
{
    CGRect frame = self.frame;
    frame.origin.x = by_left;
    self.frame = frame;
}

- (CGFloat)by_top
{
    return self.frame.origin.y;
}

- (void)setBy_top:(CGFloat)by_top
{
    CGRect frame = self.frame;
    frame.origin.y = by_top;
    self.frame = frame;
}

- (CGFloat)by_right
{
    return self.frame.origin.x + self.frame.size.width;
}

- (void)setBy_right:(CGFloat)by_right
{
    CGRect frame = self.frame;
    frame.origin.x = by_right - frame.size.width;
    self.frame = frame;
}

- (CGFloat)by_bottom
{
    return self.frame.origin.y + self.frame.size.height;
}

- (void)setBy_bottom:(CGFloat)by_bottom
{
    CGRect frame = self.frame;
    frame.origin.y = by_bottom - frame.size.height;
    self.frame = frame;
}

- (CGFloat)by_centerX
{
    return self.center.x;
}

- (void)setBy_centerX:(CGFloat)by_centerX
{
    self.center = CGPointMake(by_centerX, self.center.y);
}

- (CGFloat)by_centerY
{
    return self.center.y;
}

- (void)setBy_centerY:(CGFloat)by_centerY
{
   self.center = CGPointMake(self.center.x, by_centerY);
}

- (CGSize)by_size
{
    return self.frame.size;
}

- (void)setBy_size:(CGSize)by_size
{
    CGRect rect = self.frame;
    rect.size = by_size;
    [self setFrame:rect];
}

- (CGFloat)by_width
{
   return self.frame.size.width;
}

- (void)setBy_width:(CGFloat)by_width
{
    CGRect rect = self.frame;
    rect.size.width = by_width;
    [self setFrame:rect];
}

- (CGFloat)by_height
{
   return self.frame.size.height;
}

- (void)setBy_height:(CGFloat)by_height
{
    CGRect rect = self.frame;
    rect.size.height = by_height;
    [self setFrame:rect];
}

- (void)by_removeAllSubViews {
    [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
}

+ (void)showShakeAnimationLayer:(CALayer *)layer type:(BYShakeAnimationType)type
{
    NSNumber *bigScale = (type == BYShakeAnimationTypeBig) ? @(1.15) : @(0.5);
    NSNumber *smallScale = (type == BYShakeAnimationTypeBig) ? @(0.92) : @(1.15);
    [UIView animateWithDuration:0.15 delay:0 options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveEaseInOut animations:^{
        [layer setValue:bigScale forKeyPath:@"transform.scale"];
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.15 delay:0 options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveEaseInOut animations:^{
            [layer setValue:smallScale forKeyPath:@"transform.scale"];
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.1 delay:0 options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveEaseInOut animations:^{
                [layer setValue:@(1.0) forKeyPath:@"transform.scale"];
            } completion:nil];
        }];
    }];
}

@end
