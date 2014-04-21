//
//  MyEHomePanelViewController.h
//  MyE
//
//  Created by Ye Yuan on 4/14/14.
//  Copyright (c) 2014 MyEnergy Domain. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ACPbutton.h"

@interface MyEHomePanelViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIBarButtonItem *sidebarButton;

@property (weak, nonatomic) IBOutlet ACPButton *weatherTile;
@property (weak, nonatomic) IBOutlet UILabel *inflLabel;
- (IBAction)TestAction:(id)sender;
@end
