//
//  SmartUpViewController.h
//  MyE
//
//  Created by space on 13-8-6.
//  Copyright (c) 2013年 MyEnergy Domain. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TableViewWithBlock.h"

@interface MyEDevicesViewController : UIViewController <UITableViewDataSource,UITableViewDelegate,UIAlertViewDelegate,MyEDataLoaderDelegate,EGORefreshTableHeaderDelegate>
{
    NSIndexPath *_selectedIndexPath;  //当前选定的indexPath
    NSMutableDictionary *_mainDic;
    MBProgressHUD *HUD;
    NSMutableArray *_devices;
    EGORefreshTableHeaderView *_refreshHeaderView;
    BOOL _isRefreshing;
}

@property (nonatomic, strong) MyEMainDevice *mainDevice;
@property (nonatomic) BOOL needRefresh;

@property (weak, nonatomic) IBOutlet TableViewWithBlock *roomsTableView;
@property (weak, nonatomic) IBOutlet UIButton *roomBtn;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *sidebarButton;

@end
