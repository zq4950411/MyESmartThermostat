//
//  MyESwitchEditViewController.h
//  MyEHomeCN2
//
//  Created by 翟强 on 14-3-3.
//  Copyright (c) 2014年 My Energy Domain Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MyESwitchInfo.h"
#import "SmartUp.h"
@interface MyESwitchEditViewController : UITableViewController<MyEDataLoaderDelegate,IQActionSheetPickerView>{
    MBProgressHUD *HUD;
    NSInteger _selectedIndex;
    NSInteger _reportTime;
    MyERoom *_room;
    NSArray *_initArray;  //这里采用数组来记录初始值，以前都是使用的字典
}

@property(nonatomic,weak) SmartUp *device;

@property(nonatomic,strong) MyESwitchInfo *switchInfo;
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UILabel *roomLabel;
@property (weak, nonatomic) IBOutlet UILabel *terminalID;
@property (weak, nonatomic) IBOutlet UITableViewCell *table0;
@property (weak, nonatomic) IBOutlet UITableViewCell *table1;
@property (weak, nonatomic) IBOutlet UILabel *tableLabel;

@end
