//
//  BYCropTestController.m
//  BYImagePicker
//
//  Created by Beryter on 2017/3/1.
//  Copyright © 2017年 Beryter. All rights reserved.
//

#import "BYCropTestController.h"

@interface BYCropTestController ()

@end

@implementation BYCropTestController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    UIImageView *imageview = [[UIImageView alloc] initWithFrame:self.view.bounds];
    imageview.contentMode = UIViewContentModeCenter;
    imageview.image = self.image;
    [self.view addSubview:imageview];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

@end
