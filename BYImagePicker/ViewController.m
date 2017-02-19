//
//  ViewController.m
//  BYImagePicker
//
//  Created by Beryter on 2017/2/12.
//  Copyright © 2017年 Beryter. All rights reserved.
//

#import "ViewController.h"
#import "BYAlbumPickerController.h"
#import "BYImagePickerController.h"
@interface ViewController ()<BYImagePickerDelegate>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"测试demo";
    self.view.backgroundColor = [UIColor whiteColor];
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(100, 100, 200, 60);
    [button setTitle:@"相册" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(test:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
}

- (void)test:(id)sender
{
    BYImagePickerController *picker = [[BYImagePickerController alloc] init];
    picker.pickerDelegate = self;
    [self presentViewController:picker animated:YES completion:nil];
}

- (void)by_imagePickerControllerDismiss:(BYImagePickerController *)picker
{
    
}

- (void)by_imagePickerController:(BYImagePickerController *)picker didFinishPickingPhotos:(NSArray<UIImage *> *)photos
{
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
