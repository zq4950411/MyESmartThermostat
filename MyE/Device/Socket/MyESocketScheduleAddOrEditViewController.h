//
//  MyESocketScheduleAddOrEditViewController.h
//  MyE
//
//  Created by 翟强 on 14-5-21.
//  Copyright (c) 2014年 MyEnergy Domain. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MYEPickerView.h"

@interface MyESocketScheduleAddOrEditViewController : UIViewController<MYEWeekButtonsDelegate,MyEDataLoaderDelegate,MYEPickerViewDelegate>

@property (nonatomic, strong) MyEDevice *device;
@property (nonatomic, strong) MyESocketSchedules *schedules;
@property (nonatomic, strong) MyESocketSchedule *schedule;
@property (nonatomic, assign) BOOL isAdd; //YES表示新增进程，NO表示修改进程

@property (weak, nonatomic) IBOutlet MYEWeekButtons *weekBtns;
@property (weak, nonatomic) IBOutlet UIButton *startTimeBtn;
@property (weak, nonatomic) IBOutlet UIButton *endTimeBtn;

@end
