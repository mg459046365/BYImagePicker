//
//  BYClipTopView.h
//  BYImagePicker
//
//  Created by Beryter on 2017/3/1.
//  Copyright © 2017年 Beryter. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BYClipTopView : UIView

@property (nonatomic, assign) CGRect clipRect;
@property (nonatomic, assign) NSInteger widthRate;
@property (nonatomic, assign) NSInteger heightRate;
- (instancetype)initWithFrame:(CGRect)frame clipRect:(CGRect)clipRect;
@end
