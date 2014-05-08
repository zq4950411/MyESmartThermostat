//
//  MyERoomsTableViewController.h
//  MyE
//
//  Created by 翟强 on 14-4-23.
//  Copyright (c) 2014年 MyEnergy Domain. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MyEDevicesViewController.h"
@interface MyERoomsTableViewController : UITableViewController<MyEDataLoaderDelegate,UIAlertViewDelegate>

@property (nonatomic, strong) NSMutableDictionary *mainDic;
@property (nonatomic,strong) MyEMainDevice *mainDevice;
@end
