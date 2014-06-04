//
//  MyEEventDetailViewController.h
//  MyE
//
//  Created by 翟强 on 14-5-24.
//  Copyright (c) 2014年 MyEnergy Domain. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MyEDataLoader.h"
#import "MyEEventInfo.h"
#import "MyEUtil.h"
#import "MBProgressHUD.h"
#import "SVProgressHUD.h"
#import "DXAlertView.h"
@interface MyEEventAddOrEditViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,MyEDataLoaderDelegate,UIAlertViewDelegate>{
}

@property (nonatomic, strong) MyEEventInfo *eventInfo;
@property (nonatomic, strong) MyEEventDetail *eventDetail;
@property (nonatomic, assign) BOOL isAdd;  //表示现在是新增场景还是编辑场景

@property (weak, nonatomic) IBOutlet UITableView *conditionTable;
@property (weak, nonatomic) IBOutlet UITableView *deviceTable;
@property (weak, nonatomic) IBOutlet UIView *topView;
@property (weak, nonatomic) IBOutlet UIButton *sortBtn;
@property (weak, nonatomic) IBOutlet UIButton *addBtn;
@property (weak, nonatomic) IBOutlet UIButton *topBtn;

@end
