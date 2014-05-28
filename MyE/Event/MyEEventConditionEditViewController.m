//
//  MyEEventConditionEditViewController.m
//  MyE
//
//  Created by 翟强 on 14-5-14.
//  Copyright (c) 2014年 MyEnergy Domain. All rights reserved.
//

#import "MyEEventConditionEditViewController.h"

@interface MyEEventConditionEditViewController (){
    NSArray *_terminals,*_terminalNames;
    NSArray *_conditonArray;
    NSArray *_relationArray;
    NSArray *_tmpArray;  //温度数据
    NSArray *_humArray;   //湿度数据
    NSInteger _selectedIndex1,_selectedIndex2,_selectedIndex3;
    NSInteger _selectedIndex4,_selectedIndex5;
    BOOL _isShow; // 用于移动view
    MyEEventConditionCustom *_newCustom;
}

@end

@implementation MyEEventConditionEditViewController

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
    _newCustom = [self.conditionCustom copy];
    _isShow = YES;
    /*------------初始化数组-----------------*/
    NSMutableArray *array = [NSMutableArray array];
    for (MyETerminalData *t in MainDelegate.houseData.terminals) {
        if (t.deviceType == 2) {
            [array addObject:t];
        }
    }
    _terminals = array;
    
    array = [NSMutableArray array];
    for (MyETerminalData *t in _terminals) {
        [array addObject:t.tName];
    }
    _terminalNames = array;
    
    if (![_terminals count]) {
        _conditonArray = @[@"Outdoor Temperature", @"Outdoor Humidty"];
        [self refreshUIWithBool:NO];
    }else{
        _conditonArray = [self.conditionCustom dataTypeArray];
    }
    _relationArray = [self.conditionCustom conditionArray];
    array = [NSMutableArray array];
    for (int i = 30; i < 101; i++) {
        [array addObject:[NSString stringWithFormat:@"%i F",i]];
    }
    _tmpArray = array;
    
    array = [NSMutableArray array];
    for (int i = 0; i < 101; i++) {
        [array addObject:[NSString stringWithFormat:@"%i %%RH",i]];
    }
    _humArray = array;
    
    /*---------------初始化UI----------------------*/
    if (self.isAdd) {
        _selectedIndex1 = 0;
        _selectedIndex2 = 0;
        _selectedIndex3 = 0;
        if (_newCustom.dataType == 1 || _newCustom.dataType == 3) {
            _selectedIndex4 = 20;
        }else
            _selectedIndex4 = 50;
    }else{
        _selectedIndex1 = _newCustom.dataType - 1;
        _selectedIndex3 = _newCustom.parameterType - 1;
        if (_newCustom.dataType == 1 || _newCustom.dataType == 3) {  //说明此时是温度
            if ([_terminals count]) {
                for (int i = 0; i < [_terminals count]; i++) {
                    MyETerminalData *t = _terminals[i];
                    if ([t.tId isEqualToString:_newCustom.tId]) {
                        _selectedIndex2 = i;
                        break;
                    }
                }
            }else
                _selectedIndex2 = 0;
            _selectedIndex4 = [_tmpArray indexOfObject:[NSString stringWithFormat:@"%i F",_newCustom.parameterValue]];
        }else
            _selectedIndex4 = [_humArray indexOfObject:[NSString stringWithFormat:@"%i %%RH",_newCustom.parameterValue]];
    }
    [_conditionBtn setTitle:_conditonArray[_selectedIndex1] forState:UIControlStateNormal];
    MyETerminalData *termina = _terminals[_selectedIndex2];
    [_terminalBtn setTitle:termina.tName forState:UIControlStateNormal];
    [_relationBtn setTitle:_relationArray[_selectedIndex3] forState:UIControlStateNormal];
    [self changeTmpOrHumWithString:_conditonArray[_selectedIndex1]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - IBAction methods
- (IBAction)save:(UIBarButtonItem *)sender {
    NSLog(@"%@",_newCustom);
}
- (IBAction)changeStatues:(UIButton *)sender {
    MYEPickerView *picker = nil;
    if (sender.tag == 100) {
        picker = [[MYEPickerView alloc] initWithView:self.view andTag:sender.tag title:@"Condition" dataSource:_conditonArray andSelectRow:_selectedIndex1];
    }else if (sender.tag == 101){
        picker = [[MYEPickerView alloc] initWithView:self.view andTag:sender.tag title:@"Smart Remote" dataSource:_terminalNames andSelectRow:_selectedIndex2];
    }else if (sender.tag == 102){
        picker = [[MYEPickerView alloc] initWithView:self.view andTag:sender.tag title:@"Comparison" dataSource:_relationArray andSelectRow:_selectedIndex3];
    }else{
        if ([_conditionBtn.currentTitle rangeOfString:@"Temperature"].location != NSNotFound) {
            picker = [[MYEPickerView alloc] initWithView:self.view andTag:sender.tag title:@"Temperature" dataSource:_tmpArray andSelectRow:_selectedIndex4>70?20:_selectedIndex4];
        }else
            picker = [[MYEPickerView alloc] initWithView:self.view andTag:sender.tag title:@"humidity" dataSource:_humArray andSelectRow:_selectedIndex4];
    }
    picker.delegate = self;
    [picker showInView:self.view];
}
#pragma mark - private methods
-(void)refreshUIWithBool:(BOOL)yes{
    if (yes) {
        if (_isShow) {
            return;
        }
        [UIView animateWithDuration:0.3 animations:^{
            CGRect newFrame = self.mainView.frame;
            newFrame.origin.y += 35;
            self.mainView.frame = newFrame;
        }completion:^(BOOL finish){
            _isShow = YES;
        }];
    }else{
        if (!_isShow) {
            return;
        }
        [UIView animateWithDuration:0.3 animations:^{
            CGRect newFrame = self.mainView.frame;
            newFrame.origin.y -= 35;
            self.mainView.frame = newFrame;
        }completion:^(BOOL finish){
            _isShow = NO;
        }];
    }
}
-(void)changeTmpOrHumWithString:(NSString *)title{
    if ([title rangeOfString:@"Temperature"].location != NSNotFound) {
        _selectedIndex4 = 20;
        [_valueBtn setTitle:_tmpArray[_selectedIndex4] forState:UIControlStateNormal];
    }else{
        _selectedIndex4 = 50;
        [_valueBtn setTitle:_humArray[_selectedIndex4] forState:UIControlStateNormal];
    }
}
#pragma mark - MYEPickerView delegate methods
-(void)MYEPickerView:(UIView *)pickerView didSelectTitles:(NSString *)title andRow:(NSInteger)row{
    if (pickerView.tag == 100) {
        _selectedIndex1 = row;
        [_conditionBtn setTitle:title forState:UIControlStateNormal];
        _newCustom.dataType = row + 1;
        if (_newCustom.dataType == 1 || _newCustom.dataType == 2) {
            [self refreshUIWithBool:YES];
        }else
            [self refreshUIWithBool:NO];
    }else if (pickerView.tag == 101){
        _selectedIndex2 = row;
        [_terminalBtn setTitle:title forState:UIControlStateNormal];
        MyETerminalData *t = _terminals[row];
        _newCustom.tId = t.tId;
    }else if (pickerView.tag == 102){
        _selectedIndex3 = row;
        [_relationBtn setTitle:title forState:UIControlStateNormal];
        _newCustom.parameterType = row + 1;
    }else{
        _selectedIndex4 = row;
        [_valueBtn setTitle:title forState:UIControlStateNormal];
        if (_newCustom.dataType == 1 || _newCustom.dataType == 3) {  //表示的是温度
            _newCustom.parameterValue = row + 30;
        }else
            _newCustom.parameterValue = row + 1;
    }
}
@end
