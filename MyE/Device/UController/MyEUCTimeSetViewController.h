//
//  MyEUCTimeSetViewController.h
//  MyE
//
//  Created by 翟强 on 14-6-9.
//  Copyright (c) 2014年 MyEnergy Domain. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MyEUCInfo.h"

@interface MyEUCTimeSetViewController : UIViewController
@property (weak, nonatomic) MyEUCSequential *sequential;
@property (weak, nonatomic) IBOutlet UIDatePicker *datePicker;

@end
