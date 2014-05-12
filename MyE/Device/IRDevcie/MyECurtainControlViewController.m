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

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
#pragma mark - life circle methods
- (void)viewDidLoad
{
    [super viewDidLoad];
    _keyBtns = self.controlBtns;
    _initNumber = 400;
}
#pragma mark - memory warning method
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
