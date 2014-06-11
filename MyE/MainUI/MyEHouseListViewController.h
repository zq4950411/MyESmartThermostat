//
//  MyEHouseListViewController.h
//  MyE
//
//  Created by Ye Yuan on 1/29/12.
//  Copyright (c) 2012 MyEnergy Domain. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "MyEDataLoader.h"
#import "MBProgressHUD.h"
#import "ACPButton.h"

@class MyEAccountData;

@interface MyEHouseListViewController : UITableViewController <MyEDataLoaderDelegate,MBProgressHUDDelegate,EGORefreshTableHeaderDelegate>
{
     MBProgressHUD *HUD;
    
    BOOL _hasLoadedDefaultHouseId;//如果还没取得过系统偏好里面的默认houseId时，此变量取NO，否则取YES
    NSInteger _defaultHouseId;// 保存在系统偏好里面的用户默认的houseId，如果设置了，就在登录后略过Houselist view，直接用这个houseId进入Dashboard view
    
    EGORefreshTableHeaderView *_refreshHeaderView;
    BOOL _isRefreshing;
}
@property (nonatomic) NSInteger selectedTabIndex; // 这个原来是为SelectedTabBar protocol所定义的，定义在m文件的前面的SelectedTabBar协议变量部分，但为了保证在ThermostatListViewController里面程序转移到新的tab后也能记住所进入的tab，就把此变量定义到这里，以便其他地方也可以访问。
@property (nonatomic, retain) MyEAccountData *accountData;
@property (weak, nonatomic) IBOutlet UIButton *rememberHouseIdBtn;
@property (weak, nonatomic) IBOutlet ACPButton *registerButton;
@property (nonatomic, assign) BOOL needRefresh;

// 加载持久存储的设置
-(void)loadSettings;
-(void)saveSettings:(NSInteger)defaultHouseId;

- (void)refreshAction;
- (void)downloadModelFromServer;

- (void) dimissAlert:(UIAlertView *)alert;
- (void)showAutoDisappearAlertWithTile:(NSString *)title message:(NSString *)message delay:(NSInteger)delay;

@end
