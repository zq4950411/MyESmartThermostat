//
//  SettingViewController.h
//  MyE
//
//  Created by space on 13-8-30.
//  Copyright (c) 2013年 MyEnergy Domain. All rights reserved.
//

#import "BaseTableViewController.h"
#import "DictionaryTableViewViewController.h"

#import "GatewayEntity.h"
#import "GatewayDeviceCell.h"
#import "MyEDataLoader.h"

@interface SettingViewController : BaseTableViewController<UITableViewDataSource,UITableViewDelegate,GatewayDelegate,UIAlertViewDelegate,UITextFieldDelegate,DictionaryDelegate,MyEDataLoaderDelegate,GatewayDelegate>
{
    GatewayEntity *gateway;
    
    int currentDeleteIndex;
    int requestCount;
}

@property (nonatomic,strong) GatewayEntity *gateway;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *sidebarButton;

@end
