//aaaaaa
//  MyENext24HrsScheduleSubviewController.h
//  MyE
//
//  Created by Ye Yuan on 7/10/12.
//  Copyright (c) 2012 MyEnergy Domain. All rights reserved.
//
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "MyESubviewController.h"
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
@class MyEScheduleViewController;


@interface MyENext24HrsScheduleSubviewController : MyESubviewController <
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
// 用于保持一个到根NavigationController对象的引用
@property (strong, nonatomic) UINavigationController *navigationController;
// 用于保持一个对最底层容器的引用
@property (strong, nonatomic) MyEScheduleViewController *delegate;

@property (copy, nonatomic) NSString *userId;
@property (nonatomic) NSInteger houseId;
@property (nonatomic, copy) NSString *tId;
@property (nonatomic, copy) NSString *tName;// 当前选择的t的名字
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


- (void) viewDidUnload;
- (void) downloadModelFromServer;
- (void) downloadWeeklyModelFromServer;
- (void) uploadModelToServer;
- (void) uploadHoldModelToServerWithSetpoint:(NSInteger)setpoint hold:(NSInteger)hold;
@end