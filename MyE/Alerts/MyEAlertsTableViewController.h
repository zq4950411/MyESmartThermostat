//
//  MyEAlertsTableViewController.h
//  MyE
//
//  Created by Ye Yuan on 5/24/14.
//  Copyright (c) 2014 MyEnergy Domain. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MyEAlertsTableViewController : UITableViewController<MyEDataLoaderDelegate,MBProgressHUDDelegate>
{
@private
    MBProgressHUD *HUD;
}
@property (strong, nonatomic) NSMutableArray *alerts;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *sidebarButton;
@property (assign, nonatomic) BOOL fromHome;

@end
