//
//  BYAlbumPickerController.m
//  BYImagePicker
//
//  Created by Beryter on 2017/2/13.
//  Copyright © 2017年 Beryter. All rights reserved.
//

#import "BYAlbumPickerController.h"
#import "BYImagePickerController.h"
#import "BYPhotoPickerController.h"
#import "UIView+BYLayout.h"
#import "BYImageManager.h"
#import "BYAlbumCell.h"
#import "BYAlbum.h"

@interface BYAlbumPickerController ()<UITableViewDataSource,UITableViewDelegate>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray *albums;
@end

@implementation BYAlbumPickerController

- (instancetype)init
{
    if (self = [super init]) {
        _mediaType = PHAssetMediaTypeUnknown;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.view.backgroundColor = [UIColor whiteColor];
    [self fetchAlbums];
    [self.view addSubview:self.tableView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)fetchAlbums {
    self.albums = [BYImageManager fetchAlbumsMediaType:self.mediaType];
    [self.tableView reloadData];
}

#pragma mark - UITableViewDataSource && Delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.albums.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 90.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    BYAlbumCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([BYAlbumCell class]) forIndexPath:indexPath];
    cell.album = self.albums[indexPath.row];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    BYAlbum *album = self.albums[indexPath.item];
    BYPhotoPickerController *controller = [[BYPhotoPickerController alloc] init];
    controller.album = album;
    controller.columnNumber = 3;
    [self.navigationController pushViewController:controller animated:YES];
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

#pragma mark - view
- (UITableView *)tableView
{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 64, self.view.by_width, self.view.by_height - 64) style:UITableViewStylePlain];
        _tableView.tableFooterView = [[UIView alloc] init];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        [_tableView registerClass:[BYAlbumCell class] forCellReuseIdentifier:NSStringFromClass([BYAlbumCell class])];
    }
    return _tableView;
}
@end

