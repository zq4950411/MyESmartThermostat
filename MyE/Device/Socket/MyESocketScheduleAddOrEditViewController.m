//
//  MyESocketScheduleAddOrEditViewController.m
//  MyE
//
//  Created by 翟强 on 14-5-21.
//  Copyright (c) 2014年 MyEnergy Domain. All rights reserved.
//

#import "MyESocketScheduleAddOrEditViewController.h"

@interface MyESocketScheduleAddOrEditViewController (){
    MBProgressHUD *HUD;
    MyESocketSchedule *_newSchedule;
    MYEPickerView *_picker;
    NSMutableArray *_startTimeArray;
    NSMutableArray *_endTimeArray;
}

@end

@implementation MyESocketScheduleAddOrEditViewController
#pragma mark - life circle Methods
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.weekBtns.delegate = self;
    _newSchedule = [self.schedule copy]; //复制一个，用于修改内部数据，这样的话不会修改原来的数据
    [self refreshUI];
    _startTimeArray = [NSMutableArray array];
    _endTimeArray = [NSMutableArray array];
    for (int i = 0; i < 48; i++) {
        [_startTimeArray addObject:[NSString stringWithFormat: @"%@",  [MyEUtil timeStringForHhid:i]]];
    }
    for (int i = 1; i < 49; i++) {
        [_endTimeArray addObject:[NSString stringWithFormat: @"%@",  [MyEUtil timeStringForHhid:i]]];
    }
    NSString *imgName = IS_IOS6?@"detailBtn-ios6":@"detailBtn";
    [self.startTimeBtn setBackgroundImage:[[UIImage imageNamed:imgName] stretchableImageWithLeftCapWidth:0 topCapHeight:0] forState:UIControlStateNormal];
    [self.startTimeBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 30)];
    [self.endTimeBtn setBackgroundImage:[[UIImage imageNamed:imgName] stretchableImageWithLeftCapWidth:0 topCapHeight:0] forState:UIControlStateNormal];
    [self.endTimeBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 30)];
}

#pragma mark - IBAction methods
- (IBAction)setScheduleTime:(UIButton *)sender {
    if (sender.tag == 301) {
        _picker = [[MYEPickerView alloc] initWithView:self.view andTag:sender.tag title:@"select startTime" dataSource:_startTimeArray andSelectRow:[_startTimeArray containsObject:sender.currentTitle]?[_startTimeArray indexOfObject:sender.currentTitle]:0];
    }else
        _picker = [[MYEPickerView alloc] initWithView:self.view andTag:sender.tag title:@"select endTime" dataSource:_endTimeArray andSelectRow:[_endTimeArray containsObject:sender.currentTitle]?[_endTimeArray indexOfObject:sender.currentTitle]:0];
    _picker.delegate = self;
    [_picker showInView:self.view];
}
- (IBAction)save:(UIBarButtonItem *)sender {
    if (![_newSchedule.weeks count]) {
        [MyEUtil showMessageOn:nil withMessage:@"Please select weekDay"];
        return;
    }
    [self uploadOrDownloadInfoFromServerWithURL:[NSString stringWithFormat:@"%@?houseId=%i&tId=%@&action=2",GetRequst(URL_FOR_SOCKET_MUTEX_DELAY),MainDelegate.houseData.houseId,self.device.tid] andName:@"check"];
}
#pragma mark - private methods
-(void)refreshUI{
    [self.startTimeBtn setTitle:[NSString stringWithFormat:@"%@",_newSchedule.onTime] forState:UIControlStateNormal];
    [self.endTimeBtn setTitle:[NSString stringWithFormat:@"%@",_newSchedule.offTime] forState:UIControlStateNormal];
    self.weekBtns.selectedButtons = _newSchedule.weeks;
}
-(void)uploadOrDownloadInfoFromServerWithURL:(NSString *)url andName:(NSString *)name{
    if (HUD == nil) {
        HUD = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    }
    [HUD show:YES];
    MyEDataLoader *loader = [[MyEDataLoader alloc] initLoadingWithURLString:url postData:nil delegate:self loaderName:name userDataDictionary:nil];
    NSLog(@"loader is %@",loader.name);
}
#pragma mark - URL delegate methods
-(void)didReceiveString:(NSString *)string loaderName:(NSString *)name userDataDictionary:(NSDictionary *)dict{
    NSLog(@"receive string is %@",string);
    [HUD hide:YES];
    if ([name isEqualToString:@"editSchedule"]) {
        if ([string isEqualToString:@"-999"]) {
            [SVProgressHUD showErrorWithStatus:@"No Connection"];
        }else if (string.intValue == -506){
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Alert" message:@"time or week has existed! Please change it" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
        }else if(![string isEqualToString:@"fail"]){
            if (self.isAdd) {
                NSDictionary *dic = [string JSONValue];
                _newSchedule.scheduleId = [dic[@"scheduleId"] intValue];
                [self.schedules.schedules addObject:_newSchedule];
            }else{
                NSUInteger index = 0;
                if ([self.schedules.schedules containsObject:self.schedule]) {
                    index = [self.schedules.schedules indexOfObject:self.schedule];
                }
                [self.schedules.schedules removeObjectAtIndex:index];
                [self.schedules.schedules insertObject:_newSchedule atIndex:index];
//                //这里特别注意，不能直接copy变量，只能一个一个的赋值
//                self.schedule.onTime = _newSchedule.onTime;
//                self.schedule.offTime = _newSchedule.offTime;
//                self.schedule.weeks = _newSchedule.weeks;
            }
            [self.navigationController popViewControllerAnimated:YES];
        }else{
            [SVProgressHUD showErrorWithStatus:@"Fail"];
        }
    }
    if ([name isEqualToString:@"check"]) {
        if ([string isEqualToString:@"fail"]) {
            [SVProgressHUD showErrorWithStatus:@"Error!"];
        }else{
            NSDictionary *dic = [string JSONValue];
            NSInteger result = [dic[@"isMutex"] intValue];
            if (result == 1) {
                DXAlertView *alert = [[DXAlertView alloc] initWithTitle:@"Alert" contentText:@"A timer has been set for this plug. To enable the auto mode, the timer will be disabled. Do you want to continue?" leftButtonTitle:@"Cancel" rightButtonTitle:@"OK"];
                alert.rightBlock = ^{
                    [self uploadOrDownloadInfoFromServerWithURL:[NSString stringWithFormat:@"%@?houseId=%i&tId=%@&deviceId=%@&scheduleId=%i&onTime=%@&offTime=%@&weeks=%@&runFlag=%i&action=%i",GetRequst(URL_FOR_SOCKET_SAVE_PLUG_SCHEDULE),MainDelegate.houseData.houseId,self.device.tid,self.device.deviceId,_newSchedule.scheduleId,_newSchedule.onTime,_newSchedule.offTime,[_newSchedule.weeks componentsJoinedByString:@","],_newSchedule.runFlag,self.isAdd?1:2] andName:@"editSchedule"];
                };
                [alert show];
            }else{
                [self uploadOrDownloadInfoFromServerWithURL:[NSString stringWithFormat:@"%@?houseId=%i&tId=%@&deviceId=%@&scheduleId=%i&onTime=%@&offTime=%@&weeks=%@&runFlag=%i&action=%i",GetRequst(URL_FOR_SOCKET_SAVE_PLUG_SCHEDULE),MainDelegate.houseData.houseId,self.device.tid,self.device.deviceId,_newSchedule.scheduleId,_newSchedule.onTime,_newSchedule.offTime,[_newSchedule.weeks componentsJoinedByString:@","],_newSchedule.runFlag,self.isAdd?1:2] andName:@"editSchedule"];
            }
        }
    }
}
-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error loaderName:(NSString *)name{
    [HUD hide:YES];
    [SVProgressHUD showErrorWithStatus:@"Connection Fail"];
}
#pragma mark - MyEWeekBtns Delegate methods
-(void)weekButtons:(UIView *)weekButtons selectedButtonTag:(NSArray *)buttonTags{
    _newSchedule.weeks = [NSMutableArray arrayWithArray:buttonTags];
}
#pragma mark - MYEPickerView delegate methods
-(void)MYEPickerView:(UIView *)pickerView didSelectTitles:(NSString *)title andRow:(NSInteger)row{
    UIButton *btn = (UIButton *)[self.view viewWithTag:pickerView.tag];
    [btn setTitle:title forState:UIControlStateNormal];
    if (pickerView.tag == 301) {  //start time
        NSInteger i = [_endTimeArray indexOfObject:self.endTimeBtn.currentTitle];
        if (i <= row) {
            [self.endTimeBtn setTitle:_endTimeArray[row] forState:UIControlStateNormal];
        }
    }else{
        NSInteger i = [_startTimeArray indexOfObject:self.startTimeBtn.currentTitle];
        if (i >= row) {
            [self.startTimeBtn setTitle:_startTimeArray[row] forState:UIControlStateNormal];
        }
    }
    _newSchedule.onTime = self.startTimeBtn.currentTitle;
    _newSchedule.offTime = self.endTimeBtn.currentTitle;
}
@end
