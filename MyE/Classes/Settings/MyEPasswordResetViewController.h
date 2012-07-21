//
//  MyEPasswordResetViewController.h
//  MyE
//
//  Created by Ye Yuan on 3/29/12.
//  Copyright (c) 2012 MyEnergy Domain. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MyEDataLoader.h"
#import "MBProgressHUD.h"


@interface MyEPasswordResetViewController : UITableViewController <UITextFieldDelegate, MyEDataLoaderDelegate,MBProgressHUDDelegate> {
    MBProgressHUD *HUD;
}
@property (copy, nonatomic) NSString *userId;
@property (nonatomic) NSInteger houseId;

@property (weak, nonatomic) IBOutlet UITextField *currentPasswordTextField;
@property (weak, nonatomic) IBOutlet UITextField *npaswdTextField0;
@property (weak, nonatomic) IBOutlet UITextField *npaswdTextField1;


- (IBAction)cancelAction:(id)sender;
- (IBAction)okAction:(id)sender;

- (void)uploadModelToServerWithCurrentPassword:(NSString *)currentPassword newPassword:(NSString *)newPassword;
@end
