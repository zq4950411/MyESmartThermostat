//
//  SmartUpViewController.h
//  MyE
//
//  Created by space on 13-8-6.
//  Copyright (c) 2013年 MyEnergy Domain. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseTableViewController.h"
#import "MyESwitchEditViewController.h"
#import "MyEDeviceAddOrEditTableViewController.h"
#import "TableViewWithBlock.h"
#import "MyERoomsTableViewController.h"
#import "MyESocketManualViewController.h"
@class MyEDevice;

@interface MyEDevicesViewController : BaseTableViewController <UITableViewDataSource,UITableViewDelegate,UIAlertViewDelegate>
{
    NSInteger currentTapIndex;
    NSIndexPath *_selectedIndexPath;
    NSMutableDictionary *_mainDic;
}

-(MyEDevice *) getCurrentSmartup;
@property (weak, nonatomic) IBOutlet TableViewWithBlock *roomsTableView;
@property (nonatomic, strong) MyEMainDevice *mainDevice;
@property (weak, nonatomic) IBOutlet UIButton *roomBtn;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *sidebarButton;
@property (nonatomic) BOOL needRefresh;

@end
