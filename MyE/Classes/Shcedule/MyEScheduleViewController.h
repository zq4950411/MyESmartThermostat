//
//  MyEScheduleViewController.h
//  MyE
//
//  Created by Ye Yuan on 1/19/12.
//  Copyright (c) 2012 MyEnergy Domain. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MyEUtil.h"
@class MyETodayScheduleController;
@class MyEWeeklyScheduleSubviewController;
@class MyENext24HrsScheduleSubviewController;
@class MyETipViewController;

@interface MyEScheduleViewController : UIViewController {
    ScheduleType _currentPanelType;
    MyETipViewController *_tipViewControllerForTodayPanel;
    MyETipViewController *_tipViewControllerForWeeklyPanel;
    MyETipViewController *_tipViewControllerForNext24HrsPanel;
}
@property (nonatomic) ScheduleType currentPanelType;
@property (copy, nonatomic) NSString *userId;
@property (nonatomic) NSInteger houseId;
@property (nonatomic,copy) NSString *houseName;
@property (nonatomic) BOOL isRemoteControl;

@property (weak, nonatomic) IBOutlet UIView *baseView;
@property (weak, nonatomic) IBOutlet UISegmentedControl *todayWeeklySwitchButton;

//下面两个声明必须使用strong，而不是weak，如果使用了weak，在运行中，此todayBaseViewController对象就会被释放，在点击其上的Button调用其action函数时，就报告找不到消息接受对象
@property (strong, nonatomic) MyETodayScheduleController *todayBaseViewController;
@property (strong, nonatomic) MyEWeeklyScheduleSubviewController *weeklyBaseViewController;
@property (strong, nonatomic) MyENext24HrsScheduleSubviewController *next24HrsBaseViewController;

- (IBAction)switchSubPanel:(id)sender;
- (void)refreshAction;
@end
