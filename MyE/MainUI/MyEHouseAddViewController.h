//
//  MyEHouseAddViewController.h
//  MyE
//
//  Created by 翟强 on 14-5-15.
//  Copyright (c) 2014年 MyEnergy Domain. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MYEPickerView.h"
#import "ACPButton.h"
@interface MyEHouseAddViewController : UITableViewController<MyEDataLoaderDelegate,UIAlertViewDelegate,MYEPickerViewDelegate>
@property (weak, nonatomic) IBOutlet UITextField *txtStreet;
@property (weak, nonatomic) IBOutlet UITextField *txtCity;
@property (weak, nonatomic) IBOutlet UILabel *lblState;
@property (weak, nonatomic) IBOutlet UIButton *bindBtn;
@property (nonatomic, weak) MyEAccountData *accountData;
@property (weak, nonatomic) IBOutlet ACPButton *okBtn;

@end
