//
//  MyEEventDeviceEditViewController.m
//  MyE
//
//  Created by 翟强 on 14-5-14.
//  Copyright (c) 2014年 MyEnergy Domain. All rights reserved.
//

#import "MyEEventDeviceEditViewController.h"
#import "MyEEventAddOrEditViewController.h"

@interface MyEEventDeviceEditViewController (){
    NSArray *_mainArray;
    MyEEventDeviceAdd *_deviceType;
    MyEInstruction *_instruction;
    MyEEventDeviceInstructions *_instructions;
    NSInteger _selectIndex;
    MBProgressHUD *HUD;
}

@end

@implementation MyEEventDeviceEditViewController

#pragma mark - life circle methods
- (void)viewDidLoad
{
    [super viewDidLoad];
    //    _instructions = [[MyEEventDeviceInstructions alloc] init];
    //    _instruction = [[MyEInstruction alloc] init];
    if (self.isAdd) {
        _mainArray = [self.eventDetail getTypeDevices];
        _deviceType = _mainArray[0];
        _device = _deviceType.devices[0];
    }else{
        for (MyEEventDeviceAdd *add in [self.eventDetail getDeviceType]) {
            if (_device.typeId == add.typeId) {
                _deviceType = add;
            }
        }
        self.typeBtn.enabled = NO;
        self.deviceBtn.enabled = NO;
    }
    [self.typeBtn setTitle:_deviceType.typeName forState:UIControlStateNormal];
    [self.deviceBtn setTitle:_device.name forState:UIControlStateNormal];
    self.navigationItem.title = _isAdd?@"Add Device":_device.name;
    //    [self refreshUI];
    [self checkIfNeedDownloadData];
    
    for (UIButton *btn in self.btns) {
        [btn setBackgroundImage:[[UIImage imageNamed:@"detailBtn"] stretchableImageWithLeftCapWidth:0 topCapHeight:0] forState:UIControlStateNormal];
        [btn setBackgroundImage:[[UIImage imageNamed:@"detailBtn-ios6"] stretchableImageWithLeftCapWidth:0 topCapHeight:0] forState:UIControlStateDisabled];
        [btn setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 30)];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}
#pragma mark - IBAction methods
- (IBAction)save:(UIBarButtonItem *)sender {
    UIView *view = (UIView *)[self.view viewWithTag:201];
    UIButton *btn = (UIButton *)[view viewWithTag:103];
    if ([btn.currentTitle isEqualToString:@"No Instruction"]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Alert" message:@"This device has no instruction" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        return;
    }
    NSLog(@"%i %i %i\n %i type:%i \n%i \n%@\n %i %i %i \n%@",MainDelegate.houseData.houseId,_device.sceneSubId,_eventInfo.sceneId,_device.deviceId,_deviceType.typeId == 0?1:2,_instruction.instructionId,_instructions.channel,_instructions.controlMode,_instructions.point,_instructions.fan,_isAdd?@"add":@"edit");
    NSString *subString = [NSString stringWithFormat:@"%@?houseId=%i&sceneSubId=%i&sceneId=%i&deviceId=%i&type=%i&action=%@&",GetRequst(URL_FOR_SCENES_SAVE_SCENE_DEVICE),MainDelegate.houseData.houseId,_device.sceneSubId,self.eventInfo.sceneId,_device.deviceId,_deviceType.typeId == 0?1:2,_isAdd?@"addSceneSub":@"editSceneSub"];
    NSString *tailString = nil;
    if (_deviceType.typeId == 0) { //温控器
        tailString = [subString stringByAppendingString:[NSString stringWithFormat:@"controlMode=%i&point=%i&fan=%i",_instructions.controlMode,_instructions.point,_instructions.fan]];
    }else if (_deviceType.typeId == 7 || _deviceType.typeId == 8){  //开关或者是通用控制器
        NSMutableString *string = [NSMutableString stringWithString:_instructions.channel];
        [string replaceOccurrencesOfString:@"2" withString:@"0" options:NSCaseInsensitiveSearch range:NSMakeRange(0, string.length)];
        tailString = [subString stringByAppendingString:[NSString stringWithFormat:@"channel=%@",string]];
    }else if (_deviceType.typeId == 1 && _device.isSystemDefined == 1){
        tailString = [subString stringByAppendingString:[NSString stringWithFormat:@"controlMode=%i&point=%i&fan=%i&instructionId=%i",_instructions.controlMode,_instructions.point,_instructions.fan,_instructions.controlStatus]];
    }else
        tailString = [subString stringByAppendingString:[NSString stringWithFormat:@"instructionId=%i",_instruction.instructionId]];
    [self updateDeviceToServerWithString:tailString andName:@"device"];
}
- (IBAction)btnPressed:(UIButton *)sender {
    NSMutableArray *array = [NSMutableArray array];
    NSString *title = nil;
    if (sender.tag == 101) {
        title = @"Device Type";
        for (MyEEventDeviceAdd *add in _mainArray) {
            [array addObject:add.typeName];
        }
    }else if (sender.tag == 102){
        title = @"Device";
        for (MyEEventDevice *d in _deviceType.devices) {
            [array addObject:d.name];
        }
        /*-----------插座或红外设备---------------*/
    }else if (sender.tag == 103){
        title = @"Control";
        if (_deviceType.typeId == 6) {
            array = [[_instructions controlStatusArray] mutableCopy];
        }else{
            if ([_instructions.instructions count]) {
                for (MyEInstruction *i in _instructions.instructions) {
                    [array addObject:i.name];
                }
            }
        }
        /*---------开关或通用控制器----------*/
    }else if (sender.tag == 104){
        title = @"SYS Mode";
        if (_deviceType.typeId == 1) {
            array = [[_instructions ACControlMode] mutableCopy];
        }else
            array = [[_instructions controlModeArray] mutableCopy];
    }else if (sender.tag == 105){
        title = @"Fan";
        if (_deviceType.typeId == 1) {
            array = [[_instructions ACFanMode] mutableCopy];
        }else
            array = [[_instructions fanMode] mutableCopy];
    }else{
        title = @"Point";
        if (_deviceType.typeId == 1) {
            array = [[_instructions ACPointArray] mutableCopy];
        }else
            array = [[_instructions pointArray] mutableCopy];
    }
    if (![array count]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Alert" message:@"This device has no instruction" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        return;
    }
    //这里是找到选定的行数
    if ([array containsObject:sender.currentTitle]) {
        _selectIndex = [array indexOfObject:sender.currentTitle];
    }else
        _selectIndex = 0;  //这里是保护措施
    MYEPickerView *picker = [[MYEPickerView alloc] initWithView:self.view andTag:sender.tag title:title dataSource:array andSelectRow:_selectIndex];
    picker.delegate = self;
    [picker showInView:self.view];
}

#pragma mark - private methods
-(void)refreshUI{
    //注意这里的编号tag值
    UIView *view = nil;
    if (_deviceType.typeId == 0 || (_deviceType.typeId == 1 && _device.isSystemDefined == 1)) {
        view = (UIView *)[self.view viewWithTag:203];
        UIButton *mode = (UIButton *)[view viewWithTag:104];
        UIButton *fan = (UIButton *)[view viewWithTag:105];
        UIButton *point = (UIButton *)[view viewWithTag:106];
        if (_isAdd) {
            if (_deviceType.typeId == 1) {
                [mode setTitle:@"Auto" forState:UIControlStateNormal];
                [fan setTitle:@"Auto" forState:UIControlStateNormal];
                [point setTitle:@"25 ℃" forState:UIControlStateNormal];
                _instructions.controlMode = 0;
                _instructions.fan = 1;
                _instructions.point = 25;
                _instructions.controlStatus = 1;
            }else{
                [mode setTitle:@"Heat" forState:UIControlStateNormal];
                [fan setTitle:@"Auto" forState:UIControlStateNormal];
                [point setTitle:@"55 F" forState:UIControlStateNormal];
            }
        }else{
            if (_deviceType.typeId == 1) {
                if (_instructions.controlMode <= 0 || _instructions.controlMode >5) {
                    _instructions.controlMode = 1;
                }
                if (_instructions.point <18 || _instructions.point > 30) {
                    _instructions.point = 25;
                }
                if (_instructions.fan < 0 || _instructions.fan > 3) {
                    _instructions.fan = 0;
                }
                [mode setTitle:[_instructions ACControlMode][_instructions.controlMode - 1] forState:UIControlStateNormal];
                [fan setTitle:[_instructions ACFanMode][_instructions.fan] forState:UIControlStateNormal];
                [point setTitle:[NSString stringWithFormat:@"%i ℃",_instructions.point] forState:UIControlStateNormal];
                if (_instructions.controlStatus == 0) {
                    self.setpointView.hidden = YES;
                    self.fanBtn.hidden = YES;
                    self.fanLbl.hidden = YES;
                    [mode setTitle:@"OFF" forState:UIControlStateNormal];
                }
            }else{
                [mode setTitle:[_instructions controlModeArray][_instructions.controlMode - 1] forState:UIControlStateNormal];
                [fan setTitle:[_instructions fanMode][_instructions.fan] forState:UIControlStateNormal];
                [point setTitle:[NSString stringWithFormat:@"%i F",_instructions.point] forState:UIControlStateNormal];
                if (_instructions.controlMode == 5) {
                    self.setpointView.hidden = YES;
                }
            }
        }
    }else if (_deviceType.typeId == 7 || _deviceType.typeId == 8){
        view = (UIView *)[self.view viewWithTag:202];
        self.tableView.delegate = self;
        self.tableView.dataSource = self;
        UIView *view = [[UIView alloc] init];
        view.backgroundColor = [UIColor clearColor];
        self.tableView.tableFooterView = view;
        if (!_isAdd) {
            _instructions.channel = [[_device.instructionName componentsSeparatedByString:@","] componentsJoinedByString:@""];
        }
        [self.tableView reloadData];
    }else{
        view = (UIView *)[self.view viewWithTag:201];
        UIButton *btn = (UIButton *)[view viewWithTag:103];
        if (_deviceType.typeId == 6) {  //插座
            if (_isAdd) {
                _instruction.instructionId = 0;
                [btn setTitle:@"OFF" forState:UIControlStateNormal];
            }else{
                if ([_device.instructionName isEqualToString:@"ON"]) {
                    _instruction.instructionId = 1;
                }else
                    _instruction.instructionId = 0;
                [btn setTitle:_device.instructionName forState:UIControlStateNormal];
//                _instruction.instructionId = [_device.instructionName intValue];
//                [btn setTitle:_instruction.instructionId == 0?@"OFF":@"ON" forState:UIControlStateNormal];
            }
        }else{
            if (_isAdd) {
                if ([_instructions.instructions count]) {
                    _instruction = _instructions.instructions[0];
                    [btn setTitle:_instruction.name forState:UIControlStateNormal];
                }else{
                    [btn setTitle:@"No Instruction" forState:UIControlStateNormal];
                }
            }else{
                if ([_instructions.instructions count]) {
                    BOOL hasThis = NO;
                    for (MyEInstruction *instruction in _instructions.instructions) {
                        if (_deviceType.typeId == 1) {
                            if (instruction.instructionId == _instructions.controlStatus) {
                                _instruction = instruction;
                                hasThis = YES;
                                break;
                            }
                        }else{
                            if ([instruction.name isEqualToString:_device.instructionName]) {
                                _instruction = instruction;  //这里也要找到这个instruction
                                hasThis = YES;
                                break;
                            }
                        }
                    }
                    if (hasThis) {
                        [btn setTitle:_instruction.name forState:UIControlStateNormal];

//                        [btn setTitle:_device.instructionName forState:UIControlStateNormal];
                    }else{
                        _instruction = _instructions.instructions[0];
                        [btn setTitle:_instruction.name forState:UIControlStateNormal];
                    }
                }else
                    [btn setTitle:@"No Instruction" forState:UIControlStateNormal];
            }
        }
    }
    [self.view bringSubviewToFront:view];
}
-(void)checkIfNeedDownloadData{
    //0,1 编辑时需下载
    //2，3，4，5 什么时候都需要下载
    //6不用
    //7，8编辑时不用，添加时需要
    if ((_deviceType.typeId >= 1 && _deviceType.typeId <= 5) ||
        _deviceType.typeId == 8 ||
        (_deviceType.typeId == 0 && !_isAdd)){
        [self downloadInstructionsWithDeviceId:_device.deviceId];
    }else{
        _instructions = [[MyEEventDeviceInstructions alloc] init];
        _instruction = [[MyEInstruction alloc] init];
        [self refreshUI];
    }
}
-(void)changeStatus:(UISwitch *)sender{
    CGPoint hit = [sender convertPoint:CGPointZero toView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:hit];
    NSLog(@"select row is %i",indexPath.row);
    NSMutableString *string = [NSMutableString stringWithString:_instructions.channel];
    [string replaceCharactersInRange:NSMakeRange(indexPath.row, 1) withString:sender.isOn?@"1":@"0"];
    [string replaceOccurrencesOfString:@"2" withString:@"0" options:NSCaseInsensitiveSearch range:NSMakeRange(0, string.length)];
    _instructions.channel = string;
}
#pragma mark - UITableView dataSource methods
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (_deviceType.typeId == 7) {
        return 6;
    }else
        return [_instructions.channel length];
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    UILabel *label = (UILabel *)[cell.contentView viewWithTag:100];
    UISwitch *status = (UISwitch *)[cell.contentView viewWithTag:101];
    UIView *view = (UIView *)[cell.contentView viewWithTag:1024];
    view.layer.cornerRadius = 4;
    if (_deviceType.typeId == 8) {
        label.text = [NSString stringWithFormat:@"Light %i",indexPath.row + 1];
    }else
        label.text = [NSString stringWithFormat:@"Channel %i",indexPath.row + 1];
    NSString *string = nil;
    if (_instructions.channel == nil || [_instructions.channel isEqualToString:@""]) {
        _instructions.channel = @"111111";
    }
    string = [_instructions.channel substringWithRange:NSMakeRange(indexPath.row, 1)];
    [status setOn:[string isEqualToString:@"1"] animated:YES];
    status.enabled = NO;
    if (string.intValue == 2 && _deviceType.typeId == 8) {
    }else{
        status.enabled = YES;
        [status addTarget:self action:@selector(changeStatus:) forControlEvents:UIControlEventValueChanged];
    }
    return cell;
}

#pragma mark - URL methods
-(void)updateDeviceToServerWithString:(NSString *)url andName:(NSString *)name{
    if (HUD == nil) {
        HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    }else
        [HUD show:YES];
    MyEDataLoader *loader = [[MyEDataLoader alloc] initLoadingWithURLString:url postData:nil delegate:self loaderName:name userDataDictionary:nil];
    NSLog(@"%@",loader.name);
}
-(void)downloadInstructionsWithDeviceId:(NSInteger)deviceId{
    if (HUD == nil) {
        HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    }else
        [HUD show:YES];
    [HUD show:YES];
    MyEDataLoader *loader = [[MyEDataLoader alloc] initLoadingWithURLString:[NSString stringWithFormat:@"%@?houseId=%i&sceneSubId=%i&deviceId=%i&type=%i&action=%@",GetRequst(URL_FOR_SCENES_FIND_DEVICE),MainDelegate.houseData.houseId,_device.sceneSubId,deviceId,_deviceType.typeId==0?1:2,_isAdd?@"addSceneSub":@"editSceneSub"] postData:nil delegate:self loaderName:@"instruction" userDataDictionary:nil];
    NSLog(@"loader name is %@",loader.name);
}
#pragma mark - URL Delegate methods
-(void)didReceiveString:(NSString *)string loaderName:(NSString *)name userDataDictionary:(NSDictionary *)dict{
    NSLog(@"receive string is %@",string);
    [HUD hide:YES];
    if ([name isEqualToString:@"instruction"]) {
        _instructions = [[MyEEventDeviceInstructions alloc] initWithJsonString:string];
        [self refreshUI];
        NSLog(@"%@",_instructions.instructions);
    }
    if ([name isEqualToString:@"device"]) {
        if ([string isEqualToString:@"OK"]) {
            MyEEventAddOrEditViewController *vc = self.navigationController.childViewControllers[1];
            vc.needRefresh = YES;
            [self.navigationController popViewControllerAnimated:YES];
        }else
            [SVProgressHUD showErrorWithStatus:@"fail"];
        //        if (_deviceType.typeId == 0) {
        //            _device.controlMode = _instructions.controlMode;
        //            _device.point = _instructions.point;
        //        }else if (_deviceType.typeId == 7 || _deviceType.typeId == 8){
        //            _device.instructionName = _instructions.channel;
        //        }else
        //            _device.instructionName = _instruction.name;
        //        if (_isAdd) {
        //            [self.eventDetail.devices addObject:_device];
        //            MyEEventAddOrEditViewController *vc = self.navigationController.childViewControllers[1];
        //            vc.needRefresh = YES;
        //        }
    }
}
-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error loaderName:(NSString *)name{
    [HUD hide:YES];
    [SVProgressHUD showErrorWithStatus:@"Connection Fail"];
}

#pragma mark - MYEPickerView delegate methods
-(void)MYEPickerView:(UIView *)pickerView didSelectTitles:(NSString *)title andRow:(NSInteger)row{
    UIButton *btn = (UIButton *)[self.view viewWithTag:pickerView.tag];
    [btn setTitle:title forState:UIControlStateNormal];
    if (pickerView.tag == 101) {   //设备类型
        _deviceType = _mainArray[row];
        _device = _deviceType.devices[0];
        [self.deviceBtn setTitle:_device.name forState:UIControlStateNormal];
        [self refreshUI];
        [self checkIfNeedDownloadData];
    }else if(pickerView.tag == 102){  //设备
        _device = _deviceType.devices[row];
        [self downloadInstructionsWithDeviceId:_device.deviceId];
    }else if (pickerView.tag == 103){  //指令
        if (_deviceType.typeId == 6) {
            _instruction.instructionId = row;
        }else
            _instruction = _instructions.instructions[row];
    }else if (pickerView.tag == 104){
        if (_deviceType.typeId == 1) {
            if ([title isEqualToString:@"OFF"]) {
                _instructions.controlStatus = 0;
                _instructions.controlMode = 1;
                self.setpointView.hidden = YES;
                self.fanLbl.hidden = YES;
                self.fanBtn.hidden = YES;
            }else{
                _instructions.controlStatus = 1;
                _instructions.controlMode = row + 1;
                self.setpointView.hidden = NO;
                self.fanLbl.hidden = NO;
                self.fanBtn.hidden = NO;
            }
        }else{
            _instructions.controlMode = row +1;
            if (_instructions.controlMode == 5) {
                self.setpointView.hidden = YES;
            }else
                self.setpointView.hidden = NO;
        }
    }else if (pickerView.tag == 105){
        _instructions.fan = row;
    }else{
        if (_deviceType.typeId == 1) {
            _instructions.point = row + 18;
        }else
            _instructions.point = row + 55;
    }
}
@end
