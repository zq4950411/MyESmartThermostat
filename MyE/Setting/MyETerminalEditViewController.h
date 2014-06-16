//
//  MyETerminalEditViewController.h
//  MyE
//
//  Created by 翟强 on 14-6-16.
//  Copyright (c) 2014年 MyEnergy Domain. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MyESettingsInfo.h"
#import "MyEDataLoader.h"

@interface MyETerminalEditViewController : UITableViewController<MyEDataLoaderDelegate>
@property (nonatomic, strong) MyESettingsTerminal *terminal;
@property (weak, nonatomic) IBOutlet UITextField *nameTxt;
@property (weak, nonatomic) IBOutlet UIImageView *signalImg;
@property (weak, nonatomic) IBOutlet UILabel *TypeLbl;
@property (weak, nonatomic) IBOutlet UILabel *tidLbl;
@property (weak, nonatomic) IBOutlet UILabel *controlLbl;
@property (weak, nonatomic) IBOutlet UISwitch *controlState;


@end
