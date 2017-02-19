//
//  BYAlbum.h
//  BYImagePicker
//
//  Created by Beryter on 2017/2/13.
//  Copyright © 2017年 Beryter. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <Photos/Photos.h>

@class BYAsset;
@interface BYAlbum : NSObject
/// 名称
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) PHFetchResult *fetchResult;
/// 所有资源的数量
@property (nonatomic, assign, readonly) NSInteger count;
/// 所有的资源集合
@property (nonatomic, strong, readonly) NSArray<BYAsset *> *assets;
/// 图片集合
@property (nonatomic, strong, readonly) NSArray<BYAsset *> *photoAssets;
/// 视频集合
@property (nonatomic, strong, readonly) NSArray<BYAsset *> *videoAssets;
/// 音频集合
@property (nonatomic, strong, readonly) NSArray<BYAsset *> *audioAssets;
/// 已选择的资源集合
@property (nonatomic, strong) NSArray<BYAsset *> *selectedAssets;

- (void)fetchCover:(void(^)(UIImage *image))coverBlock;
- (NSInteger)countWithType:(PHAssetMediaType)type;
@end
