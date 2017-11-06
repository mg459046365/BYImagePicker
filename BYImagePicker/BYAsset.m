//
//  BYAsset.m
//  BYImagePicker
//
//  Created by Beryter on 2017/2/12.
//  Copyright © 2017年 Beryter. All rights reserved.
//

#import "BYAsset.h"
#import "BYImageManager.h"

@interface BYAsset ()
@property (nonatomic, assign) PHImageRequestID imageRequestID;
/// 高清图
@property (nonatomic, strong) UIImage *photo;

@end

@implementation BYAsset

+ (instancetype)modelWithAsset:(PHAsset *)asset
{
    BYAsset *model = [[BYAsset alloc] init];
    model.asset = asset;
    return model;
}

- (instancetype)init
{
    if (self = [super init]) {
    }
    return self;
}

- (PHAssetMediaType)mediaType
{
    return self.asset.mediaType;
}

- (NSString *)localIdentifier
{
    return self.asset.localIdentifier;
}

- (BOOL)isSelected
{
    for (BYAsset *asset in [BYImageManager manager].selectedAssets) {
        if ([asset.localIdentifier isEqualToString:self.localIdentifier]) {
            return YES;
        }
    }
    return NO;
}

- (void)setIsSelected:(BOOL)isSelected
{
    BYAsset *haveSelectedAsset = nil;
    for (BYAsset *asset in [BYImageManager manager].selectedAssets) {
        if ([asset.localIdentifier isEqualToString:self.localIdentifier]) {
            haveSelectedAsset = asset;
            break;
        }
    }
    if (isSelected && !haveSelectedAsset) {
        [[BYImageManager manager].selectedAssets addObject:self];
        return;
    }
    if (!isSelected && haveSelectedAsset) {
        [[BYImageManager manager].selectedAssets removeObject:haveSelectedAsset];
    }
}

- (CGSize)fitSize:(CGSize)targetSize
{
    CGFloat scale = [UIScreen mainScreen].scale;
    CGSize size = CGSizeMake(self.asset.pixelWidth, self.asset.pixelHeight);
    CGSize tmpPixSize = CGSizeMake(targetSize.width * scale, targetSize.height * scale);
    CGSize resultSize = CGSizeZero;
    if (tmpPixSize.height / size.height > tmpPixSize.width / size.width)
    {
        resultSize.width = ceil(tmpPixSize.width / scale);
        resultSize.height = floor(size.height * tmpPixSize.width / (size.width * scale));
    }else{
        resultSize.height = ceil(tmpPixSize.height / scale);
        resultSize.width = floor(size.width * tmpPixSize.height / (size.height * scale));
    }
    return resultSize;
}

- (void)fetchImageDataCompletion:(void (^)(NSData *data))completion
{
    [BYImageManager fetchImageDataInAsset:self.asset completion:^(NSData *data, NSDictionary *info) {
        if (completion) {
            completion(data);
        }
    }];
}

- (void)fetchImageCompletion:(void(^)(UIImage *image))completion
{
    [BYImageManager fetchImageDataInAsset:self.asset completion:^(NSData *data, NSDictionary *info) {
        UIImage *image = [UIImage imageWithData:data];
        if (completion) {
            completion(image);
        }
    }];
}

- (void)fetchImageWidth:(CGFloat)width complete:(void(^)(UIImage *image))fetchBlock
{
    PHImageRequestID imageRequestID = [BYImageManager fetchImageInAsset:self.asset imageWidth:width completion:^(UIImage *image, NSDictionary *info, BOOL isDegraded)
    {
        fetchBlock(image);
    }];
    if (imageRequestID && self.imageRequestID && imageRequestID != self.imageRequestID) {
        [[PHImageManager defaultManager] cancelImageRequest:self.imageRequestID];
    }
    self.imageRequestID = imageRequestID;
}
@end
