//
//  MyESettingsViewController.h
//  MyE
//
//  Created by Ye Yuan on 3/28/12.
//  Copyright (c) 2012 MyEnergy Domain. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"
#import "MyEDataLoader.h"
@class MyESettingsData;
@class UICustomSwitch;
@class MyEDashboardData;
@class MyETipViewController;

@interface MyESettingsViewController : UITableViewController <MyEDataLoaderDelegate, MBProgressHUDDelegate>{
    CALayer *_maskLayer;
    
    MBProgressHUD *HUD;
     MyETipViewController *_tipViewController;
}
@property (copy, nonatomic) NSString *userId;
@property (nonatomic) NSInteger houseId;
@property (nonatomic,copy) NSString *houseName;
@property (nonatomic) BOOL isRemoteControl;

@property (retain, nonatomic) MyESettingsData *settingsData;
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UISwitch *keypadLockSwitch;


@property (weak, nonatomic) IBOutlet UITableViewCell *keypadCell;
@property (weak, nonatomic) IBOutlet UILabel *mediatorLabel;
@property (weak, nonatomic) IBOutlet UILabel *thermostatLabel;

- (IBAction)changeKaypadLock:(id)sender;
- (IBAction)resetTipPopups:(id)sender;

- (void) downloadModelFromServer;

- (void)uploadModelToServerWithKeypad:(NSInteger)keypad;

- (void) dimissAlert:(UIAlertView *)alert;
- (void)showAutoDisappearAlertWithTile:(NSString *)title message:(NSString *)message delay:(NSInteger)delay;

@end
