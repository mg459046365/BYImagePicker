//
//  BYImageManager.h
//  BYImagePicker
//
//  Created by Beryter on 2017/2/12.
//  Copyright © 2017年 Beryter. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Photos/Photos.h>

@class BYAlbum,BYAsset;
typedef void(^BYImageFetchBlock)(UIImage *image,NSDictionary *info,BOOL isDegraded);
typedef void(^BYImageDataFetchBlock)(NSData *data,NSDictionary *info);
typedef void(^BYAssetsFetchBlock)(NSArray<BYAsset *> *allAssets, NSArray<BYAsset *> *photoAssets, NSArray<BYAsset *> *videoAssets, NSArray<BYAsset *> *audioAssets);
typedef void(^BYImageLoadProgress)(CGFloat progress, NSError *error, BOOL *stop, NSDictionary *info);

@interface BYImageManager : NSObject

+ (instancetype)manager;
- (void)clear;

/// 选中的图片
@property (nonatomic, strong) NSMutableArray *selectedAssets;
@property (nonatomic, assign, readonly) NSInteger selectedAssetsCount;
/// 默认最大可选9张图片
@property (nonatomic, assign) NSInteger maxImagesCount;
/// 最小照片必选张数,默认是0
@property (nonatomic, assign) NSInteger minImagesCount;

/// 返回YES如果得到了授权
+ (BOOL)authorizationStatusAuthorized;
/// 授权状态
+ (PHAuthorizationStatus)authorizationStatus;
/// 是否能使用相册
+ (BOOL)canUsePhotoLibrary;
/// 是否能使用相机
+ (BOOL)canUseCamera;

/// 获得相册/相册数组
+ (BYAlbum *)fetchCameraRollImageAlbum;
+ (BYAlbum *)fetchCameraRollVideoAlbum;
+ (BYAlbum *)fetchCameraRollAudioAlbum;
+ (BYAlbum *)fetchCameraRollAlbum;
+ (BYAlbum *)fetchCameraRollAlbumMediaType:(PHAssetMediaType)type;

+ (NSArray<BYAlbum *> *)fetchAllImageAlbums;
+ (NSArray<BYAlbum *> *)fetchAllVideoAlbums;
+ (NSArray<BYAlbum *> *)fetchAllAudioAlbums;
+ (NSArray<BYAlbum *> *)fetchAllAlbums;
+ (NSArray<BYAlbum *> *)fetchAlbumsMediaType:(PHAssetMediaType)type;

/// 获得Asset数组
+ (NSArray<BYAsset *> *)fetchImageAssetsIn:(PHFetchResult *)result;
+ (NSArray<BYAsset *> *)fetchVideoAssetsIn:(PHFetchResult *)result;
+ (NSArray<BYAsset *> *)fetchAudioAssetsIn:(PHFetchResult *)result;
+ (NSArray<BYAsset *> *)fetchAllAssetsIn:(PHFetchResult *)result;
+ (NSArray<BYAsset *> *)fetchAssetsIn:(PHFetchResult *)result assetType:(PHAssetMediaType)type;
+ (void)fetchAssetsIn:(PHFetchResult *)result complete:(BYAssetsFetchBlock)fetchBlock;
+ (BYAsset *)fetchAssetIn:(PHFetchResult *)result atIndex:(NSInteger)index;

/// 获得照片
+ (void)fetchImageDataInAsset:(PHAsset *)asset completion:(BYImageDataFetchBlock)completion;
+ (void)fetchImageInAsset:(PHAsset *)asset completion:(BYImageFetchBlock)completion;
+ (void)fetchDefaultImageInAsset:(PHAsset *)asset completion:(BYImageFetchBlock)completion;
+ (void)fetchDefaultImageInAsset:(PHAsset *)asset fixOrientation:(BOOL)fix completion:(BYImageFetchBlock)completion;
+ (PHImageRequestID)fetchFullScreenImageInAsset:(PHAsset *)asset completion:(BYImageFetchBlock)completion;
+ (PHImageRequestID)fetchImageInAsset:(PHAsset *)asset imageWidth:(CGFloat)width completion:(BYImageFetchBlock)completion;
+ (PHImageRequestID)fetchImageInAsset:(PHAsset *)asset imageWidth:(CGFloat)width fixOrientation:(BOOL)fix completion:(BYImageFetchBlock)completion;
+ (PHImageRequestID)fetchImageInAsset:(PHAsset *)asset networkAllowed:(BOOL)networkAllowed progress:(BYImageLoadProgress)progressHandler completion:(BYImageFetchBlock)completion;
+ (PHImageRequestID)fetchImageInAsset:(PHAsset *)asset imageWidth:(CGFloat)width networkAllowed:(BOOL)networkAllowed progress:(BYImageLoadProgress)progressHandler completion:(BYImageFetchBlock)completion;

+ (void)fetchAlbumCover:(BYAlbum *)album completion:(void (^)(UIImage *image))completion;
/// 保存照片
+ (void)saveImage:(UIImage *)image completion:(void (^)(NSError *error))completion;

/// 获得视频
+ (void)fetchPlayerItemInAsset:(PHAsset *)asset completion:(void (^)(AVPlayerItem * playerItem, NSDictionary * info))completion;

/// 导出视频
+ (void)fetchVideoPathInAsset:(PHAsset *)asset completion:(void (^)(NSString *path))completion;

///获得一组照片的大小
+ (void)photosBytes:(NSArray *)photos completion:(void (^)(NSString *totalBytes))completion;

+ (BOOL)isCameraRollAlbum:(NSString *)albumName;
@end

