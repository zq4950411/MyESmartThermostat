//
//  MyEHouseAddViewController.h
//  MyE
//
//  Created by 翟强 on 14-5-15.
//  Copyright (c) 2014年 MyEnergy Domain. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MyEHouseAddViewController : UIViewController<MyEDataLoaderDelegate>
@property (weak, nonatomic) IBOutlet UITextField *txtStreet;
@property (weak, nonatomic) IBOutlet UITextField *txtCity;
@property (weak, nonatomic) IBOutlet UITextField *txtState;
@property (weak, nonatomic) IBOutlet UIButton *bindBtn;

@end
