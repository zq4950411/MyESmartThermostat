//
//  MyESocketManualViewController.h
//  MyE
//
//  Created by 翟强 on 14-4-24.
//  Copyright (c) 2014年 MyEnergy Domain. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MyESocketAutoViewController.h"
#import "MYEPickerView.h"
@interface MyESocketManualViewController : UIViewController<MyEDataLoaderDelegate,UIAlertViewDelegate,MYEPickerViewDelegate>
@property(nonatomic, strong) MyEDevice *device;
@property(nonatomic, strong) MyESocketControlInfo *socketControlInfo;

@property (weak, nonatomic) IBOutlet UILabel *currentPowerLabel;
@property (weak, nonatomic) IBOutlet UIButton *socketControlBtn;
@property (weak, nonatomic) IBOutlet UIButton *timeDelayBtn;
@property (weak, nonatomic) IBOutlet UILabel *timeDelayLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeDelaySetLabel;
@property (nonatomic) BOOL needRefresh;

@end
