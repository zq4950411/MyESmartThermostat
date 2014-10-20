//
//  MyESwitchScheduleSettingViewController.h
//  MyEHomeCN2
//
//  Created by 翟强 on 14-3-6.
//  Copyright (c) 2014年 My Energy Domain Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MyESwitchManualControlViewController.h"
#import "MBProgressHUD.h"
#import "MyESwitchAutoControl.h"
#import "MYETimePicker.h"
@interface MyESwitchScheduleSettingViewController : UIViewController<MYETimePickerDelegate,MyEDataLoaderDelegate,MYEWeekButtonsDelegate,UIAlertViewDelegate>{
    NSArray *_headTimeArray;
    NSArray *_tailTimeArray;
    MBProgressHUD *HUD;
    MyESwitchSchedule *_scheduleNew;
    NSArray *_initArray;  //初始化array，用于表示编辑时刚进入此面板时的内容
}

@property (weak, nonatomic) MyEDevice *device;
@property (strong, nonatomic) MyESwitchSchedule *schedule;
@property (strong, nonatomic) MyESwitchAutoControl *control;
@property (nonatomic) NSInteger actionType;  //1表示新增，2表示编辑
@property (weak, nonatomic) IBOutlet UIButton *startBtn;
@property (weak, nonatomic) IBOutlet UIButton *endBtn;
//@property (weak, nonatomic) IBOutlet MultiSelectSegmentedControl *channelSeg;
//@property (weak, nonatomic) IBOutlet MultiSelectSegmentedControl *weekSeg;
@property (weak, nonatomic) IBOutlet MYEWeekButtons *lights;
@property (weak, nonatomic) IBOutlet MYEWeekButtons *weeks;

@end
