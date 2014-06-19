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
    _instructions = [[MyEEventDeviceInstructions alloc] init];
    _instruction = [[MyEInstruction alloc] init];
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
    [self refreshUI];
    [self checkIfNeedDownloadData];
    
    NSString *imgName = IS_IOS6?@"detailBtn-ios6":@"detailBtn";
    for (UIButton *btn in self.btns) {
        [btn setBackgroundImage:[[UIImage imageNamed:imgName] stretchableImageWithLeftCapWidth:0 topCapHeight:0] forState:UIControlStateNormal];
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
        tailString = [subString stringByAppendingString:[NSString stringWithFormat:@"channel=%@",_instructions.channel]];
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
        array = [[_instructions controlModeArray] mutableCopy];
    }else if (sender.tag == 105){
        title = @"Fan";
        array = [[_instructions fanMode] mutableCopy];
    }else{
        title = @"Point";
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
    if (_deviceType.typeId == 0) {
        view = (UIView *)[self.view viewWithTag:203];
        UIButton *mode = (UIButton *)[view viewWithTag:104];
        UIButton *fan = (UIButton *)[view viewWithTag:105];
        UIButton *point = (UIButton *)[view viewWithTag:106];
        if (_isAdd) {
            [mode setTitle:@"Heat" forState:UIControlStateNormal];
            [fan setTitle:@"Auto" forState:UIControlStateNormal];
            [point setTitle:@"55 F" forState:UIControlStateNormal];
        }else{
            [mode setTitle:[_instructions controlModeArray][_instructions.controlMode - 1] forState:UIControlStateNormal];
            [fan setTitle:[_instructions fanMode][_instructions.fan] forState:UIControlStateNormal];
            [point setTitle:[NSString stringWithFormat:@"%i F",_instructions.point] forState:UIControlStateNormal];
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
                _instruction.instructionId = [_device.instructionName intValue];
                [btn setTitle:_instruction.instructionId == 0?@"OFF":@"ON" forState:UIControlStateNormal];
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
                    if ([instruction.name isEqualToString:_device.instructionName]) {
                        _instruction = instruction;  //这里也要找到这个instruction
                        hasThis = YES;
                    }
                }
                    if (hasThis) {
                        [btn setTitle:_device.instructionName forState:UIControlStateNormal];
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
    //0 编辑时需下载
    //2，3，4，5 什么时候都需要下载
    //6不用
    //7，8编辑时不用，添加时需要
    if ((_deviceType.typeId >= 2 && _deviceType.typeId <= 5) ||
        (_deviceType.typeId >= 7 && _isAdd) ||
        (_deviceType.typeId == 0 && !_isAdd)) {
        [self downloadInstructionsWithDeviceId:_device.deviceId];
    }
}
-(void)changeStatus:(UISwitch *)sender{
    CGPoint hit = [sender convertPoint:CGPointZero toView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:hit];
    NSLog(@"select row is %i",indexPath.row);
    NSMutableString *string = [NSMutableString stringWithString:_instructions.channel];
    [string replaceCharactersInRange:NSMakeRange(indexPath.row, 1) withString:sender.isOn?@"1":@"0"];
    _instructions.channel = string;
}
#pragma mark - UITableView dataSource methods
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [_instructions.channel length];
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    UILabel *label = (UILabel *)[cell.contentView viewWithTag:100];
    UISwitch *status = (UISwitch *)[cell.contentView viewWithTag:101];
    UIView *view = (UIView *)[cell.contentView viewWithTag:1024];
    view.layer.cornerRadius = 4;
    if (_deviceType.typeId == 8) {
        label.text = [NSString stringWithFormat:@"Switch %i",indexPath.row + 1];
    }else
        label.text = [NSString stringWithFormat:@"Channel %i",indexPath.row + 1];
    [status setOn:[[_instructions.channel substringWithRange:NSMakeRange(indexPath.row, 1)] isEqualToString:@"1"]?YES:NO animated:YES];
    [status addTarget:self action:@selector(changeStatus:) forControlEvents:UIControlEventValueChanged];
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
        _instructions.controlMode = row +1;
    }else if (pickerView.tag == 105){
        _instructions.fan = row;
    }else
        _instructions.point = row + 55;
}
@end
