//
//  MyEUCPeriodViewController.m
//  MyE
//
//  Created by 翟强 on 14-6-7.
//  Copyright (c) 2014年 MyEnergy Domain. All rights reserved.
//

#import "MyEUCPeriodViewController.h"

@interface MyEUCPeriodViewController (){
    MYEPickerView *_picker;
    NSMutableArray *_startTimeArray,*_endTimeArray;
    MyEUCPeriod *_newPeriod;
}

@end

@implementation MyEUCPeriodViewController
#pragma mark - life circle methods
- (void)viewDidLoad
{
    [super viewDidLoad];
    _newPeriod = [self.period copy];
    //更新UI
    NSString *imgName = IS_IOS6?@"detailBtn-ios6":@"detailBtn";
    [self.startTimeBtn setBackgroundImage:[[UIImage imageNamed:imgName] stretchableImageWithLeftCapWidth:0 topCapHeight:0] forState:UIControlStateNormal];
    [self.startTimeBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 30)];
    [self.endTimeBtn setBackgroundImage:[[UIImage imageNamed:imgName] stretchableImageWithLeftCapWidth:0 topCapHeight:0] forState:UIControlStateNormal];
    [self.endTimeBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 30)];
    //更改btn的title
    [self.startTimeBtn setTitle:[MyEUtil timeStringForHhid:_newPeriod.stid] forState:UIControlStateNormal];
    [self.endTimeBtn setTitle:[MyEUtil timeStringForHhid:_newPeriod.edid] forState:UIControlStateNormal];
    _startTimeArray = [NSMutableArray array];
    _endTimeArray = [NSMutableArray array];
    for (int i = 0; i < 48; i++) {
        [_startTimeArray addObject:[NSString stringWithFormat: @"%@",  [MyEUtil timeStringForHhid:i]]];
    }
    for (int i = 1; i < 49; i++) {
        [_endTimeArray addObject:[NSString stringWithFormat: @"%@",  [MyEUtil timeStringForHhid:i]]];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}
#pragma mark - IBAction methods
- (IBAction)setTimeAction:(UIButton *)sender {
    if (sender.tag == 301) {
        _picker = [[MYEPickerView alloc] initWithView:self.view andTag:sender.tag title:@"select startTime" dataSource:_startTimeArray andSelectRow:[_startTimeArray containsObject:sender.currentTitle]?[_startTimeArray indexOfObject:sender.currentTitle]:0];
    }else
        _picker = [[MYEPickerView alloc] initWithView:self.view andTag:sender.tag title:@"select endTime" dataSource:_endTimeArray andSelectRow:[_endTimeArray containsObject:sender.currentTitle]?[_endTimeArray indexOfObject:sender.currentTitle]:0];
    _picker.delegate = self;
    [_picker showInView:self.view];
}
- (IBAction)saveEdit:(UIBarButtonItem *)sender {
#warning 这里需要一个时段重合判断
    if (self.isAdd) {
        [self.schedule.periods addObject:_newPeriod];
    }else{
        if ([self.schedule.periods containsObject:self.period]) {
            NSInteger i = [self.schedule.periods indexOfObject:self.period];
            [self.schedule.periods removeObject:self.period];
            [self.schedule.periods insertObject:_newPeriod atIndex:i];
        }
    }
    [self.navigationController popViewControllerAnimated:YES];
}
#pragma mark - private methods
-(BOOL)checkIfHasOne{
    return YES;
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
    _newPeriod.stid = [MyEUtil hhidForTimeString:self.startTimeBtn.currentTitle];
    _newPeriod.edid = [MyEUtil hhidForTimeString:self.endTimeBtn.currentTitle];
}

@end
