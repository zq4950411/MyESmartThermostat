//
//  MyESocketAutoViewController.h
//  MyE
//
//  Created by 翟强 on 14-4-24.
//  Copyright (c) 2014年 MyEnergy Domain. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MyEScheduleCell.h"
#import "EGORefreshTableHeaderView.h"
#import "MyESocketManualViewController.h"
@interface MyESocketAutoViewController : UITableViewController<MyEDataLoaderDelegate,EGORefreshTableHeaderDelegate,UIAlertViewDelegate>
@property (nonatomic, strong) MyEDevice *device;
@property (nonatomic, strong) MyESocketSchedules *schedules;
@property (nonatomic, assign) BOOL needRefresh;
@end
