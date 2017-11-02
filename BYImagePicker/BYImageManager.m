//
//  BYImageManager.m
//  BYImagePicker
//
//  Created by Beryter on 2017/2/12.
//  Copyright © 2017年 Beryter. All rights reserved.
//
#import "BYImageManager.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "BYAsset.h"
#import "BYAlbum.h"

@interface BYImageManager ()
@end

@implementation BYImageManager

+ (instancetype)manager {
    static BYImageManager *manager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[BYImageManager alloc] init];
    });
    return manager;
}

- (instancetype)init
{
    if (self = [super init]) {
        _selectedAssets = [NSMutableArray array];
    }
    return self;
}

- (void)clear
{
    [self.selectedAssets removeAllObjects];
    self.maxImagesCount = 9;
    self.minImagesCount = 0;
}

- (NSInteger)selectedAssetsCount
{
    return self.selectedAssets.count;
}

/// Return YES if Authorized 返回YES如果得到了授权
+ (BOOL)authorizationStatusAuthorized {
    
    return [[self class] authorizationStatus] == PHAuthorizationStatusAuthorized;
}

+ (PHAuthorizationStatus)authorizationStatus {
    
    return [PHPhotoLibrary authorizationStatus];
}

/// 是否能使用相册
+ (BOOL)canUsePhotoLibrary
{
    PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
    if (status == PHAuthorizationStatusRestricted ||
        status == PHAuthorizationStatusDenied) {
        //无权限
        return NO;
    }
    return YES;
}

+ (BOOL)canUseCamera
{
    AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if (status == AVAuthorizationStatusAuthorized) {
        return YES;
    }
    return NO;
}

#pragma mark - Get Album
///获得相册/相册数组
+ (BYAlbum *)fetchCameraRollImageAlbum
{
    return [[self class] fetchCameraRollAlbumMediaType:PHAssetMediaTypeImage];
}

+ (BYAlbum *)fetchCameraRollVideoAlbum
{
    return [[self class] fetchCameraRollAlbumMediaType:PHAssetMediaTypeVideo];
}

+ (BYAlbum *)fetchCameraRollAudioAlbum
{
    return [[self class] fetchCameraRollAlbumMediaType:PHAssetMediaTypeAudio];
}

+ (BYAlbum *)fetchCameraRollAlbum
{
    return [[self class] fetchCameraRollAlbumMediaType:PHAssetMediaTypeUnknown];
}

+ (BYAlbum *)fetchCameraRollAlbumMediaType:(PHAssetMediaType)type
{
    PHFetchOptions *option = [[PHFetchOptions alloc] init];
    if (type != PHAssetMediaTypeUnknown) {
        option.predicate = [NSPredicate predicateWithFormat:@"mediaType == %ld", type];
    }
    option.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO]];
    PHFetchResult *smartAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
    for (PHAssetCollection *collection in smartAlbums) {
        // 有可能是PHCollectionList类的的对象，过滤掉
        if (![collection isKindOfClass:[PHAssetCollection class]])
        {
            continue;
        }
        if ([[self class] isCameraRollAlbum:collection.localizedTitle]) {
            PHFetchResult *fetchResult = [PHAsset fetchAssetsInAssetCollection:collection options:option];
            BYAlbum *album = [[BYAlbum alloc] init];
            album.fetchResult = fetchResult;
            album.name = collection.localizedTitle;
            return album;
        }
    }
    return nil;
}

+ (NSArray<BYAlbum *> *)fetchAllAlbums
{
    return [[self class] fetchAlbumsMediaType:PHAssetMediaTypeUnknown];
}
+ (NSArray<BYAlbum *> *)fetchAllImageAlbums
{
    return [[self class] fetchAlbumsMediaType:PHAssetMediaTypeImage];
}
+ (NSArray<BYAlbum *> *)fetchAllVideoAlbums
{
    return [[self class] fetchAlbumsMediaType:PHAssetMediaTypeVideo];
}
+ (NSArray<BYAlbum *> *)fetchAllAudioAlbums
{
    return [[self class] fetchAlbumsMediaType:PHAssetMediaTypeAudio];
}

+ (NSArray<BYAlbum *> *)fetchAlbumsMediaType:(PHAssetMediaType)type
{
    NSMutableArray *albums = [NSMutableArray array];
    PHFetchOptions *option = [[PHFetchOptions alloc] init];
    
    if (type != PHAssetMediaTypeUnknown) {
        option.predicate = [NSPredicate predicateWithFormat:@"mediaType == %ld",
                            type];
    }
    option.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO]];
    PHFetchResult *myPhotoStreamAlbum = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAlbumMyPhotoStream options:nil];
    PHFetchResult *smartAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
    PHFetchResult *topLevelUserCollections = [PHCollectionList fetchTopLevelUserCollectionsWithOptions:nil];
    PHFetchResult *syncedAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAlbumSyncedAlbum options:nil];
    PHFetchResult *sharedAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAlbumCloudShared options:nil];
    NSArray *allAlbums = @[myPhotoStreamAlbum, smartAlbums, topLevelUserCollections, syncedAlbums, sharedAlbums];
    for (PHFetchResult *fetchResult in allAlbums) {
        for (PHAssetCollection *collection in fetchResult) {
            // 有可能是PHCollectionList类的的对象，过滤掉
            if (![collection isKindOfClass:[PHAssetCollection class]])
            {
                continue;
            }
            PHFetchResult *fetchResult = [PHAsset fetchAssetsInAssetCollection:collection options:option];
            if (!fetchResult || fetchResult.count == 0) {
                continue;
            }
            if ([collection.localizedTitle containsString:@"Deleted"] || [collection.localizedTitle isEqualToString:@"最近删除"])
            {
                continue;
            }
            BYAlbum *album = [[BYAlbum alloc] init];
            album.fetchResult = fetchResult;
            album.name = collection.localizedTitle;
            
            if ([self isCameraRollAlbum:collection.localizedTitle]) {
                [albums insertObject:album atIndex:0];
            } else {
                [albums addObject:album];
            }
        }
    }
    return albums;
}
#pragma mark - Get Assets
+ (NSArray<BYAsset *> *)fetchImageAssetsIn:(PHFetchResult *)result
{
    return [[self class] fetchAssetsIn:result assetType:PHAssetMediaTypeImage];
}
+ (NSArray<BYAsset *> *)fetchVideoAssetsIn:(PHFetchResult *)result
{
    return [[self class] fetchAssetsIn:result assetType:PHAssetMediaTypeVideo];
}
+ (NSArray<BYAsset *> *)fetchAudioAssetsIn:(PHFetchResult *)result
{
    return [[self class] fetchAssetsIn:result assetType:PHAssetMediaTypeAudio];
}
+ (NSArray<BYAsset *> *)fetchAllAssetsIn:(PHFetchResult *)result
{
    return [[self class] fetchAssetsIn:result assetType:PHAssetMediaTypeUnknown];
}

+ (BYAsset *)fetchAssetIn:(PHFetchResult *)result atIndex:(NSInteger)index
{
    if (result && result.count > 0 && index < result.count) {
        PHAsset *asset = result[index];
        BYAsset *byAsset = [BYAsset modelWithAsset:asset];
        return byAsset;
    }
    return nil;
}

/// 获取assets数组
+ (NSArray<BYAsset *> *)fetchAssetsIn:(PHFetchResult *)result assetType:(PHAssetMediaType)type
{
    NSMutableArray *photos = [NSMutableArray array];
    PHFetchResult *fetchResult = (PHFetchResult *)result;
    [fetchResult enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        PHAsset *asset = (PHAsset *)obj;
        if (type == PHAssetMediaTypeUnknown) {
            BYAsset *byAsset = [BYAsset modelWithAsset:asset];
            [photos addObject:byAsset];
            return;
        }
        if (asset.mediaType != type) {
            return;
        }
        BYAsset *byAsset = [BYAsset modelWithAsset:asset];
        [photos addObject:byAsset];
    }];
    return photos;
}

+ (void)fetchAssetsIn:(PHFetchResult *)result complete:(BYAssetsFetchBlock)fetchBlock
{
   NSMutableArray *allAssets = [NSMutableArray array];
   NSMutableArray *photoAssets = [NSMutableArray array];
   NSMutableArray *videoAssets = [NSMutableArray array];
   NSMutableArray *audioAssets = [NSMutableArray array];
    
    PHFetchResult *fetchResult = (PHFetchResult *)result;
    [fetchResult enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        PHAsset *asset = (PHAsset *)obj;
        BYAsset *byAsset = [BYAsset modelWithAsset:asset];
        [allAssets addObject:byAsset];
        switch (asset.mediaType) {
            case PHAssetMediaTypeUnknown:
                [photoAssets addObject:byAsset];
                break;
            case PHAssetMediaTypeImage:
                [photoAssets addObject:byAsset];
                break;
            case PHAssetMediaTypeAudio:
                [audioAssets addObject:byAsset];
                break;
            case PHAssetMediaTypeVideo:
                [videoAssets addObject:byAsset];
                break;
        }
    }];
    if (fetchBlock) {
        fetchBlock(allAssets,photoAssets,videoAssets,audioAssets);
    }
}

/// Get photo bytes 获得一组照片的大小
+ (void)photosBytes:(NSArray *)photos completion:(void (^)(NSString *totalBytes))completion {
    __block NSInteger dataLength = 0;
    __block NSInteger assetCount = 0;
    for (NSInteger i = 0; i < photos.count; i++) {
        BYAsset *model = photos[i];
        [[PHImageManager defaultManager] requestImageDataForAsset:model.asset options:nil resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
            
            if (model.asset.mediaType == PHAssetMediaTypeImage) {
                dataLength += imageData.length;
            }
            assetCount ++;
            if (assetCount >= photos.count) {
                NSString *bytes = [[self class] getBytesFromDataLength:dataLength];
                if (completion)
                {
                    completion(bytes);
                }
            }
        }];
    }
}

+ (NSString *)getBytesFromDataLength:(NSInteger)dataLength {
    NSString *bytes;
    if (dataLength >= 0.1 * (1024 * 1024)) {
        bytes = [NSString stringWithFormat:@"%0.1fM",dataLength/1024/1024.0];
    } else if (dataLength >= 1024) {
        bytes = [NSString stringWithFormat:@"%0.0fK",dataLength/1024.0];
    } else {
        bytes = [NSString stringWithFormat:@"%zdB",dataLength];
    }
    return bytes;
}

#pragma mark - Get Photo

///获得照片本身
+ (PHImageRequestID)fetchImageInAsset:(PHAsset *)asset imageWidth:(CGFloat)width completion:(BYImageFetchBlock)completion
{
    return [[self class] fetchImageInAsset:asset imageWidth:width fixOrientation:YES completion:completion];
}

+ (PHImageRequestID)fetchImageInAsset:(PHAsset *)asset imageWidth:(CGFloat)width fixOrientation:(BOOL)fix completion:(BYImageFetchBlock)completion
{
    CGSize imageSize;
    CGFloat aspectRatio = asset.pixelWidth / (CGFloat)asset.pixelHeight;
    CGFloat pixelWidth = width * [UIScreen mainScreen].scale;
    CGFloat pixelHeight = pixelWidth / aspectRatio;
    imageSize = CGSizeMake(pixelWidth, pixelHeight);
    PHImageRequestOptions *option = [[PHImageRequestOptions alloc] init];
    option.resizeMode = PHImageRequestOptionsResizeModeFast;
    PHImageRequestID imageRequestID = [[PHImageManager defaultManager] requestImageForAsset:asset targetSize:imageSize contentMode:PHImageContentModeAspectFill options:option resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        BOOL downloadFinined = (![[info objectForKey:PHImageCancelledKey] boolValue] && ![info objectForKey:PHImageErrorKey]);
        // 下面的判断方式会造成稍微的卡顿
//        BOOL downloadFinined = ![[info objectForKey:PHImageCancelledKey] boolValue] && ![info objectForKey:PHImageErrorKey] && ![[info objectForKey:PHImageResultIsDegradedKey] boolValue];
        if (downloadFinined && result) {
            if (fix) {
                result = [[self class] fixOrientation:result];
            }
            if (completion) completion(result,info,[[info objectForKey:PHImageResultIsDegradedKey] boolValue]);
        }
        // Download image from iCloud / 从iCloud下载图片
        if ([info objectForKey:PHImageResultIsInCloudKey] && !result) {
            PHImageRequestOptions *option = [[PHImageRequestOptions alloc]init];
            option.networkAccessAllowed = YES;
            option.resizeMode = PHImageRequestOptionsResizeModeFast;
            [[PHImageManager defaultManager] requestImageDataForAsset:asset options:option resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
                UIImage *resultImage = [UIImage imageWithData:imageData scale:0.1];
                resultImage = [[self class] scaleImage:resultImage toSize:imageSize];
                if (resultImage) {
                    if (fix) {
                        resultImage = [[self class] fixOrientation:resultImage];
                    }
                    if (completion){
                        completion(resultImage,info,[[info objectForKey:PHImageResultIsDegradedKey] boolValue]);
                    }
                }
            }];
        }
    }];
    return imageRequestID;
}

+ (PHImageRequestID)fetchImageInAsset:(PHAsset *)asset completion:(BYImageFetchBlock)completion
{
    return [[self class] fetchImageInAsset:asset imageWidth:[UIScreen mainScreen].bounds.size.width completion:completion];
}

+ (PHImageRequestID)fetchImageInAsset:(PHAsset *)asset networkAllowed:(BOOL)networkAllowed progress:(BYImageLoadProgress)progressHandler completion:(BYImageFetchBlock)completion
{
    return [[self class] fetchImageInAsset:asset imageWidth:[UIScreen mainScreen].bounds.size.width networkAllowed:networkAllowed progress:progressHandler completion:completion];
}

+ (PHImageRequestID)fetchImageInAsset:(PHAsset *)asset imageWidth:(CGFloat)width networkAllowed:(BOOL)networkAllowed progress:(BYImageLoadProgress)progressHandler completion:(BYImageFetchBlock)completion
{
    CGSize imageSize;
    CGFloat aspectRatio = asset.pixelWidth / (CGFloat)asset.pixelHeight;
    CGFloat pixelWidth = width * [UIScreen mainScreen].scale;
    CGFloat pixelHeight = pixelWidth / aspectRatio;
    imageSize = CGSizeMake(pixelWidth, pixelHeight);
    PHImageRequestOptions *option = [[PHImageRequestOptions alloc] init];
    option.resizeMode = PHImageRequestOptionsResizeModeFast;
    PHImageRequestID imageRequestID = [[PHImageManager defaultManager] requestImageForAsset:asset targetSize:imageSize contentMode:PHImageContentModeAspectFill options:option resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        BOOL downloadFinined = (![[info objectForKey:PHImageCancelledKey] boolValue] && ![info objectForKey:PHImageErrorKey]);
//        BOOL downloadFinined = ![[info objectForKey:PHImageCancelledKey] boolValue] && ![info objectForKey:PHImageErrorKey] && ![[info objectForKey:PHImageResultIsDegradedKey] boolValue];
        if (downloadFinined && result) {
            result = [self fixOrientation:result];
            if (completion) completion(result,info,[[info objectForKey:PHImageResultIsDegradedKey] boolValue]);
        }
        // Download image from iCloud / 从iCloud下载图片
        if ([info objectForKey:PHImageResultIsInCloudKey] && !result && networkAllowed) {
            PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
            options.progressHandler = ^(double progress, NSError *error, BOOL *stop, NSDictionary *info) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (progressHandler) {
                        progressHandler(progress, error, stop, info);
                    }
                });
            };
            options.networkAccessAllowed = YES;
            options.resizeMode = PHImageRequestOptionsResizeModeFast;
            [[PHImageManager defaultManager] requestImageDataForAsset:asset options:options resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
                UIImage *resultImage = [UIImage imageWithData:imageData scale:0.1];
                resultImage = [self scaleImage:resultImage toSize:imageSize];
                if (resultImage) {
                    resultImage = [self fixOrientation:resultImage];
                    if (completion) completion(resultImage,info,[[info objectForKey:PHImageResultIsDegradedKey] boolValue]);
                }
            }];
        }
    }];
    return imageRequestID;
}


///获取封面图
+ (void)fetchAlbumCover:(BYAlbum *)album completion:(void (^)(UIImage *image))completion
{
    PHAsset *asset = [album.fetchResult firstObject];
    [[self class] fetchImageInAsset:asset imageWidth:80 completion:^(UIImage *image, NSDictionary *info, BOOL isDegraded) {
        if (completion) {
            completion(image);
        }
    }];
}
/// 获取原图
+ (void)fetchOriginalImageDataInAsset:(PHAsset *)asset completion:(void (^)(NSData *data,NSDictionary *info))completion
{
    PHImageRequestOptions *option = [[PHImageRequestOptions alloc]init];
    option.networkAccessAllowed = YES;
    [[PHImageManager defaultManager] requestImageDataForAsset:asset options:option resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
        BOOL downloadFinined = (![[info objectForKey:PHImageCancelledKey] boolValue] && ![info objectForKey:PHImageErrorKey]);
//        BOOL downloadFinined = ![[info objectForKey:PHImageCancelledKey] boolValue] && ![info objectForKey:PHImageErrorKey] && ![[info objectForKey:PHImageResultIsDegradedKey] boolValue];
        if (downloadFinined && imageData) {
            if (completion)
            {
                completion(imageData,info);
            }
        }
    }];
}

+ (void)fetchOriginalImageInAsset:(PHAsset *)asset completion:(void (^)(UIImage *image,NSDictionary *info))completion
{
    [[self class] fetchOriginalImageInAsset:asset fixOrientation:YES completion:completion];
}

+ (void)fetchOriginalImageInAsset:(PHAsset *)asset fixOrientation:(BOOL)fix completion:(void (^)(UIImage *image,NSDictionary *info))completion
{
    PHImageRequestOptions *option = [[PHImageRequestOptions alloc]init];
    option.networkAccessAllowed = YES;
    [[PHImageManager defaultManager] requestImageForAsset:asset targetSize:PHImageManagerMaximumSize contentMode:PHImageContentModeDefault options:option resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        BOOL downloadFinined = (![[info objectForKey:PHImageCancelledKey] boolValue] && ![info objectForKey:PHImageErrorKey]);
//        BOOL downloadFinined = ![[info objectForKey:PHImageCancelledKey] boolValue] && ![info objectForKey:PHImageErrorKey] && ![[info objectForKey:PHImageResultIsDegradedKey] boolValue];
        if (downloadFinined && result) {
            UIImage *image = result;
            if (fix) {
                image = [[self class] fixOrientation:result];
            }
            if (completion)
            {
                completion(image,info);
            }
        }
    }];
}

#pragma mark - Save photo

+ (void)saveImage:(UIImage *)image completion:(void (^)(NSError *error))completion {
        NSData *data = UIImageJPEGRepresentation(image, 0.9);
        [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
            PHAssetResourceCreationOptions *options = [[PHAssetResourceCreationOptions alloc] init];
            options.shouldMoveFile = YES;
            [[PHAssetCreationRequest creationRequestForAsset] addResourceWithType:PHAssetResourceTypePhoto data:data options:options];
        } completionHandler:^(BOOL success, NSError * _Nullable error) {
            dispatch_sync(dispatch_get_main_queue(), ^{
                if (success && completion) {
                    completion(nil);
                } else if (error) {
                    NSLog(@"保存照片出错:%@",error.localizedDescription);
                    if (completion) {
                        completion(error);
                    }
                }
            });
        }];
}

#pragma mark - Get Video

///视频
+ (void)fetchPlayerItemInAsset:(PHAsset *)asset completion:(void (^)(AVPlayerItem * playerItem, NSDictionary * info))completion {
    [[PHImageManager defaultManager] requestPlayerItemForVideo:asset options:nil resultHandler:^(AVPlayerItem * _Nullable playerItem, NSDictionary * _Nullable info) {
        if (completion)
        {
            completion(playerItem,info);
        }
    }];
}

#pragma mark - Export video

/// Export Video / 导出视频
+ (void)fetchVideoPathInAsset:(PHAsset *)asset completion:(void (^)(NSString *path))completion
{
    PHVideoRequestOptions* options = [[PHVideoRequestOptions alloc] init];
    options.version = PHVideoRequestOptionsVersionOriginal;
    options.deliveryMode = PHVideoRequestOptionsDeliveryModeAutomatic;
    options.networkAccessAllowed = YES;
    [[PHImageManager defaultManager] requestAVAssetForVideo:asset options:options resultHandler:^(AVAsset* avasset, AVAudioMix* audioMix, NSDictionary* info){
        AVURLAsset *videoAsset = (AVURLAsset*)avasset;
        [[self class] startExportVideoWithVideoAsset:videoAsset completion:completion];
    }];
}
#pragma mark - Export video

+ (void)startExportVideoWithVideoAsset:(AVURLAsset *)videoAsset completion:(void (^)(NSString *outputPath))completion {
    // Find compatible presets by video asset.
    NSArray *presets = [AVAssetExportSession exportPresetsCompatibleWithAsset:videoAsset];
    
    // Begin to compress video
    // Now we just compress to low resolution if it supports
    // If you need to upload to the server, but server does't support to upload by streaming,
    // You can compress the resolution to lower. Or you can support more higher resolution.
    if ([presets containsObject:AVAssetExportPreset640x480]) {
        AVAssetExportSession *session = [[AVAssetExportSession alloc]initWithAsset:videoAsset presetName:AVAssetExportPreset640x480];
        
        NSDateFormatter *formater = [[NSDateFormatter alloc] init];
        [formater setDateFormat:@"yyyy-MM-dd-HH:mm:ss"];
        NSString *outputPath = [NSHomeDirectory() stringByAppendingFormat:@"/tmp/output-%@.mp4", [formater stringFromDate:[NSDate date]]];
        NSLog(@"video outputPath = %@",outputPath);
        session.outputURL = [NSURL fileURLWithPath:outputPath];
        
        // Optimize for network use.
        session.shouldOptimizeForNetworkUse = true;
        
        NSArray *supportedTypeArray = session.supportedFileTypes;
        if ([supportedTypeArray containsObject:AVFileTypeMPEG4]) {
            session.outputFileType = AVFileTypeMPEG4;
        } else if (supportedTypeArray.count == 0) {
            NSLog(@"No supported file types 视频类型暂不支持导出");
            return;
        } else {
            session.outputFileType = [supportedTypeArray objectAtIndex:0];
        }
        
        if (![[NSFileManager defaultManager] fileExistsAtPath:[NSHomeDirectory() stringByAppendingFormat:@"/tmp"]]) {
            [[NSFileManager defaultManager] createDirectoryAtPath:[NSHomeDirectory() stringByAppendingFormat:@"/tmp"] withIntermediateDirectories:YES attributes:nil error:nil];
        }
        
        // 修正视频转向
        session.videoComposition = [[self class]fixedCompositionWithAsset:videoAsset];
        
        // Begin to export video to the output path asynchronously.
        [session exportAsynchronouslyWithCompletionHandler:^(void) {
            switch (session.status) {
                case AVAssetExportSessionStatusUnknown:
                    NSLog(@"AVAssetExportSessionStatusUnknown"); break;
                case AVAssetExportSessionStatusWaiting:
                    NSLog(@"AVAssetExportSessionStatusWaiting"); break;
                case AVAssetExportSessionStatusExporting:
                    NSLog(@"AVAssetExportSessionStatusExporting"); break;
                case AVAssetExportSessionStatusCompleted: {
                    NSLog(@"AVAssetExportSessionStatusCompleted");
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (completion) {
                            completion(outputPath);
                        }
                    });
                }  break;
                case AVAssetExportSessionStatusFailed:
                    NSLog(@"AVAssetExportSessionStatusFailed"); break;
                default: break;
            }
        }];
    }
}

+ (BOOL)isCameraRollAlbum:(NSString *)albumName {
    NSString *versionStr = [[UIDevice currentDevice].systemVersion stringByReplacingOccurrencesOfString:@"." withString:@""];
    if (versionStr.length <= 1) {
        versionStr = [versionStr stringByAppendingString:@"00"];
    } else if (versionStr.length <= 2) {
        versionStr = [versionStr stringByAppendingString:@"0"];
    }
    CGFloat version = versionStr.floatValue;
    // 目前已知8.0.0 - 8.0.2系统，拍照后的图片会保存在最近添加中
    if (version >= 800 && version <= 802) {
        return [albumName isEqualToString:@"最近添加"] || [albumName isEqualToString:@"Recently Added"];
    } else {
        return [albumName isEqualToString:@"Camera Roll"] || [albumName isEqualToString:@"相机胶卷"] || [albumName isEqualToString:@"所有照片"] || [albumName isEqualToString:@"All Photos"];
    }
}

#pragma mark - Private Method

+ (UIImage *)scaleImage:(UIImage *)image toSize:(CGSize)size {
    if (image.size.width > size.width) {
        UIGraphicsBeginImageContext(size);
        [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
        UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return newImage;
    } else {
        return image;
    }
}

/// 获取优化后的视频转向信息
+ (AVMutableVideoComposition *)fixedCompositionWithAsset:(AVAsset *)videoAsset {
    AVMutableVideoComposition *videoComposition = [AVMutableVideoComposition videoComposition];
    // 视频转向
    int degrees = [[self class] degressFromVideoFileWithAsset:videoAsset];
    if (degrees != 0) {
        CGAffineTransform translateToCenter;
        CGAffineTransform mixedTransform;
        videoComposition.frameDuration = CMTimeMake(1, 30);
        
        NSArray *tracks = [videoAsset tracksWithMediaType:AVMediaTypeVideo];
        AVAssetTrack *videoTrack = [tracks objectAtIndex:0];
        
        if (degrees == 90) {
            // 顺时针旋转90°
            translateToCenter = CGAffineTransformMakeTranslation(videoTrack.naturalSize.height, 0.0);
            mixedTransform = CGAffineTransformRotate(translateToCenter,M_PI_2);
            videoComposition.renderSize = CGSizeMake(videoTrack.naturalSize.height,videoTrack.naturalSize.width);
        } else if(degrees == 180){
            // 顺时针旋转180°
            translateToCenter = CGAffineTransformMakeTranslation(videoTrack.naturalSize.width, videoTrack.naturalSize.height);
            mixedTransform = CGAffineTransformRotate(translateToCenter,M_PI);
            videoComposition.renderSize = CGSizeMake(videoTrack.naturalSize.width,videoTrack.naturalSize.height);
        } else if(degrees == 270){
            // 顺时针旋转270°
            translateToCenter = CGAffineTransformMakeTranslation(0.0, videoTrack.naturalSize.width);
            mixedTransform = CGAffineTransformRotate(translateToCenter,M_PI_2*3.0);
            videoComposition.renderSize = CGSizeMake(videoTrack.naturalSize.height,videoTrack.naturalSize.width);
        }else{
            
        }
        
        AVMutableVideoCompositionInstruction *roateInstruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
        roateInstruction.timeRange = CMTimeRangeMake(kCMTimeZero, [videoAsset duration]);
        AVMutableVideoCompositionLayerInstruction *roateLayerInstruction = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:videoTrack];
        
        [roateLayerInstruction setTransform:mixedTransform atTime:kCMTimeZero];
        
        roateInstruction.layerInstructions = @[roateLayerInstruction];
        // 加入视频方向信息
        videoComposition.instructions = @[roateInstruction];
    }
    return videoComposition;
}

/// 获取视频角度
+ (int)degressFromVideoFileWithAsset:(AVAsset *)asset {
    int degress = 0;
    NSArray *tracks = [asset tracksWithMediaType:AVMediaTypeVideo];
    if([tracks count] > 0) {
        AVAssetTrack *videoTrack = [tracks objectAtIndex:0];
        CGAffineTransform t = videoTrack.preferredTransform;
        if(t.a == 0 && t.b == 1.0 && t.c == -1.0 && t.d == 0){
            // Portrait
            degress = 90;
        } else if(t.a == 0 && t.b == -1.0 && t.c == 1.0 && t.d == 0){
            // PortraitUpsideDown
            degress = 270;
        } else if(t.a == 1.0 && t.b == 0 && t.c == 0 && t.d == 1.0){
            // LandscapeRight
            degress = 0;
        } else if(t.a == -1.0 && t.b == 0 && t.c == 0 && t.d == -1.0){
            // LandscapeLeft
            degress = 180;
        }
    }
    return degress;
}

/// 修正图片转向
+ (UIImage *)fixOrientation:(UIImage *)aImage {
    
    // No-op if the orientation is already correct
    if (aImage.imageOrientation == UIImageOrientationUp)
        return aImage;
    
    // We need to calculate the proper transformation to make the image upright.
    // We do it in 2 steps: Rotate if Left/Right/Down, and then flip if Mirrored.
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    switch (aImage.imageOrientation) {
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, aImage.size.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
            
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, aImage.size.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
        default:
            break;
    }
    
    switch (aImage.imageOrientation) {
        case UIImageOrientationUpMirrored:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
            
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
        default:
            break;
    }
    
    // Now we draw the underlying CGImage into a new context, applying the transform
    // calculated above.
    CGContextRef ctx = CGBitmapContextCreate(NULL, aImage.size.width, aImage.size.height,
                                             CGImageGetBitsPerComponent(aImage.CGImage), 0,
                                             CGImageGetColorSpace(aImage.CGImage),
                                             CGImageGetBitmapInfo(aImage.CGImage));
    CGContextConcatCTM(ctx, transform);
    switch (aImage.imageOrientation) {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            // Grr...
            CGContextDrawImage(ctx, CGRectMake(0,0,aImage.size.height,aImage.size.width), aImage.CGImage);
            break;
            
        default:
            CGContextDrawImage(ctx, CGRectMake(0,0,aImage.size.width,aImage.size.height), aImage.CGImage);
            break;
    }
    
    // And now we just create a new UIImage from the drawing context
    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
    UIImage *img = [UIImage imageWithCGImage:cgimg];
    CGContextRelease(ctx);
    CGImageRelease(cgimg);
    return img;
}

@end

