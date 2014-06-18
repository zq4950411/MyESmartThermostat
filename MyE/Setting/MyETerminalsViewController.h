//
//  MyETerminalsViewController.h
//  MyE
//
//  Created by 翟强 on 14-6-16.
//  Copyright (c) 2014年 MyEnergy Domain. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MyESettingsInfo.h"
#import "MBProgressHUD.h"
#import "EGORefreshTableHeaderView.h"

@interface MyETerminalsViewController : UITableViewController<MyEDataLoaderDelegate,EGORefreshTableHeaderDelegate>
@property (nonatomic, strong) MyESettingsInfo *info;

@end
