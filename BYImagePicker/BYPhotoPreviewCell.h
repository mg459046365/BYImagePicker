//
//  BYPhotoPreviewCell.h
//  BYImagePicker
//
//  Created by Beryter on 2017/2/16.
//  Copyright © 2017年 Beryter. All rights reserved.
//

#import <UIKit/UIKit.h>
@class BYAsset;
@interface BYPhotoPreviewCell : UICollectionViewCell
@property (nonatomic, strong) BYAsset *asset;
@property (nonatomic, copy) void(^singleTapBlock)(void);
- (void)resetSubviews;
@end
