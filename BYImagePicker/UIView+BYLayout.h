//
//  UIView+BYLayout.h
//  BYImagePicker
//
//  Created by Beryter on 2017/2/13.
//  Copyright © 2017年 Beryter. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, BYShakeAnimationType)
{
    BYShakeAnimationTypeBig,
    BYShakeAnimationTypeSmall
};

@interface UIView (BYLayout)
@property(nonatomic, assign) CGPoint by_position;
@property(nonatomic, assign) CGFloat by_top;
@property(nonatomic, assign) CGFloat by_bottom;
@property(nonatomic, assign) CGFloat by_left;
@property(nonatomic, assign) CGFloat by_right;
@property(nonatomic, assign) CGFloat by_centerX;
@property(nonatomic, assign) CGFloat by_centerY;
@property(nonatomic, assign) CGSize  by_size;
@property(nonatomic, assign) CGFloat by_width;
@property(nonatomic, assign) CGFloat by_height;
- (void)by_removeAllSubViews;
+ (void)showShakeAnimationLayer:(CALayer *)layer type:(BYShakeAnimationType)type;
@end
