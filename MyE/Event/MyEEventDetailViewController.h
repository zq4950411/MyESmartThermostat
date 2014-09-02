//
//  MyEEventDetailViewController.h
//  MyE
//
//  Created by 翟强 on 14-8-29.
//  Copyright (c) 2014年 MyEnergy Domain. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "MyEDataLoader.h"
#import "MyEEventInfo.h"
#import "MyEUtil.h"
#import "MBProgressHUD.h"
#import "SVProgressHUD.h"
#import "DXAlertView.h"

@interface MyEEventDetailViewController : UITableViewController<MyEDataLoaderDelegate>

@property (nonatomic, strong) MyEEvents *events;
@property (nonatomic, strong) MyEEventInfo *eventInfo;
@property (nonatomic, strong) MyEEventDetail *eventDetail;
@property (nonatomic, assign) BOOL isAdd;  //表示现在是新增场景还是编辑场景
@property (nonatomic, assign) BOOL needRefresh; //需要重新请求数据

@property (weak, nonatomic) IBOutlet UIButton *sortBtn;

@end
