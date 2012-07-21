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
@class MyEAccountData;

@interface MyEHouseListViewController : UITableViewController <MyEDataLoaderDelegate,MBProgressHUDDelegate>{
     MBProgressHUD *HUD;
    
    BOOL _hasLoadedDefaultHouseId;//如果还没取得过系统偏好里面的默认houseId时，此变量取NO，否则取YES
    NSInteger _defaultHouseId;// 保存在系统偏好里面的用户默认的houseId，如果设置了，就在登录后略过Houselist view，直接用这个houseId进入Dashboard view
}
@property (nonatomic, retain) MyEAccountData *accountData;
@property (weak, nonatomic) IBOutlet UISwitch *rememberHouseIdSwitch;

// 加载持久存储的一下设置
-(void)loadSettings;
-(void)saveSettings:(NSInteger)defaultHouseId;

- (void)refreshAction;
- (void)downloadModelFromServer;

- (void) dimissAlert:(UIAlertView *)alert;
- (void)showAutoDisappearAlertWithTile:(NSString *)title message:(NSString *)message delay:(NSInteger)delay;

@end
