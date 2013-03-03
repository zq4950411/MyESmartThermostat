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
@property (copy, nonatomic) NSString *userId;
@property (nonatomic) NSInteger houseId;
@property (nonatomic,copy) NSString *houseName;
@property (nonatomic) NSInteger selectedTabIndex;
@property (nonatomic, weak) id <SelectedTabBar> selectedTabIndexDelegate;

- (void)navigationBarDoubleTap:(UIGestureRecognizer*)recognizer;
- (void)switchTerminal;// 用于测试切换红外转发器

@end
