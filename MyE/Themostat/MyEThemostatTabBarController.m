//
//  MyEThemostatTabBarController.m
//  MyE
//
//  Created by 翟强 on 14-7-9.
//  Copyright (c) 2014年 MyEnergy Domain. All rights reserved.
//

#import "MyEThemostatTabBarController.h"

@interface MyEThemostatTabBarController ()

@end

@implementation MyEThemostatTabBarController

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
    MyEDashboardViewController *dash = [self.storyboard instantiateViewControllerWithIdentifier:@"dash"];
    MyENext24HrsScheduleViewController *next = [self.storyboard instantiateViewControllerWithIdentifier:@"next"];
    MyEWeeklyScheduleViewController *week = [self.storyboard instantiateViewControllerWithIdentifier:@"week"];
    MyEVacationMasterViewController *vacation = [self.storyboard instantiateViewControllerWithIdentifier:@"vacation"];
    MyESpecialDaysScheduleViewController *day = [self.storyboard instantiateViewControllerWithIdentifier:@"ThermostatSpecialDays"];
    if (_device.showSpecialDays) {
        [self setViewControllers:@[dash,next,week,day] animated:YES];
    }else
        [self setViewControllers:@[dash,next,week,vacation] animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
