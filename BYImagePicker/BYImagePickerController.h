//
//  BYImagePickerController.h
//  BYImagePicker
//
//  Created by Beryter on 2017/2/13.
//  Copyright © 2017年 Beryter. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Photos/Photos.h>
#import "BYAsset.h"

typedef NS_ENUM(NSInteger, BYEditType)
{
    BYEditTypeCrop = 0,
    BYEditTypeRotate = 1 << 0,
    BYEditTypeOther = 1 << 1,
    BYEditTypeOther1 = 1 << 2,
    BYEditTypeOther2 = 1 << 3,
};

@protocol BYImagePickerDelegate;
@interface BYImagePickerController : UINavigationController
/// 默认最大可选9张图片
@property (nonatomic, assign) NSInteger maxPhotoCount;
/// 最小照片必选张数,默认是0
@property (nonatomic, assign) NSInteger minPhotoCount;
/// 图片展示一行展示的个数
@property (nonatomic, assign) NSInteger columnNumber;
/// 上次选择的照片
@property (nonatomic, strong) NSArray<BYAsset *> *lastSelectedAssets;
/// 允许选择的资源类型
@property(nonatomic, assign,readonly) PHAssetMediaType mediaSelectableType;

@property (nonatomic, weak) id<BYImagePickerDelegate> pickerDelegate;

@end

@protocol BYImagePickerDelegate <NSObject>

@required
- (void)by_imagePickerController:(BYImagePickerController *)picker didFinishPickedAssets:(NSArray<BYAsset *> *)assets;
- (void)by_imagePickerControllerDismiss:(BYImagePickerController *)picker;
@optional
- (void)by_imagePickerController:(BYImagePickerController *)picker didSelectPhoto:(BYAsset *)asset;
- (void)by_imagePickerController:(BYImagePickerController *)picker didDeselectPhoto:(BYAsset *)asset;
- (void)by_imagePickerControllerBeyondMaximum:(BYImagePickerController *)picker;
@end
