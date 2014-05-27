//
//  MyEEventTimeEdtiViewController.m
//  MyE
//
//  Created by 翟强 on 14-5-14.
//  Copyright (c) 2014年 MyEnergy Domain. All rights reserved.
//

#import "MyEEventTimeEdtiViewController.h"

@interface MyEEventTimeEdtiViewController (){
    MyEEventConditionTime *_newTime;
}

@end

@implementation MyEEventTimeEdtiViewController

#pragma mark - life circle methods
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self changeDatePickerModeAndBtnWithTag:100]; //100是第一个btn的tag值
    _newTime = [self.conditionTime copy];
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
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    NSInteger unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSWeekdayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit;
    comps = [calendar components:unitFlags fromDate:self.datePicker.date];
    NSLog(@"%i %i %i %i %i",[comps year],[comps month],[comps day],[comps hour],[comps minute]);
    if (_newTime.timeType == 1) {  //表示的是日期
        _newTime.date = [NSString stringWithFormat:@"%i/%i/%i",[comps month],[comps day],[comps year]];
        _newTime.weeks = [NSMutableArray array];
    }else{
        _newTime.date = @"";
    }
    _newTime.hour = [comps hour];
    _newTime.minute = [comps minute];
    
    MyEDataLoader *loader = [[MyEDataLoader alloc] initLoadingWithURLString:[NSString stringWithFormat:@"%@?houseId=%i&sceneId=%i&id=%i&timeType=%i&triggerData=%@&weekly=%@&hour=%i&minute=%i&action=%i",GetRequst(URL_FOR_SCENES_CONDITION_TIME),MainDelegate.houseData.houseId,self.eventInfo.sceneId,self.conditionTime.conditionId,self.conditionTime.timeType,self.conditionTime.date,[self.conditionTime.weeks componentsJoinedByString:@","],self.conditionTime.hour,self.conditionTime.minute,self.isAdd?1:2] postData:nil delegate:self loaderName:@"time" userDataDictionary:nil];
    
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
    _newTime.weeks = [buttonTags mutableCopy];
}
@end
