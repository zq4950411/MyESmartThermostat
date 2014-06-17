//
//  MyEMediatorRegisterViewController.h
//  MyE
//
//  Created by 翟强 on 14-6-11.
//  Copyright (c) 2014年 MyEnergy Domain. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MyEAccountData.h"
#import "ACPButton.h"
#import "MyEQRScanViewController.h"
#import "WTReTextField.h"
#import "MyESettingsInfo.h"
#import "MBProgressHUD.h"
@interface MyEMediatorRegisterViewController : UITableViewController<MyEDataLoaderDelegate,MyEQRScanViewControllerDelegate>
@property (nonatomic, weak) MyEAccountData *accountData;
@property (nonatomic, assign) NSInteger timeZone;   //这里把这些值写成属性的形式，是为了在nav中更好的传值
@property (nonatomic, assign) NSInteger selectHouseIndex;
@property (nonatomic, assign) BOOL jumpFromNav;
@property (weak, nonatomic) IBOutlet WTReTextField *midTxt;
@property (weak, nonatomic) IBOutlet UITextField *pinTxt;
@property (weak, nonatomic) IBOutlet ACPButton *scanBtn;
@property (weak, nonatomic) IBOutlet ACPButton *regestBtn;

@end
