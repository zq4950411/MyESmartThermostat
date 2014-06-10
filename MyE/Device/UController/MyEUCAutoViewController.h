//
//  MyEUCAutoViewController.h
//  MyE
//
//  Created by 翟强 on 14-6-6.
//  Copyright (c) 2014年 MyEnergy Domain. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MyEUCInfo.h"
#import "EGORefreshTableHeaderView.h"
#import "MyEUCScheduleViewController.h"
@interface MyEUCAutoViewController : UITableViewController<MyEDataLoaderDelegate,EGORefreshTableHeaderDelegate>

@property (nonatomic, weak) MyEDevice *device;
@property (nonatomic, strong) MyEUCAuto *ucAuto;
@end
