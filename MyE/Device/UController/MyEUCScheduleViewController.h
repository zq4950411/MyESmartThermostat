//
//  MyEUCScheduleViewController.h
//  MyE
//
//  Created by 翟强 on 14-6-7.
//  Copyright (c) 2014年 MyEnergy Domain. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MyEUCPeriodViewController.h"
#import "MYEWeekButtons.h"
#import "MyEDataLoader.h"
#import "MBProgressHUD.h"
@interface MyEUCScheduleViewController : UIViewController<UITableViewDelegate,UITableViewDataSource,MYEWeekButtonsDelegate,MyEDataLoaderDelegate>
@property (nonatomic, weak) MyEDevice *device;
@property (nonatomic, weak) MyEUCSchedule *schedule;
@property (nonatomic, weak) MyEUCAuto *ucAuto;
@property (nonatomic, assign) BOOL isAdd;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet MYEWeekButtons *weekBtns;
@property (weak, nonatomic) IBOutlet MYEWeekButtons *channels;

@end
