//
//  BYImageManager.h
//  BYImagePicker
//
//  Created by Beryter on 2017/2/12.
//  Copyright © 2017年 Beryter. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Photos/Photos.h>

#define iOS8Later ([UIDevice currentDevice].systemVersion.floatValue >= 8.0f)
#define iOS9Later ([UIDevice currentDevice].systemVersion.floatValue >= 9.0f)
#define iOS9_1Later ([UIDevice currentDevice].systemVersion.floatValue >= 9.1f)
///16进制色值
#define RGB(x) [UIColor colorWithRed:((x & 0xff0000) >> 16)/255.0 green:((x & 0x00ff00) >> 8)/255.0 blue:(x & 0x0000ff)/255.0 alpha:1.0f]
#define RGBA(x,y) [UIColor colorWithRed:((x & 0xff0000) >> 16)/255.0 green:((x & 0x00ff00) >> 8)/255.0 blue:(x & 0x0000ff)/255.0 alpha:y]

@class BYAlbum,BYAsset;
typedef void(^BYImageFetchBlock)(UIImage *image,NSDictionary *info,BOOL isDegraded);
typedef void(^BYAssetsFetchBlock)(NSArray<BYAsset *> *allAssets, NSArray<BYAsset *> *photoAssets, NSArray<BYAsset *> *videoAssets, NSArray<BYAsset *> *audioAssets);
typedef void(^BYImageLoadProgress)(CGFloat progress, NSError *error, BOOL *stop, NSDictionary *info);

@interface BYImageManager : NSObject

+ (instancetype)manager;
- (void)clear;

@property (nonatomic, strong) NSMutableArray *selectedAssets;
@property (nonatomic, assign, readonly) NSInteger selectedAssetsCount;
/// 默认最大可选9张图片
@property (nonatomic, assign) NSInteger maxImagesCount;
/// 最小照片必选张数,默认是0
@property (nonatomic, assign) NSInteger minImagesCount;

/// 返回YES如果得到了授权
+ (BOOL)authorizationStatusAuthorized;
+ (NSInteger)authorizationStatus;

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
+ (PHImageRequestID)fetchImageInAsset:(PHAsset *)asset imageWidth:(CGFloat)width completion:(BYImageFetchBlock)completion;
+ (PHImageRequestID)fetchImageInAsset:(PHAsset *)asset imageWidth:(CGFloat)width fixOrientation:(BOOL)fix completion:(BYImageFetchBlock)completion;
+ (PHImageRequestID)fetchImageInAsset:(PHAsset *)asset completion:(BYImageFetchBlock)completion;
+ (PHImageRequestID)fetchImageInAsset:(PHAsset *)asset networkAllowed:(BOOL)networkAllowed progress:(BYImageLoadProgress)progressHandler completion:(BYImageFetchBlock)completion;
+ (PHImageRequestID)fetchImageInAsset:(PHAsset *)asset imageWidth:(CGFloat)width networkAllowed:(BOOL)networkAllowed progress:(BYImageLoadProgress)progressHandler completion:(BYImageFetchBlock)completion;

+ (void)fetchAlbumCover:(BYAlbum *)album completion:(void (^)(UIImage *image))completion;
+ (void)fetchOriginalImageDataInAsset:(PHAsset *)asset completion:(void (^)(NSData *data,NSDictionary *info))completion;
+ (void)fetchOriginalImageInAsset:(PHAsset *)asset completion:(void (^)(UIImage *image,NSDictionary *info))completion;
+ (void)fetchOriginalImageInAsset:(PHAsset *)asset fixOrientation:(BOOL)fix completion:(void (^)(UIImage *image,NSDictionary *info))completion;

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

