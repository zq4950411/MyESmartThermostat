//
//  MyETimeZoneViewController.h
//  MyE
//
//  Created by 翟强 on 14-6-11.
//  Copyright (c) 2014年 MyEnergy Domain. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MyEMediatorRegisterViewController.h"
#import "MyESettingsViewController.h"
#import "MyESettingsInfo.h"
@interface MyETimeZoneViewController : UITableViewController<MyEDataLoaderDelegate>
@property (nonatomic, weak) MyESettingsInfo *info;
@property (nonatomic) NSInteger timeZone;
@property (nonatomic, assign) BOOL jumpFromSettingPanel;  //从设置面板进来
@end
