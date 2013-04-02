//
//  MyEMainTabBarController.h
//  MyE
//
//  Created by Ye Yuan on 2/3/12.
//  Copyright (c) 2012 MyEnergy Domain. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SelectedTabBar.h"

//定义用于TabBar View上每个UITabBarItem的Tag标签序号
typedef enum {
    MYE_TAB_DASHBOARD,
    MYE_TAB_SHCHEDULE,
    MYE_TAB_VACATION,
    MYE_TAB_SETTING
} MyETabBarItemType;

@interface MyEMainTabBarController : UITabBarController
@property (copy, nonatomic) NSString *userId;// 当前选用户
@property (nonatomic) NSInteger houseId;// 当前选择的房子id
@property (nonatomic,copy) NSString *houseName;// 当前选择的房子名称
@property (nonatomic, copy) NSString *tId;// 当前选择的T的id
@property (nonatomic, copy) NSString *tName;// 当前选择的t的名字
@property (nonatomic) NSInteger selectedTabIndex;
@property (nonatomic, weak) id <SelectedTabBar> selectedTabIndexDelegate;
@property (nonatomic) NSInteger tCount; // Thermostat 的数目.

- (void)navigationBarDoubleTap:(UIGestureRecognizer*)recognizer;

@end
