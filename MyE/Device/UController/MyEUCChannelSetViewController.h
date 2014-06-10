//
//  MyEUCChannelSetViewController.h
//  MyE
//
//  Created by 翟强 on 14-6-9.
//  Copyright (c) 2014年 MyEnergy Domain. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MyEUCInfo.h"
#import "MYEPickerView.h"
@interface MyEUCChannelSetViewController : UIViewController<MYEPickerViewDelegate>
@property (weak, nonatomic) MyEUCSequential *sequential;
@property (strong, nonatomic) MyEUCChannelInfo *channelInfo;
@property (assign, nonatomic) BOOL isAdd;
@property (weak, nonatomic) IBOutlet UIButton *channelBtn;
@property (weak, nonatomic) IBOutlet UITextField *durationTxt;

@end
