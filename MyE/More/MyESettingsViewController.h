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
    
    
    
    // 下面变量纯粹用于要删除T前显示AlertView时，要把下一步具体删除修改动作的所需变量保存下来，等AlertView点击YES后才执行真正的删除修改
    NSString *_tIdToDelete;
    NSInteger _tIndexToDelete; // 记录下要删除的T在thermostats数组里面的序号
    
    NSInteger _deleteThermostatQueryNumber;// 删除T查询次数
    
    
    NSTimer *loadTimer;  // Timer used for query thermostat delay.
}
@property (copy, nonatomic) NSString *userId;
@property (copy, nonatomic) NSString *userName;
@property (nonatomic) NSInteger houseId;
@property (nonatomic,copy) NSString *houseName;
@property (nonatomic, copy) NSString *tId;// 表示当前选择的t的id
@property (nonatomic, copy) NSString *tName;// 当前选择的t的名字
//@property (nonatomic) BOOL isRemoteControl;

@property (retain, nonatomic) MyEHouseData *houseData;



@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;



@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UILabel *mediatorLabel;


- (IBAction)resetTipPopups:(id)sender;

- (void) downloadModelFromServer;
- (void)uploadModelToServerWithTId:(NSString *)tId keypad:(NSInteger)keypad;
- (void)uploadServerToDeleteThermostat:(NSString *)tId index:(NSInteger)index;
- (void)queryThermostatDeleteStatusFromServer:(NSTimer *)timer;

- (void) dimissAlert:(UIAlertView *)alert;
- (void)showAutoDisappearAlertWithTile:(NSString *)title message:(NSString *)message delay:(NSInteger)delay;
- (MyEHouseData *)getHouseFromJSONString:(NSString *)jsonString byHouseId:(NSInteger)theHouseId;
@end
