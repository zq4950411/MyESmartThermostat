//
//  TimeChooseViewController.m
//  MyE
//
//  Created by space on 13-8-27.
//  Copyright (c) 2013年 MyEnergy Domain. All rights reserved.
//

#import "TimeChooseViewController.h"
#import "UIViewController+MJPopupViewController.h"
#import "ControlViewController.h"
#import "Sequential.h"

@implementation TimeChooseViewController

-(IBAction) dimss:(UIControl *) sender
{
    [parentVC dismissPopupViewControllerWithanimationType:MJPopupViewAnimationFade];
}

-(IBAction) ok:(UIButton *) sender
{
    if ([parentVC isKindOfClass:[ControlViewController class]])
    {
        ControlViewController *cc = (ControlViewController *)parentVC;
        cc.seq.startTime = [self getSelectedTime];
        
        [parentVC dismissPopupViewControllerWithanimationType:MJPopupViewAnimationFade];
    }
}

-(NSString *) getSelectedTime
{
    UIDatePicker *picker = (UIDatePicker *)[self.view viewWithTag:10];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"HH:mm"];
    NSString *dateString = [dateFormatter stringFromDate:[picker date]];
    
    return dateString;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
