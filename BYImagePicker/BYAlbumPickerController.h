//
//  BYAlbumPickerController.h
//  BYImagePicker
//
//  Created by Beryter on 2017/2/13.
//  Copyright © 2017年 Beryter. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Photos/Photos.h>

@interface BYAlbumPickerController : UIViewController
@property (nonatomic, assign) PHAssetMediaType mediaType;
@property (nonatomic, assign) NSInteger columnNumber;
@end
