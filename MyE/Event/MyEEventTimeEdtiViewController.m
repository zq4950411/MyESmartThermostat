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
    self.weekBtns.delegate = self;
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
        NSLog(@"%@",_newTime.date);
        _newTime.weeks = [NSMutableArray array];
    }else{
        _newTime.date = @"";
    }
    _newTime.hour = [comps hour];
    _newTime.minute = (int)([comps minute]/10)*10;
    
    MyEDataLoader *loader = [[MyEDataLoader alloc] initLoadingWithURLString:[NSString stringWithFormat:@"%@?houseId=%i&sceneId=%i&id=%i&timeType=%i&triggerDate=%@&weekly=%@&hour=%i&minute=%i&action=%i",GetRequst(URL_FOR_SCENES_CONDITION_TIME),MainDelegate.houseData.houseId,self.eventInfo.sceneId,_newTime.conditionId,_newTime.timeType,_newTime.date,[_newTime.weeks componentsJoinedByString:@","],_newTime.hour,_newTime.minute,self.isAdd?1:2] postData:nil delegate:self loaderName:@"time" userDataDictionary:nil];
    NSLog(@"loader name is %@",loader.name);
}

#pragma mark - private methods
-(void)changeDatePickerModeAndBtnWithTag:(NSInteger)tag{
    UIButton *dateBtn = (UIButton *)[self.view viewWithTag:100];
    UIButton *timeBtn = (UIButton *)[self.view viewWithTag:101];
    if (tag == 100) {
        _newTime.timeType = 1;
        dateBtn.selected = YES;
        timeBtn.selected = NO;
        self.weekBtns.hidden = YES;
        self.datePicker.datePickerMode = UIDatePickerModeDateAndTime;
        self.datePicker.minimumDate = [NSDate date];
        self.datePicker.maximumDate = [[NSDate alloc] initWithTimeIntervalSinceNow:60*60*24*30*2];  //显示两个月之后的日期
    }else{
        _newTime.timeType = 2;
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
#pragma mark - URL delegate methods
-(void)didReceiveString:(NSString *)string loaderName:(NSString *)name userDataDictionary:(NSDictionary *)dict{
    NSLog(@"recieve string is %@",string);
    if (![string isEqualToString:@"fail"]) {
        if (self.isAdd) {
            NSDictionary *dic = [string JSONValue];
            _newTime.conditionId = [dic[@"id"] intValue];
            [self.eventDetail.timeConditions addObject:_newTime];
        }else{
            if ([self.eventDetail.timeConditions containsObject:self.conditionTime]) {
                NSInteger i = [self.eventDetail.timeConditions indexOfObject:self.conditionTime];
                [self.eventDetail.timeConditions removeObjectAtIndex:i];
                [self.eventDetail.timeConditions insertObject:_newTime atIndex:i];
            }
        }
    }else
        [SVProgressHUD showErrorWithStatus:@"Error!"];
}
@end
