//
//  MyEEventDetailViewController.h
//  MyE
//
//  Created by 翟强 on 14-5-24.
//  Copyright (c) 2014年 MyEnergy Domain. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MyEEventAddOrEditViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,MyEDataLoaderDelegate>

@property (nonatomic, strong) MyEEventInfo *eventInfo;
@property (nonatomic, strong) MyEEventDetail *eventDetail;
@property (nonatomic, assign) BOOL isAdd;  //表示现在是新增场景还是编辑场景

@property (weak, nonatomic) IBOutlet UITableView *conditionTable;
@property (weak, nonatomic) IBOutlet UITableView *deviceTable;
@property (weak, nonatomic) IBOutlet UIView *topView;

@end
