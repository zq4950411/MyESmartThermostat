//
//  MyESwitchScheduleSettingViewController.m
//  MyEHomeCN2
//
//  Created by 翟强 on 14-3-6.
//  Copyright (c) 2014年 My Energy Domain Inc. All rights reserved.
//

#import "MyESwitchScheduleSettingViewController.h"
#import "MyESwitchAutoViewController.h"
@interface MyESwitchScheduleSettingViewController ()

@end

@implementation MyESwitchScheduleSettingViewController
#pragma mark - life circle method
- (void)viewDidLoad
{
    [super viewDidLoad];
    for (UIButton *btn in self.view.subviews) {
        if ([btn isKindOfClass:[UIButton class]]) {
            [btn setBackgroundImage:[UIImage imageNamed:@"detailBtn"] forState:UIControlStateNormal];
            [btn setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 30)];
        }
    }
    if (self.control.numChannel == 1) {
        self.lights.titles = [@[@"1"] mutableCopy];
//        [self.channelSeg removeSegmentAtIndex:1 animated:YES];
//        [self.channelSeg removeSegmentAtIndex:2 animated:YES];
    }else if(self.control.numChannel == 2){
        self.lights.titles = [@[@"1",@"2"] mutableCopy];
//        [self.channelSeg removeSegmentAtIndex:2 animated:YES];
    }else
        self.lights.titles = [@[@"1",@"2",@"3"] mutableCopy];
    self.lights.delegate = self;
    self.weeks.delegate = self;
    
//    self.channelSeg.mydelegate = self;
//    self.weekSeg.mydelegate = self;
//    
    _scheduleNew = [self.schedule copy];
    _scheduleNew.runFlag = 1;
//    [self refreshSegment];
    self.weeks.selectedButtons = [_scheduleNew.weeks mutableCopy];
    self.lights.selectedButtons = [_scheduleNew.channels mutableCopy];
    self.lights.disableArray = self.control.channelDisabledStatus;

    [self.startBtn setTitle:_schedule.onTime forState:UIControlStateNormal];
    [self.endBtn setTitle:_schedule.offTime forState:UIControlStateNormal];
    
    NSMutableArray *array1 = [NSMutableArray array];
    NSMutableArray *array2 = [NSMutableArray array];
    for (int i = 0; i < 24; i++) {
        if (i < 10) {
            [array1 addObject:[NSString stringWithFormat:@"0%i",i]];
        }else
            [array1 addObject:[NSString stringWithFormat:@"%i",i]];
    }
    for (int i = 0; i< 6; i++) {
        if (i == 0) {
            [array2 addObject:@"00"];
        }else
            [array2 addObject:[NSString stringWithFormat:@"%i",i*10]];
    }
    _headTimeArray = array1;
    _tailTimeArray = array2;
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - private methods
-(void)doThisWhenNeedDownLoadOrUploadInfoWithURLString:(NSString *)url andName:(NSString *)name{
    if (HUD == nil) {
        HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    }
    [HUD show:YES];
    NSLog(@"%@ string is %@",name,url);
    MyEDataLoader *loader = [[MyEDataLoader alloc] initLoadingWithURLString:url postData:nil delegate:self loaderName:name userDataDictionary:nil];
    NSLog(@"%@ is %@",name,loader.name);
}
-(void)uploadInfoToServer{
    _scheduleNew.runFlag = 1;   //保存的时候进程的启用状态肯定为1，不能为0
    // 估计这里会有问题，因为数组没有转变为字符串(特别注意这里是怎么样转化为字符串的)
    //这里保存时默认是启用进程的
    [self doThisWhenNeedDownLoadOrUploadInfoWithURLString:[NSString stringWithFormat:@"%@?houseId=%li&tId=%@&deviceId=%i&scheduleId=%li&onTime=%@&offTime=%@&channels=%@&weeks=%@&runFlag=%i&action=%li",
                                                           GetRequst(URL_FOR_SWITCH_SCHEDULE_SAVE),
                                                           (long)MainDelegate.houseData.houseId, self.device.tid,[self.device.deviceId intValue],
                                                           (long)_scheduleNew.scheduleId,
                                                           _scheduleNew.onTime,
                                                           _scheduleNew.offTime,
                                                           [_scheduleNew.channels componentsJoinedByString:@","],
                                                           [_scheduleNew.weeks componentsJoinedByString:@","],_scheduleNew.runFlag,
                                                           (long)self.actionType] andName:@"scheduleEdit"];
}
-(NSMutableArray *)changeIndexSetToArrayWithIndexSet:(NSIndexSet *)indexSet{
    NSMutableArray *array = [NSMutableArray array];
    for (NSInteger i = [indexSet firstIndex];i != NSNotFound; i = [indexSet indexGreaterThanIndex: i])  {
        [array addObject:[NSNumber numberWithInteger:i+1]];
    }
    return array;
}
-(BOOL)isValid{  //用于判断时段和星期是否符合要求
    NSInteger onTime = [MyEUtil hhidForTimeString:_scheduleNew.onTime];
    NSInteger offTime = [MyEUtil hhidForTimeString:_scheduleNew.offTime];
    NSMutableArray *array = [NSMutableArray arrayWithArray:self.control.SSList];
    if (self.actionType == 2) {  //只有编辑的时候才这么做
        [array removeObject:self.schedule];
    }
    for (MyESwitchSchedule *s in array) {
        NSInteger onTime1 = [MyEUtil hhidForTimeString:s.onTime];
        NSInteger offTime1 = [MyEUtil hhidForTimeString:s.offTime];
        if(onTime >= offTime1 || offTime <= onTime1){
            continue;
        }else{
            for (NSNumber *i in _scheduleNew.weeks) {
                if ([s.weeks containsObject:i]) {
                    for (NSNumber *i in _scheduleNew.channels){
                        if([s.channels containsObject:i]){
                            return NO;
                        }
                    }
                }
            }
        }
    }
    return YES;
}
-(BOOL)isTimeUsefull{
    NSMutableString *startString = [NSMutableString stringWithString:self.startBtn.currentTitle];
    NSMutableString *endString = [NSMutableString stringWithString:self.endBtn.currentTitle];
    NSInteger startTime = [[startString stringByReplacingCharactersInRange:NSMakeRange(2, 1) withString:@"0"] intValue];
    NSInteger endTime = [[endString stringByReplacingCharactersInRange:NSMakeRange(2, 1) withString:@"0"] intValue];
    if (startTime >= endTime) {
        return NO;
    }
    return YES;
}
//-(void)refreshSegment{
//    NSMutableIndexSet *channelIndex = [NSMutableIndexSet indexSet];
//    NSMutableIndexSet *weekIndex = [NSMutableIndexSet indexSet];
//    for (NSNumber *i in _schedule.channels) {
//        [channelIndex addIndex:[i intValue]-1];
//    }
//    for (NSNumber *i in _schedule.weeks) {
//        [weekIndex addIndex:[i intValue]-1];
//    }
//    [self.channelSeg setSelectedSegmentIndexes:channelIndex];
//    [self.weekSeg setSelectedSegmentIndexes:weekIndex];
//}
-(NSArray *)changeStringToInt:(NSString *)title{
    NSArray *array = [NSArray array];
    if (title.length !=5) {
        NSLog(@"time is not correct");
//        DXAlertView *alert = [[DXAlertView alloc] initWithTitle:@"Warning" contentText:@"time is off" leftButtonTitle:nil rightButtonTitle:@"OK"];
//        [alert show];
        array = @[@1,@1];
    }else{
        NSInteger i = [_headTimeArray indexOfObject:[title substringToIndex:2]];
        NSInteger j = [_tailTimeArray indexOfObject:[title substringFromIndex:3]];
        array = @[@(i),@(j)];
    }
    return array;
}
#pragma mark - IBAction methods
- (IBAction)startBtnPressed:(UIButton *)sender{
    MYETimePicker *picker = [[MYETimePicker alloc] initWithView:self.view andTag:1 title:@"Start Time" interval:10 andDelegate:self];
    picker.time = sender.currentTitle;
    [picker show];
}
- (IBAction)endBtnPressed:(UIButton *)sender {
    MYETimePicker *picker = [[MYETimePicker alloc] initWithView:self.view andTag:2 title:@"End Time" interval:10 andDelegate:self];
    picker.time = sender.currentTitle;
    [picker show];
}
- (IBAction)saveEditor:(UIBarButtonItem *)sender {
    if (![self isTimeUsefull]) {
        [MyEUtil showMessageOn:nil withMessage:@"Start time must be less than the end time"];
        return;
    }
//    _scheduleNew.channels = [self changeIndexSetToArrayWithIndexSet:self.channelSeg.selectedSegmentIndexes];
//    _scheduleNew.weeks = [self changeIndexSetToArrayWithIndexSet:self.weekSeg.selectedSegmentIndexes];
    if ([_scheduleNew.channels count] == 0) {
        [MyEUtil showMessageOn:nil withMessage:@"Please select at least one light"];
        return;
    }
    if ([_scheduleNew.weeks count] == 0) {
        [MyEUtil showMessageOn:nil withMessage:@"Please select at least one day"];
        return;
    }
//    if (![self isValid]) {
//        [MyEUtil showMessageOn:nil withMessage:@"Time period overlap, please adjust time."];
//        return;
//    }
    [self doThisWhenNeedDownLoadOrUploadInfoWithURLString:[NSString stringWithFormat:@"%@?houseId=%li&tId=%@&channels=%@&action=2",GetRequst(URL_FOR_SWITCH_TIME_DELAY),(long)MainDelegate.houseData.houseId, self.device.tid,[_scheduleNew.channels componentsJoinedByString:@","]] andName:@"check"];
}

//#pragma mark - MultiSelectSegmentedControlDelegate methods
//-(void)multiSelect:(MultiSelectSegmentedControl*) multiSelecSegmendedControl didChangeValue:(BOOL) value atIndex: (NSUInteger) index{
//    
//    NSIndexSet *anIndexSet;
//    if (multiSelecSegmendedControl == self.channelSeg) {
//        anIndexSet = self.channelSeg.selectedSegmentIndexes;
//    }else
//        anIndexSet = self.weekSeg.selectedSegmentIndexes;
//    
//    if ([anIndexSet count] == 0) {
//        [MyEUtil showMessageOn:self.view withMessage:multiSelecSegmendedControl == self.channelSeg?@"Must select at least one channel":@"Must select at least one day"];
//    }
//}
#pragma mark - MYEWeekBtns delegate methods
-(void)weekButtons:(UIView *)weekButtons selectedButtonTag:(NSArray *)buttonTags{
    if (weekButtons.tag == 500) {
        _scheduleNew.channels = [buttonTags mutableCopy];
    }else
        _scheduleNew.weeks = [buttonTags mutableCopy];
}
#pragma mark - IQActionSheetPickerView delegate methods
-(void)MYETimePicker:(UIView *)picker didSelectString:(NSString *)title{
    if (picker.tag == 1) {
        [self.startBtn setTitle:title forState:UIControlStateNormal];
        _scheduleNew.onTime = title;
    }else{
        [self.endBtn setTitle:title forState:UIControlStateNormal];
        _scheduleNew.offTime = title;
    }
}

#pragma mark - url delegate methods
-(void)didReceiveString:(NSString *)string loaderName:(NSString *)name userDataDictionary:(NSDictionary *)dict{
    NSLog(@"receive string is %@",string);
    [HUD hide:YES];
    if ([name isEqualToString:@"check"]) {
        NSLog(@"check string is %@",string);
        if (![string isEqualToString:@"fail"]) {
            SBJsonParser *parser = [[SBJsonParser alloc] init];
            NSDictionary *dict = [parser objectWithString:string];
            int isMutex = [[dict objectForKey:@"isMutex"] intValue];
            
            if(isMutex == 1){
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Alert" message:@"A timer has been set for this switch. To enable the auto mode, the timer will be disabled. Do you want to continue?" delegate:self cancelButtonTitle:@"NO" otherButtonTitles:@"YES", nil];
                alert.tag = 900;
                [alert show];
            }else if(isMutex == 2){
                [self uploadInfoToServer];
            }else
                [MyEUtil showMessageOn:nil withMessage:[NSString stringWithFormat:@"Wrong code:%i from server",isMutex]];
        }else {
            [MyEUtil showMessageOn:nil withMessage:@"Failed to communicate with server"];
        }
    }
    if ([name isEqualToString:@"scheduleEdit"]) {
        if (string.intValue == -506) {
            [MyEUtil showMessageOn:nil withMessage:@"Time period overlap, please adjust time."];
            return;
        }
        if (self.actionType == 1) {  //新增进程
            if (![string isEqualToString:@"fail"]) {
                MyESwitchSchedule *schedule = [[MyESwitchSchedule alloc] initWithString:string];
                _scheduleNew.scheduleId = schedule.scheduleId;
                [self.control.SSList addObject:_scheduleNew];
                [self.navigationController popViewControllerAnimated:YES];
                NSLog(@"Add new period successfully");
            } else {
                [MyEUtil showMessageOn:nil withMessage:[NSString stringWithFormat:@"Falied to add new period"]];
            }
        }else{
            if([string isEqualToString:@"OK"]){
                if ([self.control.SSList containsObject:self.schedule]) {
                    NSInteger i = [self.control.SSList indexOfObject:self.schedule];
                    [self.control.SSList removeObject:self.schedule];
                    [self.control.SSList insertObject:_scheduleNew atIndex:i];
                }
                [self.navigationController popViewControllerAnimated:YES];
                NSLog(@"Edit period successfully");
            }
            else {
                [MyEUtil showMessageOn:nil withMessage:[NSString stringWithFormat:@"Falied to edit period"]];
            }
        }
    }
}
-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error loaderName:(NSString *)name{
    [HUD hide:YES];
    [SVProgressHUD showErrorWithStatus:@"Connection Fail"];
}
#pragma mark - UIAlertView Delegate methods
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (alertView.tag == 900 && buttonIndex == 1) {
        //这里也要进行手动控制面板的刷新
        UINavigationController *nav = self.tabBarController.childViewControllers[0];
        MyESwitchManualControlViewController *vc = nav.childViewControllers[0];
        vc.needRefresh = YES;
        [self uploadInfoToServer];
    }
}
@end
