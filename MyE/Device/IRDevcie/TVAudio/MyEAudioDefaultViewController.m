//
//  MyEAudioDefaultViewController.m
//  MyE
//
//  Created by 翟强 on 14-4-24.
//  Copyright (c) 2014年 MyEnergy Domain. All rights reserved.
//

#import "MyEAudioDefaultViewController.h"

@interface MyEAudioDefaultViewController ()

@end

@implementation MyEAudioDefaultViewController

#pragma mark - life circle methods
- (void)viewDidLoad
{
    _keyBtns = self.controlBtns;
    _initNumber = 300;
    
    [super viewDidLoad];  //此处特别要注意，因为此处的super是irDefault，必须在传值完成之后才能调用父类的viewDidLoad方法
}

#pragma mark - memory warning methods
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
