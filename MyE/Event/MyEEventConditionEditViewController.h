//
//  MyEEventConditionEditViewController.h
//  MyE
//
//  Created by 翟强 on 14-5-14.
//  Copyright (c) 2014年 MyEnergy Domain. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MyETerminalData.h"
#import "MYEPickerView.h"
#import "MBProgressHUD.h"
@interface MyEEventConditionEditViewController : UIViewController<MYEPickerViewDelegate,MyEDataLoaderDelegate>

@property (nonatomic, weak) MyEEventInfo *eventInfo;
@property (nonatomic, weak) MyEEventDetail *eventDetail;
@property (nonatomic, strong) MyEEventConditionCustom *conditionCustom;
@property (nonatomic, assign) BOOL isAdd;

@property (weak, nonatomic) IBOutlet UIView *indoorView;
@property (weak, nonatomic) IBOutlet UIView *outdoorView;

@property (weak, nonatomic) IBOutlet UIButton *conditionBtn;
@property (weak, nonatomic) IBOutlet UIButton *terminalBtn;
@property (weak, nonatomic) IBOutlet UIButton *relationBtn;
@property (weak, nonatomic) IBOutlet UIButton *relationBtn1;

@property (weak, nonatomic) IBOutlet UIButton *valueBtn;
@property (weak, nonatomic) IBOutlet UIButton *valueBtn1;
@end
