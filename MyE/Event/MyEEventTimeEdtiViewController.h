//
//  MyEEventTimeEdtiViewController.h
//  MyE
//
//  Created by 翟强 on 14-5-14.
//  Copyright (c) 2014年 MyEnergy Domain. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MyEEventTimeEdtiViewController : UIViewController<MYEWeekButtonsDelegate>

@property (nonatomic, strong) MyEEventConditionTime *conditionTime;

@property (weak, nonatomic) IBOutlet UIDatePicker *datePicker;
@property (weak, nonatomic) IBOutlet MYEWeekButtons *weekBtns;

@end
