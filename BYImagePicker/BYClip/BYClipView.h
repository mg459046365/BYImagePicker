//
//  BYClipView.h
//  BYImagePicker
//
//  Created by Beryter on 2017/2/24.
//  Copyright © 2017年 Beryter. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BYClipView : UIView
@property (nonatomic, assign) CGRect clippingRect;
- (id)initWithSuperview:(UIView*)superview frame:(CGRect)frame;
- (void)setBgColor:(UIColor*)bgColor;
- (void)setGridColor:(UIColor*)gridColor;
- (void)clippingRatioDidChange;
@end
