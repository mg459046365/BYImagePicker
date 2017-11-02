//
//  BYPhotoPickerController.h
//  BYImagePicker
//
//  Created by Beryter on 2017/2/13.
//  Copyright © 2017年 Beryter. All rights reserved.
//

#import <UIKit/UIKit.h>
@class BYAlbum;
@interface BYPhotoPickerController : UIViewController
@property (nonatomic, assign) BOOL firstItemIsCamera;
@property (nonatomic, assign) NSInteger columnNumber;
@property (nonatomic, strong) BYAlbum *album;
@property (nonatomic, copy) void (^backButtonClickHandle)(BYAlbum *model);
@property (nonatomic, copy) void (^updateAssetCount)(void);
@end
