//
//  MyEUCConditionViewController.h
//  MyE
//
//  Created by 翟强 on 14-6-7.
//  Copyright (c) 2014年 MyEnergy Domain. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MyEDashboardData.h"
#import "MYEWeekButtons.h"
#import "MyEUCInfo.h"
#import "MyEUCChannelSetViewController.h"
#import "MyEUCTimeSetViewController.h"
#import "MyEUCWeatherViewController.h"
@interface MyEUCConditionViewController : UITableViewController<MyEDataLoaderDelegate,MYEWeekButtonsDelegate>
@property (nonatomic, strong) MyEUCSequential *sequential;
@property (nonatomic, weak) MyEDevice *device;
@end
