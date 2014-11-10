//
//  MyECurtainControlViewController.m
//  MyEHomeCN2
//
//  Created by 翟强 on 13-12-11.
//  Copyright (c) 2013年 My Energy Domain Inc. All rights reserved.
//

#import "MyECurtainControlViewController.h"

@interface MyECurtainControlViewController ()

@end

@implementation MyECurtainControlViewController

#pragma mark - life circle methods
- (void)viewDidLoad
{
    _keyBtns = self.controlBtns;
    _initNumber = 400;
    [super viewDidLoad];
}
#pragma mark - memory warning method
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}
#pragma mark - IBAction methods
- (IBAction)editKey:(UIBarButtonItem *)sender {
    if ([sender.title isEqualToString:@"Record"]) {
        sender.title = @"Exit";
        self.isControlMode = NO;
        self.view.backgroundColor = [UIColor colorWithRed:0.84 green:0.93 blue:0.95 alpha:1];
    }else{
        sender.title = @"Record";
        self.isControlMode = YES;
        self.view.backgroundColor = [UIColor colorWithRed:0.97 green:0.97 blue:0.97 alpha:1];
    }
}

@end
