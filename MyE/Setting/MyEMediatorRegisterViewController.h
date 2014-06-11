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
@interface MyEMediatorRegisterViewController : UITableViewController<MyEDataLoaderDelegate>
@property (nonatomic, weak) MyEAccountData *accountData;
@end
