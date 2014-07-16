//
//  MyELoginViewController.h
//  MyE
//
//  Created by Ye Yuan on 1/19/12.
//  Copyright (c) 2012 MyEnergy Domain. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MyEDataLoader.h"
#import "MBProgressHUD.h"
#import "MyEQRScanViewController.h"
#import "TableViewWithBlock.h"
@class MyEAccountData;

@interface MyELoginViewController : UIViewController <UITextFieldDelegate, MyEDataLoaderDelegate, MBProgressHUDDelegate, UIAlertViewDelegate,MyEQRScanViewControllerDelegate> {
    UIView *opaqueview;
    
    MBProgressHUD *HUD;
}

@property (nonatomic, retain) MyEAccountData *accountData;
@property (weak, nonatomic) IBOutlet UIView *bgView;
@property (weak, nonatomic) IBOutlet TableViewWithBlock *usersTableView;
@property (weak, nonatomic) IBOutlet UIButton *showBtn;

@property (weak, nonatomic) IBOutlet UITextField *usernameInput;
@property (weak, nonatomic) IBOutlet UITextField *passwordInput;
@property (weak, nonatomic) IBOutlet UIButton *saveBtn;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property (weak, nonatomic) IBOutlet UIButton *scanBtn;
@property (weak, nonatomic) IBOutlet UILabel *versionLbl;

- (IBAction)login:(id)sender;


- (void)keyboardWillHide:(NSNotification *)notification;
- (void)keyboardWillShow:(NSNotification *)notification;
- (void)hideKeyboardBeforeResignActive:(NSNotification *)notification;

// 加载持久存储的一下设置
-(void)loadSettings;
-(void)saveSettings;

@end
