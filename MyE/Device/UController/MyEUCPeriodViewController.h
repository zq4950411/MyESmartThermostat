//
//  MyEUCPeriodViewController.h
//  MyE
//
//  Created by 翟强 on 14-6-7.
//  Copyright (c) 2014年 MyEnergy Domain. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MYEPickerView.h"
#import "MyEUCInfo.h"
@interface MyEUCPeriodViewController : UIViewController<MYEPickerViewDelegate>
@property (weak, nonatomic) IBOutlet UIButton *startTimeBtn;
@property (weak, nonatomic) IBOutlet UIButton *endTimeBtn;
@property (strong, nonatomic) MyEUCPeriod *period;
@property (weak, nonatomic) MyEUCSchedule *schedule;
@property (assign, nonatomic) BOOL isAdd;
@end
