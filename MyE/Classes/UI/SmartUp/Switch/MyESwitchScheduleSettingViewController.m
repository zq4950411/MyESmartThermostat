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

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    if (!IS_IOS6) {
        for (UIButton *btn in self.view.subviews) {
            if ([btn isKindOfClass:[UIButton class]]) {
                [btn setBackgroundImage:[UIImage imageNamed:@"detailBtn"] forState:UIControlStateNormal];
                [btn setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 30)];
            }
        }
    }else{
        for (UIButton *btn in self.view.subviews) {
            if ([btn isKindOfClass:[UIButton class]]) {
                [btn setBackgroundImage:[UIImage imageNamed:@"detailBtn-ios6"] forState:UIControlStateNormal];
                [btn setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 30)];
            }
        }
    }

    self.channelSeg.mydelegate = self;
    self.weekSeg.mydelegate = self;
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
    
    _scheduleNew = [[MyESwitchSchedule alloc] init];
    if (self.actionType == 1) {  //新增时段
        self.schedule = [[MyESwitchSchedule alloc] init];
        [self.startBtn setTitle:@"12:00" forState:UIControlStateNormal];
        [self.endBtn setTitle:@"12:30" forState:UIControlStateNormal];
    }else{
        _scheduleNew = [_schedule copy];
        self.navigationItem.rightBarButtonItem.enabled = NO;
        [self.startBtn setTitle:_schedule.onTime forState:UIControlStateNormal];
        [self.endBtn setTitle:_schedule.offTime forState:UIControlStateNormal];
        [self refreshSegment];
        _initArray = @[self.startBtn.currentTitle,self.endBtn.currentTitle,[self changeIndexSetToArrayWithIndexSet:self.channelSeg.selectedSegmentIndexes],[self changeIndexSetToArrayWithIndexSet:self.weekSeg.selectedSegmentIndexes]];   //这里进行初始化，作为比较的基准
    }
}
-(void)viewWillDisappear:(BOOL)animated{
    MyESwitchAutoViewController *vc = self.navigationController.childViewControllers[0];
    vc.jumpFromSubView = YES;
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
    // 估计这里会有问题，因为数组没有转变为字符串(特别注意这里是怎么样转化为字符串的)
    [self doThisWhenNeedDownLoadOrUploadInfoWithURLString:[NSString stringWithFormat:@"%@?houseId=%li&tId=%@&deviceId=%i&scheduleId=%li&onTime=%@&offTime=%@&channels=%@&weeks=%@&action=%li",
                                                           GetRequst(URL_FOR_SWITCH_SCHEDULE_SAVE),
                                                           (long)MainDelegate.houseData.houseId, self.device.tid,[self.device.deviceId intValue],
                                                           (long)_scheduleNew.scheduleId,
                                                           _scheduleNew.onTime,
                                                           _scheduleNew.offTime,
                                                           [_scheduleNew.channels componentsJoinedByString:@","],
                                                           [_scheduleNew.weeks componentsJoinedByString:@","],
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
-(void)changeBarBtnEnable{
    NSArray *array = @[self.startBtn.currentTitle,self.endBtn.currentTitle,[self changeIndexSetToArrayWithIndexSet:self.channelSeg.selectedSegmentIndexes],[self changeIndexSetToArrayWithIndexSet:self.weekSeg.selectedSegmentIndexes]];
    if (![array isEqualToArray:_initArray]) {
        self.navigationItem.rightBarButtonItem.enabled = YES;
    }else
        self.navigationItem.rightBarButtonItem.enabled = NO;
}
-(void)refreshSegment{
    NSMutableIndexSet *channelIndex = [NSMutableIndexSet indexSet];
    NSMutableIndexSet *weekIndex = [NSMutableIndexSet indexSet];
    for (NSNumber *i in _schedule.channels) {
        [channelIndex addIndex:[i intValue]-1];
    }
    for (NSNumber *i in _schedule.weeks) {
        [weekIndex addIndex:[i intValue]-1];
    }
    [self.channelSeg setSelectedSegmentIndexes:channelIndex];
    [self.weekSeg setSelectedSegmentIndexes:weekIndex];
}
-(NSArray *)changeStringToInt:(NSString *)title{
    NSArray *array = [NSArray array];
    if (title.length !=5) {
        DXAlertView *alert = [[DXAlertView alloc] initWithTitle:@"Warning" contentText:@"time is off" leftButtonTitle:nil rightButtonTitle:@"OK"];
        [alert show];
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
    [MyEUniversal doThisWhenNeedPickerWithTitle:@"Start time" andDelegate:self andTag:1 andArray:@[_headTimeArray,_tailTimeArray] andSelectRow:[self changeStringToInt:sender.currentTitle] andViewController:self];
}
- (IBAction)endBtnPressed:(UIButton *)sender {
    [MyEUniversal doThisWhenNeedPickerWithTitle:@"End time" andDelegate:self andTag:2 andArray:@[_headTimeArray,_tailTimeArray] andSelectRow:[self changeStringToInt:sender.currentTitle] andViewController:self];
}
- (IBAction)saveEditor:(UIBarButtonItem *)sender {
    if (![self isTimeUsefull]) {
        [MyEUtil showMessageOn:nil withMessage:@"Start time must be less than the end time"];
        return;
    }
    _scheduleNew.onTime = self.startBtn.currentTitle;
    _scheduleNew.offTime = self.endBtn.currentTitle;
    _scheduleNew.channels = [self changeIndexSetToArrayWithIndexSet:self.channelSeg.selectedSegmentIndexes];
    _scheduleNew.weeks = [self changeIndexSetToArrayWithIndexSet:self.weekSeg.selectedSegmentIndexes];
    if ([_scheduleNew.channels count] == 0) {
        [MyEUtil showMessageOn:nil withMessage:@"Please select at least one light"];
        return;
    }
    if ([_scheduleNew.weeks count] == 0) {
        [MyEUtil showMessageOn:nil withMessage:@"Please select at least one day"];
        return;
    }
    if (![self isValid]) {
        [MyEUtil showMessageOn:nil withMessage:@"Time period overlap, please adjust time."];
        return;
    }
    if (self.actionType == 1) {
        _scheduleNew.scheduleId = 0;
    }
    [self doThisWhenNeedDownLoadOrUploadInfoWithURLString:[NSString stringWithFormat:@"%@?houseId=%li&tId=%@&channels=%@&action=2",GetRequst(URL_FOR_SWITCH_TIME_DELAY),(long)MainDelegate.houseData.houseId, self.device.tid,[_scheduleNew.channels componentsJoinedByString:@","]] andName:@"check"];
}

#pragma mark - MultiSelectSegmentedControlDelegate methods
-(void)multiSelect:(MultiSelectSegmentedControl*) multiSelecSegmendedControl didChangeValue:(BOOL) value atIndex: (NSUInteger) index{

    NSIndexSet *anIndexSet;
    if (multiSelecSegmendedControl == self.channelSeg) {
        anIndexSet = self.channelSeg.selectedSegmentIndexes;
    }else
        anIndexSet = self.weekSeg.selectedSegmentIndexes;
    
    if ([anIndexSet count] == 0) {
        [MyEUtil showMessageOn:self.view withMessage:multiSelecSegmendedControl == self.channelSeg?@"Must select at least one channel":@"Must select at least one day"];
    }
    if (self.actionType == 2) {
        [self changeBarBtnEnable];
    }
}
#pragma mark - IQActionSheetPickerView delegate methods
-(void)actionSheetPickerView:(IQActionSheetPickerView *)pickerView didSelectTitles:(NSArray *)titles{
    if (pickerView.tag == 1) {
        [self.startBtn setTitle:[titles componentsJoinedByString:@":"] forState:UIControlStateNormal];
    }else{
        [self.endBtn setTitle:[titles componentsJoinedByString:@":"] forState:UIControlStateNormal];
    }
    if (self.actionType == 2) {
        [self changeBarBtnEnable];
    }
}
#pragma mark - url delegate methods
-(void)didReceiveString:(NSString *)string loaderName:(NSString *)name userDataDictionary:(NSDictionary *)dict{
    [HUD hide:YES];
    if ([name isEqualToString:@"check"]) {
        NSLog(@"check string is %@",string);
        if (![string isEqualToString:@"fail"]) {
            SBJsonParser *parser = [[SBJsonParser alloc] init];
            NSDictionary *dict = [parser objectWithString:string];
            int isMutex = [[dict objectForKey:@"isMutex"] intValue];
            
            if(isMutex == 1){
                DXAlertView *alert = [[DXAlertView alloc] initWithTitle:@"提示" contentText:@"The light has been set dalay control, are you sure to save it?" leftButtonTitle:@"Cancel" rightButtonTitle:@"OK"];
                alert.rightBlock = ^{
                    //这里也要进行手动控制面板的刷新
                    UINavigationController *nav = self.tabBarController.childViewControllers[0];
                    MyESwitchManualControlViewController *vc = nav.childViewControllers[0];
                    vc.needRefresh = YES;
                    [self uploadInfoToServer];
                };
                alert.leftBlock = ^{
                    [self.navigationController popViewControllerAnimated:YES];
                };
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
        NSLog(@"scheduleEdit string is %@",string);
        if (self.actionType == 1) {
            if ([string length]>0) {
                self.schedule.scheduleId = _scheduleNew.scheduleId;
                self.schedule.onTime = _scheduleNew.onTime;
                self.schedule.offTime = _scheduleNew.offTime;
                _schedule.weeks = _scheduleNew.weeks;
                _schedule.channels = _scheduleNew.channels;

                MyESwitchSchedule *schedule = [[MyESwitchSchedule alloc] initWithString:string];
                _schedule.scheduleId = schedule.scheduleId;
                [self.control.SSList addObject:self.schedule];

                [self.navigationController popViewControllerAnimated:YES];
                NSLog(@"Add new period successfully");
            } else {
                [MyEUtil showMessageOn:nil withMessage:[NSString stringWithFormat:@"Falied to add new period"]];
            }
        }else{
            if([string isEqualToString:@"OK"]){
                self.schedule.scheduleId = _scheduleNew.scheduleId;
                self.schedule.onTime = _scheduleNew.onTime;
                self.schedule.offTime = _scheduleNew.offTime;
                _schedule.weeks = _scheduleNew.weeks;
                _schedule.channels = _scheduleNew.channels;
                [self.navigationController popViewControllerAnimated:YES];
                NSLog(@"Edit period successfully");
            }
            else {
                [MyEUtil showMessageOn:nil withMessage:[NSString stringWithFormat:@"Falied to edit period"]];
            }
        }
    }
}
@end
