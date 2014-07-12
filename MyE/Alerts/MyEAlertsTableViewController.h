//
//  MyEAlertsTableViewController.h
//  MyE
//
//  Created by Ye Yuan on 5/24/14.
//  Copyright (c) 2014 MyEnergy Domain. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef enum {
    ALERT_LOAD_TYPE_INIT,// init load when enter this VC at first time
    ALERT_LOAD_TYPE_PULL_REFRESH, // pull down to refresh
    ALERT_LOAD_TYPE_DRAG_LOADMORE // drag up to load more
} ALERT_LOAD_TYPE;

@interface MyEAlertsTableViewController : UITableViewController<MyEDataLoaderDelegate,MBProgressHUDDelegate, UIAlertViewDelegate,EGORefreshTableHeaderDelegate>
{
@private
    MBProgressHUD *HUD;
    NSUInteger _totalCount;//total alert count on server
    NSInteger _pageIndex;//current zero-based page index that has already loaded, init value is -1 indicating not load any thing
}
@property (strong, nonatomic) NSMutableArray *alerts;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *sidebarButton;
@property (weak, nonatomic) IBOutlet UIButton *refreshBtn;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activity;

@property (assign, nonatomic) BOOL fromHome;

@end
