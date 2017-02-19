//
//  BYPhotoCell.h
//  BYImagePicker
//
//  Created by Beryter on 2017/2/14.
//  Copyright © 2017年 Beryter. All rights reserved.
//

#import <UIKit/UIKit.h>
@class BYAsset;
@interface BYPhotoCell : UICollectionViewCell
- (void)setAsset:(BYAsset *)asset isTakePicItem:(BOOL)isTakePicItem;
@property (nonatomic, copy) void(^didClickedSelectIcon)();
@end

@interface BYPhotoCellSelectView : UIImageView

@end
