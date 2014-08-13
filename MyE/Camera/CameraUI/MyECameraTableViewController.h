//
//  MyECameraTableViewController.h
//  MyEHomeCN2
//
//  Created by Ye Yuan on 4/27/14.
//  Copyright (c) 2014 My Energy Domain Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MyEEditCameraViewController.h"
#import "defineutility.h"
#import "PPPPChannelManagement.h"
#import "EGORefreshTableHeaderView.h"

@interface MyECameraTableViewController : UITableViewController <SnapshotProtocol,EGORefreshTableHeaderDelegate,MyEDataLoaderDelegate,PPPPStatusProtocol>

@property (nonatomic, retain) NSMutableArray *cameraList;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *sidebarButton;

@end
