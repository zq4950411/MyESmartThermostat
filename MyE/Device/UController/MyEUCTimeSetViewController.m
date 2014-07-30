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
    NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    _datePicker.locale = locale;
    NSArray *time = [self.sequential.startTime componentsSeparatedByString:@":"];
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"HH:mm"]; // 大写H表示24小时制,小写的h表示12小时制
    NSDate *date = [dateFormatter dateFromString:[NSString stringWithFormat:@"%i:%i",[time[0] intValue],[time[1] intValue]]];
    [self.datePicker setDate:date animated:YES];

//    [self.datePicker setDate:[NSDate dateWithTimeIntervalSinceNow:24*60*60] animated:YES];
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
    self.sequential.startTime = [NSString stringWithFormat:@"%i:%@",[comps hour],[comps minute]== 0?@"00":[NSString stringWithFormat:@"%i",[comps minute]]];
    [self.navigationController popViewControllerAnimated:YES];
}

@end
