//
//  MyEACManualControlNavController.m
//  MyEHomeCN2
//
//  Created by 翟强 on 14-7-19.
//  Copyright (c) 2014年 My Energy Domain Inc. All rights reserved.
//

#import "MyEACManualControlNavController.h"
#import "MyEAcUserModelViewController.h"
#import "MyEAcManualControlViewController.h"
@interface MyEACManualControlNavController ()

@end

@implementation MyEACManualControlNavController

#pragma mark - life circle method
- (void)viewDidLoad
{
    [super viewDidLoad];
    if (!self.device.isSystemDefined) {
        MyEAcUserModelViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"customControl"];
        vc.device = self.device;
        [self setViewControllers:@[vc] animated:YES];
    }else{
        MyEAcManualControlViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"standerdControl"];
        vc.device = self.device;
        [self setViewControllers:@[vc] animated:YES];
    }
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}
@end
