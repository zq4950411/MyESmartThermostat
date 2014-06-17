//
//  MyESettingsPasswordResetViewController.h
//  MyE
//
//  Created by 翟强 on 14-6-17.
//  Copyright (c) 2014年 MyEnergy Domain. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MyESettingsPasswordResetViewController : UITableViewController<UITextFieldDelegate,MyEDataLoaderDelegate>
@property (nonatomic,strong) IBOutlet UITextField *pwd;
@property (nonatomic,strong) IBOutlet UITextField *nowPwd;
@property (nonatomic,strong) IBOutlet UITextField *renewPwd;
@end
