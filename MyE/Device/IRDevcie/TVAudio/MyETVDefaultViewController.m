//
//  MyETVDefaultViewController.m
//  MyE
//
//  Created by 翟强 on 14-4-24.
//  Copyright (c) 2014年 MyEnergy Domain. All rights reserved.
//

#import "MyETVDefaultViewController.h"

@interface MyETVDefaultViewController ()
@end

@implementation MyETVDefaultViewController

#pragma mark - life circle methods
- (void)viewDidLoad
{
    [super viewDidLoad];
    _keyBtns = self.controlBtns;
    _initNumber = 200;
}

#pragma mark - memory warning methods
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
