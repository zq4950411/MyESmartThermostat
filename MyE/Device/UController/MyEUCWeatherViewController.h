//
//  MyEUCWeatherViewController.h
//  MyE
//
//  Created by 翟强 on 14-6-9.
//  Copyright (c) 2014年 MyEnergy Domain. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MyEUCInfo.h"
#import "MYEPickerView.h"
@interface MyEUCWeatherViewController : UITableViewController<MYEPickerViewDelegate>
@property (weak, nonatomic) MyEUCSequential *sequential;
@end
