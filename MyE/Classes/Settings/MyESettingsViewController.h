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
#import "MyESettingsThermostatCell.h"
@class MyEHouseData;
@class UICustomSwitch;
@class MyEHouseData;
@class MyETipViewController;

@interface MyESettingsViewController : UITableViewController <MyEDataLoaderDelegate, MBProgressHUDDelegate, MyESettingsThermostatCellDelegate>{
    CALayer *_maskLayer;
    
    MBProgressHUD *HUD;
     MyETipViewController *_tipViewController;
}
@property (copy, nonatomic) NSString *userId;
@property (copy, nonatomic) NSString *userName;
@property (nonatomic) NSInteger houseId;
@property (nonatomic,copy) NSString *houseName;
@property (nonatomic, copy) NSString *tId;// 表示当前选择的t
//@property (nonatomic) BOOL isRemoteControl;

@property (retain, nonatomic) MyEHouseData *houseData;



@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;



@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UITableViewCell *keypadCell;
@property (weak, nonatomic) IBOutlet UILabel *mediatorLabel;


- (IBAction)resetTipPopups:(id)sender;

- (void) downloadModelFromServer;

- (void)uploadModelToServerWithKeypad:(NSInteger)keypad;

- (void) dimissAlert:(UIAlertView *)alert;
- (void)showAutoDisappearAlertWithTile:(NSString *)title message:(NSString *)message delay:(NSInteger)delay;

@end
