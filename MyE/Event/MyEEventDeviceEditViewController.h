//
//  MyEEventDeviceEditViewController.h
//  MyE
//
//  Created by 翟强 on 14-5-14.
//  Copyright (c) 2014年 MyEnergy Domain. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MyEDataLoader.h"
#import "MyEEventInfo.h"
#import "MyEUtil.h"
#import "MyEHouseData.h"
#import "MYEPickerView.h"
#import "MBProgressHUD.h"
@interface MyEEventDeviceEditViewController : UIViewController<MyEDataLoaderDelegate,MYEPickerViewDelegate,UITableViewDataSource,UITableViewDelegate>

@property (nonatomic, strong) MyEEventInfo *eventInfo;
@property (nonatomic, strong) MyEEventDetail *eventDetail;
@property (nonatomic, strong) MyEEventDevice *device;
@property (nonatomic, assign) BOOL isAdd;

@property (weak, nonatomic) IBOutlet UIButton *typeBtn;
@property (weak, nonatomic) IBOutlet UIButton *deviceBtn;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *btns;
@property (weak, nonatomic) IBOutlet UIView *setpointView;
@property (weak, nonatomic) IBOutlet UILabel *fanLbl;
@property (weak, nonatomic) IBOutlet UIButton *fanBtn;


@end
