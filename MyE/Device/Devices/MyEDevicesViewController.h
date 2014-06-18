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
{
    NSIndexPath *_selectedIndexPath;  //当前选定的indexPath
    NSMutableDictionary *_mainDic;
    MBProgressHUD *HUD;
    NSMutableArray *_devices;
    EGORefreshTableHeaderView *_refreshHeaderView;
    BOOL _isRefreshing;
    BOOL _isDelete;  //表示删除模式，此时指定行是不能编辑的
    UITapGestureRecognizer *_tableTap;   //这两个手势主要用于排序
    UILongPressGestureRecognizer *_tableLong;
}

@property (nonatomic, strong) MyEMainDevice *mainDevice;
@property (nonatomic) BOOL needRefresh;

@property (weak, nonatomic) IBOutlet UIButton *roomBtn;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *sidebarButton;

@end
