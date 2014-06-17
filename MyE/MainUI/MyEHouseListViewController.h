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
    NSInteger _defaultHouseId;// 保存在系统偏好里面的用户默认的houseId，如果设置了，就在登录后略过Houselist view，直接用这个houseId进入Dashboard view
    
    EGORefreshTableHeaderView *_refreshHeaderView;
    BOOL _isRefreshing;
}
@property (weak, nonatomic) IBOutlet UIBarButtonItem *sidebarButton;
@property (weak, nonatomic) IBOutlet ACPButton *registerButton;

- (void)refreshAction;
- (void)downloadModelFromServer;

- (void) dimissAlert:(UIAlertView *)alert;
- (void)showAutoDisappearAlertWithTile:(NSString *)title message:(NSString *)message delay:(NSInteger)delay;

@end
