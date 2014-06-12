//
//  MyEHouseUsefullViewController.h
//  MyE
//
//  Created by 翟强 on 14-6-11.
//  Copyright (c) 2014年 MyEnergy Domain. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MyEMediatorRegisterViewController.h"
@interface MyEHouseUsefullViewController : UITableViewController
@property (nonatomic, weak) NSArray *houses;
@property (nonatomic) NSInteger selectHouseIndex;
@end
