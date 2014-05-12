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
#import "MyELaunchIntroViewController.h"

#import "MyEAccountData.h"
#import "MyEThermostatData.h"
#import "MyEHouseData.h"

@implementation MyEAppDelegate

@synthesize window = _window;
@synthesize accountData = _accountData;
@synthesize thermostatData = _thermostatData;
@synthesize houseData = _houseData;

-(BOOL) isRemember
{
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    return [prefs boolForKey:@"rememberme"];
}

-(void) setRemember:(BOOL) b
{
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    [prefs setBool:YES forKey:@"rememberme"];
}

-(void) setValue:(NSString *) v withKey:(NSString *) key
{
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    [prefs setObject:v forKey:key];
}

-(void) getLoginView
{
    UIStoryboard *storybord = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
    //        UIViewController *vc =[storybord instantiateInitialViewController];// 这个是默认的第一个viewController
    
    // 获取程序的主Navigation VC, 这里可以类似地从stroyboard获取任意的VC，然后设置它为rootViewController，这样就可以显示它
    UINavigationController *controller = (UINavigationController*)[storybord
                                                                   instantiateViewControllerWithIdentifier: @"MainNavViewController"];
    self.window.rootViewController = controller;// 用主Navigation VC作为程序的rootViewController
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    if (!IS_IOS6) {
        [[UINavigationBar appearance] setBackgroundImage:[UIImage imageNamed:@"barImage.png"]  forBarMetrics:UIBarMetricsDefault];   //这个貌似跟位置有关系，之前放在方法最后面竟然没有执行成功，放在这里才算成功了
        [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
        //这种给导航栏修改title颜色的方法简直太赞了，特别值得注意
        //首先获得这个dictionary，然后对相应的键值进行赋值，特别注意只有可变的dictionary才能进行赋值，然后把修改好的dic赋值给navbar
        NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:[UINavigationBar appearance].titleTextAttributes];
        [dic setValue:[UIColor whiteColor] forKey:UITextAttributeTextColor];
        [[UINavigationBar appearance] setTitleTextAttributes:dic];
        [[UIBarButtonItem appearance] setTintColor:[UIColor whiteColor]];
        [[UITabBar appearance] setBarStyle:UIBarStyleBlack];
        [[UITabBar appearance] setTintColor:[UIColor whiteColor]];
        [[UIToolbar appearance] setBarStyle:UIBarStyleBlack];
    }

    // Override point for customization after application launch.
    sleep(0.01);//让程序休眠n秒，以使Launch image多停留一会。
    
    
    /**
     说明与备忘：
        下面这一段的目的是为程序添加一个Startup Introduction ScrollView。
     当用户在第一次进入APP时，就沿着Storyboard里面确定的rootViewController顺序进行加载，
     并且在standardUserDefaults里面记载程序已经加载过了。
        在程序第二次加载时，就从storyBoard里面取得标示符为"MainNavViewController"的程序的主体VC，
     就用这个VC代替程序原来的self.window.rootViewController，这样程序就略过Startup Introduction ScrollView，
     而直接进入MainNavViewController.
     **/
    //*
    if ([[NSUserDefaults standardUserDefaults] boolForKey:KEY_FOR_APP_HAS_LAUNCHED_ONCE])
    {
        // app already launched
       
        UIStoryboard *storybord = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
//        UIViewController *vc =[storybord instantiateInitialViewController];// 这个是默认的第一个viewController
        
        // 获取程序的主Navigation VC, 这里可以类似地从stroyboard获取任意的VC，然后设置它为rootViewController，这样就可以显示它
        UIViewController *controller = (UIViewController*)[storybord
                                    instantiateViewControllerWithIdentifier: @"MainViewController"];
        self.window.rootViewController = controller;// 用主Navigation VC作为程序的rootViewController
        [self.window makeKeyAndVisible];
        return YES;
    }
    else
    {
        // This is the first launch ever
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:KEY_FOR_APP_HAS_LAUNCHED_ONCE];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
    }
    //*/
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
        } else {//有可能是view堆栈的最顶上vc不是MyEMainTabBarController，有可能是HouseListViewController
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
