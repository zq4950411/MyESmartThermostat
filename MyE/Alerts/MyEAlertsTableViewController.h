//
//  MyEAlertsTableViewController.h
//  MyE
//
//  Created by Ye Yuan on 5/24/14.
//  Copyright (c) 2014 MyEnergy Domain. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UITableView+DragLoad.h"
typedef enum {
    ALERT_LOAD_TYPE_INIT,
    ALERT_LOAD_TYPE_PULL_REFRESH,
    ALERT_LOAD_TYPE_DRAG_LOADMORE
} ALERT_LOAD_TYPE;

@interface MyEAlertsTableViewController : UITableViewController
<MyEDataLoaderDelegate,MBProgressHUDDelegate, UIAlertViewDelegate,UITableViewDragLoadDelegate>
{
@private
    MBProgressHUD *HUD;
    NSUInteger _totalCount;//total alert count on server
    NSInteger _pageIndex;//current zero-based page index that has already loaded, init value is -1 indicating not load any thing
}
@property (strong, nonatomic) NSMutableArray *alerts;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *sidebarButton;
@property (assign, nonatomic) BOOL fromHome;

@end
