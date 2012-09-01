//
//  MyEAppDelegate.m
//  MyE
//
//  Created by Ye Yuan on 1/19/12.
//  Copyright (c) 2012 MyEnergy Domain. All rights reserved.
//

#import "MyEAppDelegate.h"
#import "MyEHouseListViewController.h"
#import "MyEMainTabBarController.h"
#import "MyEDashboardViewController.h"
#import "MyEScheduleViewController.h"
#import "MyETodayScheduleController.h"
#import "MyEWeeklyScheduleSubviewController.h"
#import "MyENext24HrsScheduleSubviewController.h"
#import "MyEVacationMasterViewController.h"
#import "MyESettingsViewController.h"

@implementation MyEAppDelegate

@synthesize window = _window;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    sleep(2);//让程序休眠两秒，以使Launch image多停留一会。
    
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
    NSLog(@"------------=============applicationWillResignActive");
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
    // 防御性编程，如果程序正常转到后台或由用户退出，就把exitcode设置为1
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    [prefs setInteger:1  forKey:@"exitcode"]; 
    [prefs synchronize];
    NSLog(@"------------=============applicationDidEnterBackground, exitcode = 1");
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
    NSLog(@"------------=============applicationWillEnterForeground");
    
    UINavigationController *nc = (UINavigationController *)self.window.rootViewController;
    NSArray *subVS = [nc viewControllers];
    if([subVS count] == 1){// 在HouseListView模块时，view堆栈的数目是1
        id vc = [subVS objectAtIndex:0];
        
        // view堆栈的数目是1时，还有可能是在MyELoginViewController面板，所以这里必须保证此vc却是是MyEHouseListViewController
        if ([vc isKindOfClass:[MyEHouseListViewController class]]) {
            MyEHouseListViewController * hlvc= vc;
            [hlvc downloadModelFromServer];
        }
        
    }
    else if([subVS count] == 2){// 在进入TabBarController的任何一个直接子view时，view堆栈的数目是2
        id vc= [subVS objectAtIndex:1];
        if ([vc isKindOfClass:[MyEMainTabBarController class]]) {
            MyEMainTabBarController * mtbc = vc;
            id selectedVC = [mtbc selectedViewController];
            
            if([selectedVC isKindOfClass:[MyEDashboardViewController class]]){
                [(MyEDashboardViewController *)selectedVC downloadModelFromServer];
            }
            if([selectedVC isKindOfClass:[MyEScheduleViewController class]]){
                MyEScheduleViewController *svc = (MyEScheduleViewController *)selectedVC;
                if (svc.currentPanelType == SCHEDULE_TYPE_TODAY && svc.todayBaseViewController != nil)
                    [svc.todayBaseViewController downloadModelFromServer];
                else if (svc.currentPanelType == SCHEDULE_TYPE_WEEKLY && svc.weeklyBaseViewController != nil)
                    [svc.weeklyBaseViewController downloadModelFromServer];
                else if (svc.currentPanelType == SCHEDULE_TYPE_NEXT24HRS && svc.next24HrsBaseViewController != nil)
                    [svc.next24HrsBaseViewController downloadModelFromServer];
            }
            if([selectedVC isKindOfClass:[MyEVacationMasterViewController class]]){
                [(MyEVacationMasterViewController *)selectedVC downloadModelFromServer];
            }
            if([selectedVC isKindOfClass:[MyESettingsViewController class]]){
                [(MyESettingsViewController *)selectedVC downloadModelFromServer];
            }
        } else {//有可能是view堆栈的最顶上vc不是MyEMainTabBarController，
            // 这种情况不应该发生，但有可能是程序设计时没有想到而导致的未处理的情况。所以这里进行调试检查一下。
            NSLog(@"This message indicates that the top vc in vc stack is no the  MyEMainTabBarController");
        }
        
    }else if([subVS count] > 2){// 在vacation模块的添加、修改vacation时，view堆栈的数目是3或4
        NSLog(@"view堆栈的数目是 %i", [subVS count]);
    }
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
    NSLog(@"----------===================applicationDidBecomeActive, exitcode = -1");
    
    //想显示记录下来的被迫退出的原因，仅用于调试
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    
    // exitcode < 1表示上次程序正常转到后台，直至退出。如果程序是异常crash，就没有机会把exitcode设置为1
    BOOL exitcode = [prefs boolForKey:@"exitcode"];
    
    if (exitcode != 1) {
        // 表示程序上一次退出时是在前台异常crash，没有机会把appInActiveSinceLastExit变量设置为1
        // 这里就把所有上次保存的东西删除，使得程序像初始化一样运行
        
        [prefs removeObjectForKey:@"username"]; 
        [prefs removeObjectForKey:@"password"];
        [prefs removeObjectForKey:@"rememberme"];
        [prefs removeObjectForKey:KEY_FOR_HOUSE_ID_LAST_VIEWED];
        [prefs removeObjectForKey:@"defaulthouseid"];
        [prefs removeObjectForKey:KEY_FOR_HIDE_TIP_OF_DASHBOARD1];
        [prefs removeObjectForKey:KEY_FOR_HIDE_TIP_OF_DASHBOARD2];
        [prefs removeObjectForKey:KEY_FOR_HIDE_TIP_OF_SCHEDULE_TODAY1];
        [prefs removeObjectForKey:KEY_FOR_HIDE_TIP_OF_SCHEDULE_TODAY2];
        [prefs removeObjectForKey:KEY_FOR_HIDE_TIP_OF_SCHEDULE_NEXT24HRS1];
        [prefs removeObjectForKey:KEY_FOR_HIDE_TIP_OF_SCHEDULE_NEXT24HRS2];
        [prefs removeObjectForKey:KEY_FOR_HIDE_TIP_OF_SCHEDULE_WEEKLY];
        [prefs removeObjectForKey:KEY_FOR_HIDE_TIP_OF_VACATION];
        [prefs removeObjectForKey:KEY_FOR_HIDE_TIP_OF_SETTINGS];
    }
    [prefs setInteger:-1 forKey:@"exitcode"]; //设置exitcode为-1，如果程序异常crash，此exitcode就没有机会设置为1
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
    // 防御性编程，如果程序正常转到后台或由用户退出，就把exitcode设置为1
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    [prefs setInteger:1  forKey:@"exitcode"]; 
    [prefs synchronize];
    NSLog(@"------------=============applicationWillTerminate");
}

@end
