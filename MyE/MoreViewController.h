//
//  MoreViewController.h
//  MyE
//
//  Created by space on 13-8-30.
//  Copyright (c) 2013年 MyEnergy Domain. All rights reserved.
//

#import "BaseTableViewController.h"
#import "CommonCell.h"

@interface MoreViewController : BaseTableViewController <UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate>
{
    BOOL isSwitch;
    
    CommonCell *typeCell;
}

@property (nonatomic,strong) CommonCell *typeCell;

@end