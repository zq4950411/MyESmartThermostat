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
    
    //想显示记录下来的被迫退出的原因，仅用于调试
//    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
//    
//    NSInteger exitcode = [prefs integerForKey:@"exitcode"];
//    
//    if (exitcode < 0) {
//        NSLog(@"exit by applicationWillTerminate, abnormally.");
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Warning" 
//                                                        message:@"App exit with exit code of -1 last time."
//                                                       delegate:self 
//                                              cancelButtonTitle:@"Close" 
//                                              otherButtonTitles: nil];   
//        [alert show];
//        [prefs setInteger:0  forKey:@"exitcode"]; //恢复此exitcode为0的状态
//    }
    
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */

}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
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
        NSLog(@"%i", [subVS count]);
    }
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
    NSLog(@"----------applicationDidBecomeActive");

}

- (void)applicationWillTerminate:(UIApplication *)application
{
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
    //想记录下来被迫退出的原因，仅用于调试
//    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
//
//    [prefs setInteger:-1  forKey:@"exitcode"]; 
//
//    [prefs synchronize];
}

@end
