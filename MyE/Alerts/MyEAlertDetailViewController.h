//
//  MyEAlertDetailViewController.h
//  MyE
//
//  Created by Ye Yuan on 6/3/14.
//  Copyright (c) 2014 MyEnergy Domain. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MyEAlert.h"
@interface MyEAlertDetailViewController : UIViewController<MyEDataLoaderDelegate>
@property (nonatomic, retain) MyEAlert *alert;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UITextView *contentTextView;
@property (weak, nonatomic) IBOutlet UILabel *publishDateLabel;

@end
