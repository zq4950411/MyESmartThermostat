//
//  MyESocketManualViewController.h
//  MyE
//
//  Created by 翟强 on 14-4-24.
//  Copyright (c) 2014年 MyEnergy Domain. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MyESocketAutoViewController.h"
#import "MyESocketUsageViewController.h"

@interface MyESocketManualViewController : UIViewController<MyEDataLoaderDelegate,IQActionSheetPickerView,UIAlertViewDelegate>
@property(nonatomic, strong) MyEDevice *device;
@property(nonatomic, strong) MyESocketInfo *socketInfo;
@property (weak, nonatomic) IBOutlet UILabel *currentPowerLabel;
@property (weak, nonatomic) IBOutlet UIButton *socketControlBtn;
@property (weak, nonatomic) IBOutlet UIButton *timeDelayBtn;
@property (weak, nonatomic) IBOutlet UILabel *timeDelayLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeDelaySetLabel;

@end
