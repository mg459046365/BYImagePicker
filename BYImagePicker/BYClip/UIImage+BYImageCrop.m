//
//  UIImage+BYImageCrop.m
//  BYImagePicker
//
//  Created by Beryter on 2017/3/1.
//  Copyright © 2017年 Beryter. All rights reserved.
//

#import "UIImage+BYImageCrop.h"

@implementation UIImage (BYImageCrop)
- (UIImage*)crop:(CGRect)rect
{
    CGPoint origin = CGPointMake(-rect.origin.x, -rect.origin.y);
    
    UIImage *img = nil;
    
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, self.scale);
    [self drawAtPoint:origin];
    img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return img;
}
@end
