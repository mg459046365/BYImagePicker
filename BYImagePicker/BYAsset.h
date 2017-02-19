//
//  BYAsset.h
//  BYImagePicker
//
//  Created by Beryter on 2017/2/12.
//  Copyright © 2017年 Beryter. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Photos/Photos.h>

@interface BYAsset : NSObject
/// 图片资源
@property (nonatomic, strong) PHAsset *asset;
/// 资源类型
@property (nonatomic, assign, readonly) PHAssetMediaType mediaType;
@property (nonatomic, strong, readonly) NSString *localIdentifier;
///// 是否被选中
@property (nonatomic, assign) BOOL isSelected;
/// 用一个PHAsset实例，初始化一个照片模型
+ (instancetype)modelWithAsset:(PHAsset *)asset;
- (void)fetchImageWidth:(CGFloat)width complete:(void(^)(UIImage *image))fetchBlock;
- (void)fetchOriginImageCompletion:(void(^)(UIImage *image))completion;
@end
