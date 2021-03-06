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
    MBProgressHUD *HUD;
}

@end

@implementation MyEEventConditionEditViewController

#pragma mark - lifecircle methods
- (void)viewDidLoad
{
    [super viewDidLoad];
    _newCustom = [self.conditionCustom copy];
    self.navigationItem.title = _isAdd?@"New Condition":@"Condition Edit";
    NSLog(@"%@",_newCustom);
    for (UIButton *btn in self.indoorView.subviews) {
        if ([btn isKindOfClass:[UIButton class]]) {
            [btn setBackgroundImage:[[UIImage imageNamed:@"detailBtn"] stretchableImageWithLeftCapWidth:0 topCapHeight:0] forState:UIControlStateNormal];
            [btn setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 30)];
        }
    }
    for (UIButton *btn in self.outdoorView.subviews) {
        if ([btn isKindOfClass:[UIButton class]]) {
            [btn setBackgroundImage:[[UIImage imageNamed:@"detailBtn"] stretchableImageWithLeftCapWidth:0 topCapHeight:0] forState:UIControlStateNormal];
            [btn setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 30)];
        }
    }
    [_conditionBtn setBackgroundImage:[[UIImage imageNamed:@"detailBtn"] stretchableImageWithLeftCapWidth:0 topCapHeight:0] forState:UIControlStateNormal];
    [_conditionBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 30)];

    /*------------初始化数组-----------------*/
    NSMutableArray *array = [NSMutableArray array];
    for (MyETerminalData *t in MainDelegate.houseData.terminals) {
        if (t.deviceType == 1) {   //这里的值应是1，表示的是红外设备
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
        [self changeTmpOrHum];
        [self setIndoorViewHidden:NO];
    }else{
        _selectedIndex1 = _newCustom.dataType - 1;
        _selectedIndex3 = _newCustom.parameterType - 1;
        if (_newCustom.dataType == 1 || _newCustom.dataType == 3) {  //说明此时是温度
            _selectedIndex4 = [_tmpArray indexOfObject:[NSString stringWithFormat:@"%i F",_newCustom.parameterValue]];
            [_valueBtn setTitle:_tmpArray[_selectedIndex4] forState:UIControlStateNormal];
            [_valueBtn1 setTitle:_tmpArray[_selectedIndex4] forState:UIControlStateNormal];
        }else{
            _selectedIndex4 = [_humArray indexOfObject:[NSString stringWithFormat:@"%i %%RH",_newCustom.parameterValue]];
            [_valueBtn setTitle:_humArray[_selectedIndex4] forState:UIControlStateNormal];
            [_valueBtn1 setTitle:_humArray[_selectedIndex4] forState:UIControlStateNormal];
        }
        if (_newCustom.dataType == 1 || _newCustom.dataType == 2) {  //这个表示的是室内
            if ([_terminals count]) {
                for (int i = 0; i < [_terminals count]; i++) {
                    MyETerminalData *t = _terminals[i];
                    if ([t.tId isEqualToString:_newCustom.tId]) {
                        NSLog(@"tid is %i",i);
                        _selectedIndex2 = i;
                        break;
                    }
                }
            }else
                _selectedIndex2 = 0;
            [self setIndoorViewHidden:NO];
        }else{
            [self setIndoorViewHidden:YES];
//            _isShow = YES;
////            [self refreshUIWithBool:NO];
//            [self performSelector:@selector(refreshUIWithBool:) withObject:nil afterDelay:1.0f];
////            dispatch_async(dispatch_get_main_queue(), ^{
////                [self refreshUIWithBool:NO];
////            });
        }
    }
    [_conditionBtn setTitle:_conditonArray[_selectedIndex1] forState:UIControlStateNormal];
    if ([_terminals count]) {
        MyETerminalData *terminal = _terminals[_selectedIndex2];
        [_terminalBtn setTitle:terminal.tName forState:UIControlStateNormal];
        _newCustom.tId = terminal.tId;
    }else
        [_terminalBtn setTitle:@"No terminal" forState:UIControlStateNormal];
    [_relationBtn setTitle:_relationArray[_selectedIndex3] forState:UIControlStateNormal];
    [_relationBtn1 setTitle:_relationArray[_selectedIndex3] forState:UIControlStateNormal];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - IBAction methods
- (IBAction)save:(UIBarButtonItem *)sender {
    NSLog(@"%@",_newCustom);
    MyEDataLoader *loader = [[MyEDataLoader alloc] initLoadingWithURLString:[NSString stringWithFormat:@"%@?houseId=%i&sceneId=%i&tid=%@&id=%i&dataType=%i&parameterType=%i&parameterValue=%i&action=%i",GetRequst(URL_FOR_SCENES_CONDITION_CUSTOM),MainDelegate.houseData.houseId,self.eventInfo.sceneId,(_newCustom.dataType == 1 || _newCustom.dataType == 2)?_newCustom.tId:@"",_newCustom.conditionId,_newCustom.dataType,_newCustom.parameterType,_newCustom.parameterValue,_isAdd?1:2] postData:nil delegate:self loaderName:@"condition" userDataDictionary:nil];
    NSLog(@"loader name is %@",loader.name);
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
            picker = [[MYEPickerView alloc] initWithView:self.view andTag:sender.tag title:@"Temperature" dataSource:_tmpArray andSelectRow:_selectedIndex4];
        }else
            picker = [[MYEPickerView alloc] initWithView:self.view andTag:sender.tag title:@"humidity" dataSource:_humArray andSelectRow:_selectedIndex4];
    }
    picker.delegate = self;
    [picker showInView:self.view];
}
#pragma mark - private methods
-(void)setIndoorViewHidden:(BOOL)hidden{
    self.indoorView.hidden = hidden;
    self.outdoorView.hidden = !hidden;
}
-(void)refreshUIWithBool:(BOOL)yes{
    if (yes) { //yes值为YES，则是要显示view,NO就是不显示
        if (_isShow) {
            return;
        }
        _isShow = YES;
//        [UIView beginAnimations:@"" context:NULL];
//        [UIView setAnimationDuration:0.3];
//        CGRect newFrame = self.mainView.frame;
//        newFrame.origin.y += 45;
//        self.mainView.frame = newFrame;
//        _isShow = YES;
//        [UIView commitAnimations];
//        [UIView animateWithDuration:0.3 animations:^{
//            NSLog(@"%@",NSStringFromCGRect(self.mainView.frame));
//            CGRect newFrame = self.mainView.frame;
//            newFrame.origin.y += 45;
//            self.mainView.frame = newFrame;
//            NSLog(@"%@",NSStringFromCGRect(self.mainView.frame));
//            [self.view performSelectorOnMainThread:@selector(setNeedsDisplay) withObject:nil waitUntilDone:NO];
//        }completion:^(BOOL com){
//            _isShow = YES;
//        }];
    }else{
//        if (!_isShow) {
//            return;
//        }
        [UIView beginAnimations:@"" context:NULL];
        [UIView setAnimationDuration:0.3];
//        CGRect newFrame = self.mainView.frame;
//        newFrame.origin.y -= 45;
//        self.mainView.frame = newFrame;
        _isShow = NO;
        [UIView commitAnimations];
        
//        [UIView animateWithDuration:0.3 animations:^{
//            NSLog(@"%@",NSStringFromCGRect(self.mainView.frame));
//            CGRect newFrame = self.mainView.frame;
//            newFrame.origin.y -= 45;
//            self.mainView.frame = newFrame;
//            NSLog(@"%@",NSStringFromCGRect(self.mainView.frame));
//            [self.view performSelectorOnMainThread:@selector(setNeedsDisplay) withObject:nil waitUntilDone:NO];
//        }completion:^(BOOL com){
//            _isShow = NO;
//        }];
    }
}
-(void)changeTmpOrHum{
    //这里还有其他的比较方法
    if ([_conditionBtn.currentTitle rangeOfString:@"Temperature"].location != NSNotFound) {
        _selectedIndex4 = 20;
        [_valueBtn setTitle:_tmpArray[_selectedIndex4] forState:UIControlStateNormal];
        [_valueBtn1 setTitle:_tmpArray[_selectedIndex4] forState:UIControlStateNormal];
    }else{
        _selectedIndex4 = 50;
        [_valueBtn setTitle:_humArray[_selectedIndex4] forState:UIControlStateNormal];
        [_valueBtn1 setTitle:_humArray[_selectedIndex4] forState:UIControlStateNormal];
    }
}
#pragma mark - MYEPickerView delegate methods
-(void)MYEPickerView:(UIView *)pickerView didSelectTitles:(NSString *)title andRow:(NSInteger)row{
    if (pickerView.tag == 100) {
        _selectedIndex1 = row;
        [_conditionBtn setTitle:title forState:UIControlStateNormal];
        _newCustom.dataType = row + 1;
        if (_newCustom.dataType == 1 || _newCustom.dataType == 2) {
            [self setIndoorViewHidden:NO];
        }else{
            [self setIndoorViewHidden:YES];
        }
        [self changeTmpOrHum];
    }else if (pickerView.tag == 101){
        _selectedIndex2 = row;
        [_terminalBtn setTitle:title forState:UIControlStateNormal];
        MyETerminalData *t = _terminals[row];
        _newCustom.tId = t.tId;
    }else if (pickerView.tag == 102){
        _selectedIndex3 = row;
        [_relationBtn setTitle:title forState:UIControlStateNormal];
        [_relationBtn1 setTitle:title forState:UIControlStateNormal];
        _newCustom.parameterType = row + 1;
    }else{
        _selectedIndex4 = row;
        [_valueBtn setTitle:title forState:UIControlStateNormal];
        [_valueBtn1 setTitle:title forState:UIControlStateNormal];
        if (_newCustom.dataType == 1 || _newCustom.dataType == 3) {  //表示的是温度
            _newCustom.parameterValue = row + 30;
        }else
            _newCustom.parameterValue = row;
    }
}
#pragma mark - URL delegate methods
-(void)didReceiveString:(NSString *)string loaderName:(NSString *)name userDataDictionary:(NSDictionary *)dict{
    NSLog(@"receive string is %@",string);
    [HUD hide:YES];
    if (![string isEqualToString:@"fail"]) {
        if (self.isAdd) {
            NSDictionary *dic = [string JSONValue];
            _newCustom.conditionId = [dic[@"id"] intValue];
            [self.eventDetail.customConditions addObject:_newCustom];
        }else{
            if ([self.eventDetail.customConditions containsObject:self.conditionCustom]) {
                NSInteger i = [self.eventDetail.customConditions indexOfObject:self.conditionCustom];
                [self.eventDetail.customConditions removeObjectAtIndex:i];
                [self.eventDetail.customConditions insertObject:_newCustom atIndex:i];
            }
        }
        [self.navigationController popViewControllerAnimated:YES];
    }else
        [SVProgressHUD showErrorWithStatus:@"fail"];
}
-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error loaderName:(NSString *)name{
    [HUD hide:YES];
    [SVProgressHUD showErrorWithStatus:@"Connection Fail"];
}
@end
