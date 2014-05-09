//
//  MyEIrControlPageViewController.m
//  MyEHomeCN2
//
//  Created by 翟强 on 13-12-17.
//  Copyright (c) 2013年 My Energy Domain Inc. All rights reserved.
//

#import "MyEIrControlPageViewController.h"

@interface MyEIrControlPageViewController ()

@end

@implementation MyEIrControlPageViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.slideSwitchView.slideSwitchViewDelegate = self;
    self.slideSwitchView.tabItemNormalColor = [SUNSlideSwitchView colorFromHexRGB:@"868686"];
    self.slideSwitchView.tabItemSelectedColor = [SUNSlideSwitchView colorFromHexRGB:@"bb0b15"];
    self.slideSwitchView.shadowImage = [UIImage imageNamed:@"red_line_btn.png"];//这里可以认为是九宫格的样式
    self.irUserKeyViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"IrUserKeyVC"];
    self.irUserKeyViewController.device = self.device;

    if (self.device.typeId.intValue == 2) {
        self.navigationItem.title = @"电视控制";
        self.tvDefaultViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"TvDefaultVC"];
        self.tvDefaultViewController.device = self.device;
    }else{
        self.navigationItem.title = @"音响控制";
        self.audioDefaultViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"AudioDefaultVC"];
        self.audioDefaultViewController.device = self.device;
    }
    
    [self.slideSwitchView buildUI];
}

- (IBAction)changMode:(UIBarButtonItem *)sender {
    if ([sender.title isEqualToString:@"学习模式"]) {
        sender.title = @"退出学习";
        if (self.device.typeId.intValue == 2) {
            self.tvDefaultViewController.isControlMode = NO;
            self.tvDefaultViewController.view.backgroundColor = [UIColor colorWithRed:0.84 green:0.93 blue:0.95 alpha:1];
        }else{
            self.audioDefaultViewController.isControlMode = NO;
            self.audioDefaultViewController.view.backgroundColor = [UIColor colorWithRed:0.84 green:0.93 blue:0.95 alpha:1];
        }
        self.irUserKeyViewController.isControlMode = NO;
        self.irUserKeyViewController.view.backgroundColor = [UIColor colorWithRed:0.84 green:0.93 blue:0.95 alpha:1];
    }else{
        sender.title = @"学习模式";
        if (self.device.typeId.intValue == 2) {
            self.tvDefaultViewController.isControlMode = YES;
            self.tvDefaultViewController.view.backgroundColor = [UIColor colorWithRed:0.97 green:0.97 blue:0.97 alpha:1];
        }else{
            self.audioDefaultViewController.isControlMode = YES;
            self.audioDefaultViewController.view.backgroundColor = [UIColor colorWithRed:0.97 green:0.97 blue:0.97 alpha:1];
        }
        self.irUserKeyViewController.isControlMode = YES;
        self.irUserKeyViewController.view.backgroundColor = [UIColor colorWithRed:0.97 green:0.97 blue:0.97 alpha:1];
    }
}

#pragma mark - 滑动tab视图代理方法

- (NSUInteger)numberOfTab:(SUNSlideSwitchView *)view
{
    return 2;
}

- (UIViewController *)slideSwitchView:(SUNSlideSwitchView *)view viewOfTab:(NSUInteger)number
{
    if (number == 0) {
        if (self.device.typeId.intValue == 2) {
            return self.tvDefaultViewController;
        }else{
            return self.audioDefaultViewController;
        }
    }else{
         return self.irUserKeyViewController;
    }
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}
@end