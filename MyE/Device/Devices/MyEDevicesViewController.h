//
//  SmartUpViewController.h
//  MyE
//
//  Created by space on 13-8-6.
//  Copyright (c) 2013年 MyEnergy Domain. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MyEDataLoader.h"
#import "EGORefreshTableHeaderView.h"
#import "MBProgressHUD.h"
#import "MyEDevice.h"
#import "MyEHouseData.h"
#import "SVProgressHUD.h"
#import "MyEUtil.h"
#import "MyETerminalData.h"
#import "KxMenu.h"
@interface MyEDevicesViewController : UIViewController <UITableViewDataSource,UITableViewDelegate,UIAlertViewDelegate,MyEDataLoaderDelegate,EGORefreshTableHeaderDelegate>

@property (nonatomic, strong) MyEMainDevice *mainDevice;
@property (nonatomic) BOOL needRefresh;

@property (weak, nonatomic) IBOutlet UIButton *roomBtn;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *sidebarButton;

@end
