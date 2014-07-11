//
//  MyEThemostatTabBarController.h
//  MyE
//
//  Created by 翟强 on 14-7-9.
//  Copyright (c) 2014年 MyEnergy Domain. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MyEDashboardViewController.h"
#import "MyENext24HrsScheduleViewController.h"
#import "MyEWeeklyScheduleViewController.h"
#import "MyEVacationMasterViewController.h"
#import "MyESpecialDaysScheduleViewController.h"

@interface MyEThemostatTabBarController : UITabBarController
@property (nonatomic, weak) MyEDevice *device;
@end
