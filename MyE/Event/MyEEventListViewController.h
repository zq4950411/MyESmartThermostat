//
//  MyEEventListViewController.h
//  MyE
//
//  Created by 翟强 on 14-5-14.
//  Copyright (c) 2014年 MyEnergy Domain. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MyEEventListViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,EGORefreshTableHeaderDelegate,MyEDataLoaderDelegate>

@property (nonatomic, strong) MyEEvents *events;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *sidebarButton;
@end
