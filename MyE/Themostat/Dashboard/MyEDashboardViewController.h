//
//  MyEDashboardViewController.h
//  MyE
//
//  Created by Ye Yuan on 1/19/12.
//  Copyright (c) 2012 MyEnergy Domain. All rights reserved.
//
#define ANIMATION_DURATION 0.80f
#define LOAD_DELAY 1.0f

#import <UIKit/UIKit.h>
#import "MyEDataLoader.h"
#import "MBProgressHUD.h"


#import "ACPButton.h"
#import "FUISwitch.h"
#import "CDCircle.h"

@class MyEAccountData;
@class MyEDashboardData;
@class MyEHouseData;
@class MyETipViewController;

// 定义转多少度算是一步
#define STEP_DEGREE 10

@interface MyEDashboardViewController : UIViewController
<MyEDataLoaderDelegate,MBProgressHUDDelegate,
CDCircleDelegate, CDCircleDataSource> {
    CALayer *_maskLayer;
    NSTimer *loadTimer;  // Timer used for uploading delay.


    MBProgressHUD *HUD;
    
    BOOL _isSetpointChanged;
}
@property (copy, nonatomic) NSString *userId;
@property (nonatomic) NSInteger houseId;
@property (nonatomic, copy) NSString *tId;
@property (nonatomic, copy) NSString *tName;// 当前选择的t的名字
@property (nonatomic,copy) NSString *houseName;
@property (nonatomic) BOOL isRemoteControl;


@property (strong, nonatomic) MyEDashboardData *dashboardData;

//下面两个属性用于更改在 UIPickerView 中的选定行的颜色时记录选中row和原来row
@property (weak, nonatomic) UILabel *oldLabelView;
@property (weak, nonatomic) UILabel *selectedLabelView;


@property (weak, nonatomic) IBOutlet ACPButton *controlModeBtn;
@property (weak, nonatomic) IBOutlet UIImageView *controlModeImageView;
@property (weak, nonatomic) IBOutlet UILabel *stageLevelLabel;
@property (weak, nonatomic) IBOutlet UIView *systemControlToolbar;
@property (weak, nonatomic) IBOutlet UIView *systemControlToolbarOverlayView;

@property (weak, nonatomic) IBOutlet ACPButton *fanStatusBtn;
@property (weak, nonatomic) IBOutlet UIImageView *fanImageView;
@property (weak, nonatomic) IBOutlet UILabel *fanStatusLabel;
@property (weak, nonatomic) IBOutlet UIView *fanControlToolbar;
@property (weak, nonatomic) IBOutlet UIView *fanControlToolbarOverlayView;


@property (weak, nonatomic) IBOutlet UILabel *holdRunLabel;



@property (weak, nonatomic) IBOutlet UILabel *indoorTemperatureLabel;





@property (strong, nonatomic) IBOutlet UITapGestureRecognizer *systemControlToolbarViewTapRecognizer;
@property (weak, nonatomic) IBOutlet UIButton *systemControlHeatingButton;
@property (weak, nonatomic) IBOutlet UIButton *systemControlCoolingButton;
@property (weak, nonatomic) IBOutlet UIButton *systemControlAutoButton;
@property (weak, nonatomic) IBOutlet UIButton *systemControlEmgHeatingButton;
@property (weak, nonatomic) IBOutlet UIButton *systemControlOffButton;


@property (strong, nonatomic) IBOutlet UITapGestureRecognizer *fanControlToolbarViewTapRecognizer;
@property (weak, nonatomic) IBOutlet UIButton *fanControlAutoButton;
@property (weak, nonatomic) IBOutlet UIButton *fanControlOnButton;



// 显示提示信息
- (void)showAlertWithMessage:(NSString *)message messageId:(NSString *)mid;

- (IBAction)changeControlMode:(id)sender;
- (IBAction)changeFanControl:(id)sender;
- (IBAction)changeControlModeToHeatingAction:(id)sender;
- (IBAction)changeControlModeToCoolingAction:(id)sender;
- (IBAction)changeControlModeToAutoAction:(id)sender;
- (IBAction)changeControlModeToEmgHeatingAction:(id)sender;
- (IBAction)changeControlModeToOffAction:(id)sender;
- (IBAction)changeFanControlToAuto:(id)sender;
- (IBAction)changeFanControlToOn:(id)sender;
- (IBAction)hideSystemControlToolbarView:(id)sender;
- (IBAction)hideFanControlToolbarView:(id)sender;


- (void)refreshAction;
- (void)downloadModelFromServer;
- (void)downloadModelFromServerLater;// 准备3秒后请求刷新新数据， 连续刷新3次
- (void)uploadModelToServer;

#pragma mark
#pragma CDCircleDelegate 属性
@property (nonatomic, assign) NSInteger selectedSegment;

@end
