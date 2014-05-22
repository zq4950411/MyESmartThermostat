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
}

#pragma mark - IBAction methods
- (IBAction)setScheduleTime:(UIButton *)sender {
    
}
- (IBAction)save:(UIBarButtonItem *)sender {
    if (![_newSchedule.weeks count]) {
        [MyEUtil showMessageOn:nil withMessage:@"Please select weekDay"];
    }
    [self uploadOrDownloadInfoFromServerWithURL:[NSString stringWithFormat:@"%@?houseId=%i&tId=%@&deviceId=%@&scheduleId=%i&onTime=%@&offTime=%@&weeks=%@&runFlag=%i&action=%i",GetRequst(URL_FOR_SOCKET_SAVE_PLUG_SCHEDULE),MainDelegate.houseData.houseId,self.device.tid,self.device.deviceId,_newSchedule.scheduleId,_newSchedule.onTime,_newSchedule.offTime,[_newSchedule.weeks componentsJoinedByString:@","],_newSchedule.runFlag,self.isAdd?1:2] andName:@"editSchedule"];
}
#pragma mark - private methods
-(void)refreshUI{
    [self.timeBtn setTitle:[NSString stringWithFormat:@"%@ - %@",_newSchedule.onTime,_newSchedule.offTime] forState:UIControlStateNormal];
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
    if ([string isEqualToString:@"-999"]) {
        [SVProgressHUD showErrorWithStatus:@"No Connection"];
    }else if(![string isEqualToString:@"fail"]){
        if (self.isAdd) {
            [self.schedules.schedules addObject:_newSchedule];
        }else{
            //这里特别注意，不能直接copy变量，只能一个一个的赋值
            self.schedule.onTime = _newSchedule.onTime;
            self.schedule.offTime = _newSchedule.offTime;
            self.schedule.weeks = _newSchedule.weeks;
        }
        [self.navigationController popViewControllerAnimated:YES];
    }else{
        [SVProgressHUD showErrorWithStatus:@"Fail"];
    }
}
#pragma mark - MyEWeekBtns Delegate methods
-(void)weekButtons:(UIView *)weekButtons selectedButtonTag:(NSArray *)buttonTags{
    self.schedule.weeks = [NSMutableArray arrayWithArray:buttonTags];
}
@end
