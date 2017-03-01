//
//  BYClipListView.h
//  BYImagePicker
//
//  Created by Beryter on 2017/2/23.
//  Copyright © 2017年 Beryter. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BYClipListView : UIView
@property (nonatomic, copy) void(^selectedClipRate)(NSInteger widthRate, NSInteger heightRate);
@end
