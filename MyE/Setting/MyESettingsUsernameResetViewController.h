//
//  MyESettingsUsernameResetViewController.h
//  MyE
//
//  Created by 翟强 on 14-7-5.
//  Copyright (c) 2014年 MyEnergy Domain. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MyEAccountData.h"
@interface MyESettingsUsernameResetViewController : UITableViewController<MyEDataLoaderDelegate>
@property (weak, nonatomic) IBOutlet UITextField *txtUsername;

@end
