//
//  MyEUCTimeSetViewController.m
//  MyE
//
//  Created by 翟强 on 14-6-9.
//  Copyright (c) 2014年 MyEnergy Domain. All rights reserved.
//

#import "MyEUCTimeSetViewController.h"

@interface MyEUCTimeSetViewController ()

@end

@implementation MyEUCTimeSetViewController

#pragma mark - life circle methods
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.datePicker setDate:[NSDate dateWithTimeIntervalSinceNow:24*60*60] animated:YES];
    self.datePicker.minuteInterval = 10;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}
#pragma mark -IBAction methods
- (IBAction)saveEditer:(UIBarButtonItem *)sender {
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    NSInteger unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSWeekdayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit;
    comps = [calendar components:unitFlags fromDate:self.datePicker.date];
    NSLog(@"%i %i %i %i %i",[comps year],[comps month],[comps day],[comps hour],[comps minute]);
    self.sequential.startTime = [NSString stringWithFormat:@"%i:%i",[comps hour],[comps minute]];
    [self.navigationController popViewControllerAnimated:YES];
}

@end
