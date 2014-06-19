//
//  MyESettingsViewController.h
//  MyE
//
//  Created by 翟强 on 14-6-16.
//  Copyright (c) 2014年 MyEnergy Domain. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EGORefreshTableHeaderView.h"
#import "MyESettingsInfo.h"
#import "ACPButton.h"
#import "MyEAccountData.h"
#import "OpenUDID.h"
#import "MBProgressHUD.h"

@interface MyESettingsViewController : UITableViewController<MyEDataLoaderDelegate,EGORefreshTableHeaderDelegate>
@property (nonatomic, strong) MyESettingsInfo *info;
@property (nonatomic, assign) BOOL needRefresh;
@property (weak, nonatomic) IBOutlet UILabel *userNameLbl;
@property (weak, nonatomic) IBOutlet UISwitch *notiSwitch;
@property (weak, nonatomic) IBOutlet UILabel *terminalCountLbl;
@property (weak, nonatomic) IBOutlet ACPButton *deleteMBtn;
@property (weak, nonatomic) IBOutlet UILabel *midLbl;
@property (weak, nonatomic) IBOutlet UILabel *houseLbl;
@property (weak, nonatomic) IBOutlet UILabel *timeZoneLbl;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *sidebarButton;
@end
