//
//  MyEAccountViewController.h
//  MyE
//
//  Created by 翟强 on 14-7-7.
//  Copyright (c) 2014年 MyEnergy Domain. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EGORefreshTableHeaderView.h"

@interface MyEAccountViewController : UITableViewController<MyEDataLoaderDelegate,EGORefreshTableHeaderDelegate>

@property (weak, nonatomic) IBOutlet UILabel *userNameLbl;
@property (weak, nonatomic) IBOutlet UISwitch *notiSwitch;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *sidebarButton;

@end
