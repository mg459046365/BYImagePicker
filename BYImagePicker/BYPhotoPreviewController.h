//
//  BYPhotoPreviewController.h
//  BYImagePicker
//
//  Created by Beryter on 2017/2/15.
//  Copyright © 2017年 Beryter. All rights reserved.
//

#import <UIKit/UIKit.h>
@class BYAsset;
@interface BYPhotoPreviewController : UIViewController
@property (nonatomic, strong) NSArray *assets;
@property (nonatomic, assign) NSInteger showIndex;
@property (nonatomic, copy) void(^updateCell)(BYAsset *asset,NSInteger index);
@end
