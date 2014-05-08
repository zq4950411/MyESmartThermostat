//
//  MyEMainMenuViewController.h
//  MyE
//
//  Created by Ye Yuan on 4/15/14.
//  Copyright (c) 2014 MyEnergy Domain. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MyEMainMenuViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, strong) NSArray *menuItems;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UILabel *houseName;
- (IBAction)goHouseList:(id)sender;
@end
