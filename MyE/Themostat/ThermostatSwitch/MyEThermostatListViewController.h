//
//  MyEThermostatListViewController.h
//  MyE
//
//  Created by Ye Yuan on 3/3/13.
//  Copyright (c) 2013 MyEnergy Domain. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MyEThermostatListViewController : UITableViewController{
}
@property (copy, nonatomic) NSString *userId;
@property (nonatomic) NSInteger houseId;
@property (nonatomic,copy) NSString *houseName;
@property (nonatomic, copy) NSString *tId;
@property (nonatomic, copy) NSString *tName;// 当前选择的t的名字



@property (nonatomic, retain) NSArray *thermostats;
- (IBAction)switchThermostatAction:(id)sender;

@end