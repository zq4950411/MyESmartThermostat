//
//  MyEDashboardViewController.h
//  MyE
//
//  Created by Ye Yuan on 1/19/12.
//  Copyright (c) 2012 MyEnergy Domain. All rights reserved.
//
#define ANIMATION_DURATION 0.80f
#define LOAD_DELAY 2.0f

#import <UIKit/UIKit.h>
#import "MyEDataLoader.h"
#import "MBProgressHUD.h"
@class MyEAccountData;
@class MyEDashboardData;
@class MyEHouseData;
@class MyETipViewController;

@interface MyEDashboardViewController : UIViewController <MyEDataLoaderDelegate,UIPickerViewDelegate,UIPickerViewDataSource,MBProgressHUDDelegate> {
    CALayer *_maskLayer;
    NSTimer *loadTimer;  // Timer used for uploading delay.

    MBProgressHUD *HUD;
    MyETipViewController *_tipViewController;
    
    BOOL _isSetpointChanged;
    
    BOOL _isSystemControlToolbarViewShowing;
    BOOL _isFanControlToolbarViewShowing;
}
@property (copy, nonatomic) NSString *userId;
@property (nonatomic) NSInteger houseId;
@property (nonatomic, copy) NSString *tId;
@property (nonatomic,copy) NSString *houseName;
@property (nonatomic) BOOL isRemoteControl;


@property (strong, nonatomic) MyEDashboardData *dashboardData;

//下面两个属性用于更改在 UIPickerView 中的选定行的颜色时记录选中row和原来row
@property (weak, nonatomic) UILabel *oldLabelView;
@property (weak, nonatomic) UILabel *selectedLabelView;




@property (weak, nonatomic) IBOutlet UIImageView *weatherImageView;
@property (weak, nonatomic) IBOutlet UILabel *weatherTemperatureLabel;
@property (weak, nonatomic) IBOutlet UILabel *weatherTemperatureRangeLabel;
@property (weak, nonatomic) IBOutlet UILabel *humidityLabel;
@property (weak, nonatomic) IBOutlet UILabel *indoorTemperatureLabel;
@property (weak, nonatomic) IBOutlet UIImageView *controlModeImageView;
@property (weak, nonatomic) IBOutlet UIImageView *fanImageView;
@property (weak, nonatomic) IBOutlet UILabel *activeProgramLabel;
@property (weak, nonatomic) IBOutlet UILabel *stageLevelLabel;
@property (weak, nonatomic) IBOutlet UIView *systemControlToolbarView;
@property (weak, nonatomic) IBOutlet UIView *fanControlToolbarView;
@property (weak, nonatomic) IBOutlet UIPickerView *setpointPickerView;
@property (weak, nonatomic) IBOutlet UIButton *holdButton;




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
- (IBAction)holdAction:(id)sender;

- (void)refreshAction;
- (void)downloadModelFromServer;
- (void)uploadModelToServer;

@end
