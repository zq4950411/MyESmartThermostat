//
//  MyENext24HrsScheduleViewController.h
//  MyE
//
//  Created by Ye Yuan on 5/11/14.
//  Copyright (c) 2014 MyEnergy Domain. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MyEDataLoader.h"
#import "MyEDoughnutView.h"
#import "MyEModePickerView.h"
#import "MBProgressHUD.h"
#import "MyEPeriodInforDoughnutView.h"
#import "MyETodayPeriodEditingView.h"
#import "MyETodayHoldEditingView.h"
#import "MyETodayPeriodInforView.h"


@class MyEScheduleModeData;
@class MyEScheduleNext24HrsData;

@interface MyENext24HrsScheduleViewController : UIViewController<
MyEDoughnutViewDelegate,
MyEDataLoaderDelegate,
MBProgressHUDDelegate,
MyEPeriodInforDoughnutViewDelegate,
MyETodayPeriodEditingViewDelegate,
MyETodayHoldEditingViewDelegate,
MyETodayPeriodInforViewDelegate,
MyEPeriodInforDoughnutViewDelegate> {
    UINavigationController *_navigationController;
    MyEDoughnutView *_doughnutView;
    
    MyEScheduleNext24HrsData *_next24hrsModel;
    NSMutableData *_receivedData;
    
    // 当前选择的时段的id。用于用户手触摸修改sector，或者编辑这个mode。
    // 这个值和MyEDoughnutView中的成员变量相同,为了和Weekly面板习惯一致，这里也用mode命名，
    // 其实一个mode对应一个period。
    NSInteger _currentSelectedModeId;
    
    MyETodayPeriodEditingView *_periodEditingView;
    BOOL _periodEditingViewShowing;
    
    MyETodayHoldEditingView *_holdEditingView;
    BOOL _holdEditingViewShowing;
    
    MyETodayPeriodInforView *_periodInforView;
    BOOL _periodInforViewShowing;
    
    // 当用户点击了一下Sector后，就toggle显示、隐藏Doughnut圆环形式的heating/cooling信息
    MyEPeriodInforDoughnutView *_periodInforDoughnutView;
    BOOL _periodInforDoughnutViewShowing;
    
    
    // 下面变量用于表示是不是当前Schedule被用户通过触摸改变了
    BOOL _scheduleChangedByUserTouch;
    
    
    MBProgressHUD *HUD;
    
}

@property (nonatomic) BOOL isRemoteControl;

@property (strong, nonatomic) MyEScheduleNext24HrsData *next24hrsModel;
@property (strong, nonatomic) MyEScheduleNext24HrsData *next24hrsModelCache;//缓冲数据，用于恢复用户修改Schedule操作的

@property (nonatomic) NSInteger currentSelectedModeId;
@property (nonatomic) NSInteger currentSelectedPeriodIndex;


@property (weak, nonatomic) IBOutlet UIView *centerContainerView;
@property (weak, nonatomic) IBOutlet UIButton *applyButton;
@property (weak, nonatomic) IBOutlet UIButton *resetButton;
@property (weak, nonatomic) IBOutlet UIButton *useWeeklyButton;


- (IBAction)applyNewSchedule:(id)sender;
- (IBAction)resetSchedule:(id)sender;
- (IBAction)useWeekly:(id)sender;

- (void) downloadModelFromServer;
- (void) downloadWeeklyModelFromServer;
- (void) uploadModelToServer;
- (void) uploadHoldModelToServerWithSetpoint:(NSInteger)setpoint hold:(NSInteger)hold;

@end
