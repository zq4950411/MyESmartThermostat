//
//  SmartUpViewController.h
//  MyE
//
//  Created by space on 13-8-6.
//  Copyright (c) 2013年 MyEnergy Domain. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseTableViewController.h"
#import "MyESwitchEditViewController.h"
@class SmartUp;

@interface SmartUpViewController : BaseTableViewController <UITableViewDataSource,UITableViewDelegate,UIAlertViewDelegate,MyEDataLoaderDelegate>
{
    NSInteger currentTapIndex;
    NSIndexPath *_selectedIndexPath;
}

-(SmartUp *) getCurrentSmartup;

@end
