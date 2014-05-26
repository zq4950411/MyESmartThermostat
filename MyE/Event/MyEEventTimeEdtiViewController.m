//
//  MyEEventTimeEdtiViewController.m
//  MyE
//
//  Created by 翟强 on 14-5-14.
//  Copyright (c) 2014年 MyEnergy Domain. All rights reserved.
//

#import "MyEEventTimeEdtiViewController.h"

@interface MyEEventTimeEdtiViewController ()

@end

@implementation MyEEventTimeEdtiViewController

#pragma mark - life circle methods
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self changeDatePickerModeAndBtnWithTag:100]; //100是第一个btn的tag值
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - IBAction methods
- (IBAction)changeDate:(UIButton *)sender {
    if (sender.selected) {
        return;  //如果当前btn是选定状态，则不进行任何操作
    }
    [self changeDatePickerModeAndBtnWithTag:sender.tag];
}
- (IBAction)save:(UIBarButtonItem *)sender {
    NSLog(@"%@",self.datePicker.date);
}

#pragma mark - private methods
-(void)changeDatePickerModeAndBtnWithTag:(NSInteger)tag{
    UIButton *dateBtn = (UIButton *)[self.view viewWithTag:100];
    UIButton *timeBtn = (UIButton *)[self.view viewWithTag:101];
    if (tag == 100) {
        dateBtn.selected = YES;
        timeBtn.selected = NO;
        self.weekBtns.hidden = YES;
        self.datePicker.datePickerMode = UIDatePickerModeDateAndTime;
        self.datePicker.minimumDate = [NSDate date];
        self.datePicker.maximumDate = [[NSDate alloc] initWithTimeIntervalSinceNow:60*60*24*30*2];  //显示两个月之后的日期
    }else{
        dateBtn.selected = NO;
        timeBtn.selected = YES;
        self.weekBtns.hidden = NO;
        self.datePicker.datePickerMode = UIDatePickerModeTime;
    }
    self.datePicker.minuteInterval = 10;
}
#pragma mark - MYEWeekBtns delegate methods
-(void)weekButtons:(UIView *)weekButtons selectedButtonTag:(NSArray *)buttonTags{
    
}
@end
