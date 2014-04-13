//
//  MyESwitchAutoViewController.h
//  MyEHomeCN2
//
//  Created by 翟强 on 14-3-6.
//  Copyright (c) 2014年 My Energy Domain Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MyESwitchScheduleViewController.h"
#import "MyESwitchScheduleSettingViewController.h"
@interface MyESwitchAutoViewController : UIViewController<MyEDataLoaderDelegate>{
    MBProgressHUD *HUD;
}
@property(strong, nonatomic) SmartUp *device;
@property(strong, nonatomic) MyESwitchAutoControl *control;
@property (weak, nonatomic) IBOutlet UISegmentedControl *enableSeg;
@property(nonatomic) BOOL jumpFromSubView;
@property(nonatomic) BOOL needRefresh;
@end
