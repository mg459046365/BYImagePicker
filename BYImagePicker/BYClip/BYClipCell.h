//
//  BYClipCell.h
//  BYImagePicker
//
//  Created by Beryter on 2017/2/23.
//  Copyright © 2017年 Beryter. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BYClipCell : UICollectionViewCell
- (void)setImage:(UIImage *)image selected:(BOOL)selected;
- (void)setText:(NSString *)text;
@end
