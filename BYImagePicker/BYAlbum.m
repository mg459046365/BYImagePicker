//
//  BYAlbum.m
//  BYImagePicker
//
//  Created by Beryter on 2017/2/13.
//  Copyright © 2017年 Beryter. All rights reserved.
//

#import "BYAlbum.h"
#import <Photos/Photos.h>
#import "BYImageManager.h"

@interface BYAlbum ()
/// 封面
@property (nonatomic, strong) UIImage *cover;
/// 所有的资源集合
@property (nonatomic, strong) NSArray<BYAsset *> *assets;
/// 图片集合
@property (nonatomic, strong) NSArray<BYAsset *> *photoAssets;
/// 视频集合
@property (nonatomic, strong) NSArray<BYAsset *> *videoAssets;
/// 音频集合
@property (nonatomic, strong) NSArray<BYAsset *> *audioAssets;
@end

@implementation BYAlbum

- (void)setFetchResult:(PHFetchResult *)fetchResult
{
    _fetchResult = fetchResult;
    _cover = nil;
    self.assets = [BYImageManager fetchAllAssetsIn:fetchResult];
    __weak typeof(self) weakSelf = self;
    [BYImageManager fetchAssetsIn:fetchResult complete:^(NSArray<BYAsset *> *allAssets, NSArray<BYAsset *> *photoAssets, NSArray<BYAsset *> *videoAssets, NSArray<BYAsset *> *audioAssets) {
        weakSelf.assets = [NSArray arrayWithArray:allAssets];
        weakSelf.photoAssets = [NSArray arrayWithArray:photoAssets];
        weakSelf.videoAssets = [NSArray arrayWithArray:videoAssets];
        weakSelf.audioAssets = [NSArray arrayWithArray:audioAssets];
    }];
}

- (void)fetchCover:(void (^)(UIImage *))coverBlock
{
    if (self.cover) {
        coverBlock(self.cover);
        return;
    }
    __weak typeof(self) weakSelf = self;
    [BYImageManager fetchAlbumCover:self completion:^(UIImage *image) {
        weakSelf.cover = image;
        if (coverBlock) {
            coverBlock(image);
        }
    }];
}

- (NSInteger)count
{
    return self.fetchResult.count;
}

- (NSInteger)countWithType:(PHAssetMediaType)type
{
    switch (type) {
        case PHAssetMediaTypeUnknown:
            return self.fetchResult.count;
        case PHAssetMediaTypeImage:
            return self.photoAssets.count;
        case PHAssetMediaTypeAudio:
            return self.audioAssets.count;
        case PHAssetMediaTypeVideo:
            return self.videoAssets.count;
    }
}
@end
