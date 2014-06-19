//
//  MyEAppDelegate.h
//  MyE
//
//  Created by Ye Yuan on 1/19/12.
//  Copyright (c) 2012 MyEnergy Domain. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "APService.h"
@class MyEAccountData;
@class MyETerminalData;
@class MyEHouseData;


@interface MyEAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) NSString *deviceTokenStr,*alias; //这个是为消息推送准备的数据
@property (strong, nonatomic) MyEAccountData *accountData;

// 在进入Thermostat面板时, 会记录下当前选择的房子的Thermostat, 一个Thermostat就是一个Termial
@property (strong, nonatomic) MyETerminalData *terminalData;

// 从House list 面板选择一个house, 在这里就记录下该house数据
@property (strong, nonatomic) MyEHouseData *houseData;

-(void) getLoginView;
-(BOOL) isRemember;
-(void) setRemember:(BOOL) b;

-(void) setValue:(NSString *) v withKey:(NSString *) key;

@end
