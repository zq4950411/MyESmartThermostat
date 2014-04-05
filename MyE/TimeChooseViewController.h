//
//  TimeChooseViewController.h
//  MyE
//
//  Created by space on 13-8-27.
//  Copyright (c) 2013年 MyEnergy Domain. All rights reserved.
//

#import "BaseViewController.h"

@interface TimeChooseViewController : BaseViewController


-(IBAction) ok:(UIButton *) sender;
-(IBAction) dimss:(UIControl *) sender;

-(NSString *) getSelectedTime;

@end

