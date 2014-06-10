//
//  MyEDeviceAddOrEditTableViewController.m
//  MyE
//
//  Created by 翟强 on 14-4-22.
//  Copyright (c) 2014年 MyEnergy Domain. All rights reserved.
//

#import "MyEDeviceAddOrEditTableViewController.h"

@interface MyEDeviceAddOrEditTableViewController ()
{
    NSMutableArray *_rooms,*_types,*_terminals,*_elcts;
    MBProgressHUD *HUD;
    MyEDevice *_newDevice;
    MYEPickerView *_pickerView;
}
@end

@implementation MyEDeviceAddOrEditTableViewController

#pragma mark - life circle methods
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (self.isAddDevice) {
        self.title = @"ADD";
        self.device = [[MyEDevice alloc] init];
        [self uploadOrDownloadInfoFromServerWithURL:[NSString stringWithFormat:@"%@?houseId=%i&action=addDevice",GetRequst(URL_FOR_FIND_DEVICE),MainDelegate.houseData.houseId] andName:@"downloadInfo"];
    }else{
        self.title = @"EDIT";
        if (self.device.typeId.intValue == 6) {  //插座
            [self uploadOrDownloadInfoFromServerWithURL:[NSString stringWithFormat:@"%@?houseId=%i&tId=%@",GetRequst(URL_FOR_SOCKET_INFO),MainDelegate.houseData.houseId,self.device.tid] andName:@"downloadOtherInfo"];
        }else if(self.device.typeId.intValue == 7 || self.device.typeId.intValue == 0){   //通用控制器或者温控器
            [self uploadOrDownloadInfoFromServerWithURL:[NSString stringWithFormat:@"%@?houseId=%i&tId=%@&deviceId=%@",GetRequst(URL_FOR_UNIVERSAL_CONTROLLER_INFO),MainDelegate.houseData.houseId,self.device.tid,self.device.deviceId] andName:@"downloadOtherInfo"];
        }else
            [self uploadOrDownloadInfoFromServerWithURL:[NSString stringWithFormat:@"%@?houseId=%i&deviceId=%@&action=editDevice",GetRequst(URL_FOR_FIND_DEVICE),MainDelegate.houseData.houseId,self.device.deviceId] andName:@"downloadInfo"];
    }
}

#pragma mark - private methods
-(void)uploadOrDownloadInfoFromServerWithURL:(NSString *)string andName:(NSString *)name{
    if (HUD == nil) {
        HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    }
    [HUD show:YES];
    MyEDataLoader *loader = [[MyEDataLoader alloc] initLoadingWithURLString:string postData:nil delegate:self loaderName:name userDataDictionary:nil];
    NSLog(@"%@",loader.name);
}
-(void)getArraysFromMainData{
    _rooms = [NSMutableArray array];
    _types = [NSMutableArray array];
    _terminals = [NSMutableArray array];
    _elcts = [NSMutableArray array];
    for (MyERoom *r in self.deviceEdit.rooms) {
        [_rooms addObject:r.roomName];
    }
    for (MyEType *t in self.deviceEdit.types) {
        [_types addObject:t.typeName];
    }
    for (MyETerminal *t in self.deviceEdit.terminals) {
        [_terminals addObject:t.terminalName];
    }
    for (int i = 1; i < 13; i++) {
        [_elcts addObject:[NSString stringWithFormat:@"%li A",(long)i]];
    }
}
-(void)refreshUI{
    self.nameTextField.text = _newDevice.deviceName;
    for (int i = 1; i < 4; i++) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
        if (self.isAddDevice) {
            switch (i) {
                case 1:
                    cell.detailTextLabel.text = _rooms[0];
                    break;
                case 2:
                    cell.detailTextLabel.text = _types[0];
                    break;
                default:
                    cell.detailTextLabel.text = _terminals[0];
                    break;
            }
        }else{
            switch (i) {
                case 1:
                    cell.detailTextLabel.text = [self.deviceEdit getRoomNameByRoomId:_newDevice.locationId.intValue];
                    break;
                case 2:
                {
                    if (self.device.typeId.intValue == 6) {
                        cell.detailTextLabel.text = @"Socket";
                    }else if(self.device.typeId.intValue == 7){
                        cell.detailTextLabel.text = @"Universal Controller";
                    }else if(self.device.typeId.intValue == 0){
                        cell.detailTextLabel.text = @"Thermostat";
                    }else{
                        MyEType *t = [self.deviceEdit getTypeByTypeId:[_newDevice.typeId intValue]];
                        cell.detailTextLabel.text = t.typeName;
                    }}
                    break;
                default:
                {
                    if (self.device.typeId.intValue == 6) {
                        cell.detailTextLabel.text = _newDevice.tid;
                    }else if(self.device.typeId.intValue == 7){
                        cell.detailTextLabel.text = _newDevice.tid;
                    }else if(self.device.typeId.intValue == 0){
                        cell.detailTextLabel.text = _newDevice.tid;
                    }else{
                        MyETerminal *t = [self.deviceEdit getTerminalByTid:_newDevice.tid];
                        cell.detailTextLabel.text = t.terminalName;}}
                    break;
            }
        }
    }
    if (self.device.typeId.intValue == 6) {
        self.nameTextField.text = _newDevice.deviceName;
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:4 inSection:0];
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%i A",_newDevice.maxCurrent];
    }
    [self.tableView reloadData];
}
-(void)doThisWhenNeedAlert{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Warning" message:@"Connect failed! You cann't add or edit device" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alert show];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}
#pragma mark - IBAction methods
- (IBAction)save:(UIBarButtonItem *)sender {
    if ([self.nameTextField.text length] < 1 || [self.nameTextField.text length] > 15) {
        [SVProgressHUD showErrorWithStatus:@"name error!"];
        return;
    }
    _newDevice.deviceName = self.nameTextField.text;
    for (int i =1; i < 4; i++) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
        NSString *str = cell.detailTextLabel.text;
        switch (i) {
            case 1:
                _newDevice.locationId = [NSString stringWithFormat:@"%li",(long)[self.deviceEdit getRoomIdByRoomName:str]];
                NSLog(@"%@",_newDevice.locationId);
                break;
            case 2:
            {MyEType *type = [self.deviceEdit getTypeByTypeName:str];
                _newDevice.typeId = [NSString stringWithFormat:@"%li",(long)type.typeId];}
                break;
            default:
            {MyETerminal *terminal = [self.deviceEdit getTerminalByTName:str];
                _newDevice.tid = terminal.tId;
            }
                break;
        }
    }
    if (self.isAddDevice) {
        SBJsonWriter *writer = [[SBJsonWriter alloc] init];
        NSString *string = [writer stringWithObject:[_newDevice jsonDevice:_newDevice]];
        NSLog(@"string is %@",string);
        [self uploadOrDownloadInfoFromServerWithURL:[NSString stringWithFormat:@"%@?houseId=%i&deviceId=%i&action=addDevice&deviceMode=%@",GetRequst(URL_FOR_SAVE_DEVICE),MainDelegate.houseData.houseId,self.isAddDevice?0:_newDevice.deviceId.intValue,string] andName:@"addOrEditDevice"];
        return;
    }
    if (self.device.typeId.intValue == 6) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:4 inSection:0];
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
        NSString *str = nil;
        if ([cell.detailTextLabel.text length] == 3) {
            str = [cell.detailTextLabel.text substringToIndex:1];
        }else
            str = [cell.detailTextLabel.text substringToIndex:2];
        [self uploadOrDownloadInfoFromServerWithURL:[NSString stringWithFormat:@"%@?houseId=%i&tId=%@&aliasName=%@&locationId=%@&maximalCurrent=%@",GetRequst(URL_FOR_SOCKET_SAVEPLUG),MainDelegate.houseData.houseId,self.device.tid,_newDevice.deviceName,_newDevice.locationId,str] andName:@"otherEdit"];
    }else if(self.device.typeId.intValue == 7 || self.device.typeId.intValue == 0){
        [self uploadOrDownloadInfoFromServerWithURL:[NSString stringWithFormat:@"%@?houseId=%i&tId=%@&deviceId=%@&name=%@&locationId=%@",GetRequst(URL_FOR_UNIVERSAL_CONTROLLER_INFO_SAVE),MainDelegate.houseData.houseId,self.device.tid,self.device.deviceId,_newDevice.deviceName,_newDevice.locationId] andName:@"otherEdit"];
    }else{
        SBJsonWriter *writer = [[SBJsonWriter alloc] init];
        NSString *string = [writer stringWithObject:[_newDevice jsonDevice:_newDevice]];
        NSLog(@"string is %@",string);
        [self uploadOrDownloadInfoFromServerWithURL:[NSString stringWithFormat:@"%@?houseId=%i&deviceId=%i&action=%@&deviceMode=%@",GetRequst(URL_FOR_SAVE_DEVICE),MainDelegate.houseData.houseId,self.isAddDevice?0:_newDevice.deviceId.intValue,self.isAddDevice?@"addDevice":@"editDevice",string] andName:@"addOrEditDevice"];
    }
}
#pragma mark - Table view delegate
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    NSString *str = cell.detailTextLabel.text;
    if (self.nameTextField.editing) {
        [self.nameTextField endEditing:YES];
    }
    switch (indexPath.row) {
        case 0:
            [self.nameTextField becomeFirstResponder];
            break;
        case 1: //room
            _pickerView = [[MYEPickerView alloc] initWithView:self.view andTag:1 title:@"room select" dataSource:_rooms andSelectRow:[_rooms containsObject:str]?[_rooms indexOfObject:str]:0];
            break;
        case 2: //type
            if (!self.isAddDevice) {
                return;
            }
            _pickerView = [[MYEPickerView alloc] initWithView:self.view andTag:2 title:@"type select" dataSource:_types andSelectRow:[_types containsObject:str]?[_types indexOfObject:str]:0];
            break;
        case 3:    //tid
            if (self.device.typeId.intValue == 6 ||self.device.typeId.intValue == 7 || self.device.typeId.intValue == 0) {
                return;
            }
            _pickerView = [[MYEPickerView alloc] initWithView:self.view andTag:3 title:@"terminal select" dataSource:_terminals andSelectRow:[_terminals containsObject:str]?[_terminals indexOfObject:str]:0];
            break;
        default:
            _pickerView = [[MYEPickerView alloc] initWithView:self.view andTag:4 title:@"maxElect select" dataSource:_elcts andSelectRow:0];
            break;
    }
    _pickerView.delegate = self;
    [_pickerView showInView:self.view];
}
#pragma mark - URL Delegate methods
-(void)didReceiveString:(NSString *)string loaderName:(NSString *)name userDataDictionary:(NSDictionary *)dict{
    [HUD hide:YES];
    NSLog(@"download string is %@",string);
    if ([name isEqualToString:@"downloadInfo"]) {
        if ([string isEqualToString:@"fail"]) {
            [self doThisWhenNeedAlert];
        }else{
            MyEDeviceEdit *edit = [[MyEDeviceEdit alloc] initWithJSONString:string];
            self.deviceEdit = edit;
            _newDevice = edit.device;  //这里存放的是device数据
            NSLog(@"_newDevice is %@",_newDevice);
            [self getArraysFromMainData];
            [self refreshUI];
        }
    }
    if ([name isEqualToString:@"downloadOtherInfo"]) {
        if (![string isEqualToString:@"fail"]) {
            //  {"t_aliasName":"P-67","name":"ee","locationId":0,"maxCurrent":11}
            NSDictionary *dic = [string JSONValue];
            _newDevice = [[MyEDevice alloc] init];
            _newDevice.tid = dic[@"t_aliasName"];
            _newDevice.deviceName = dic[@"name"];
            _newDevice.locationId = dic[@"locationId"];
            if (dic[@"maxCurrent"]) {
                _newDevice.maxCurrent = [dic[@"maxCurrent"] intValue];
            }
            self.deviceEdit = [[MyEDeviceEdit alloc] init];
            NSMutableArray *roomArray = [self.mainDevice.rooms mutableCopy];
            for (MyERoom *r in self.mainDevice.rooms) {
                if (r.roomId == -1) {
                    [roomArray removeObject:r];
                }
            }
            self.deviceEdit.rooms = roomArray;
            [self getArraysFromMainData];
            [self refreshUI];
        }else
            [SVProgressHUD showErrorWithStatus:@"Error!"];
    }
    if ([name isEqualToString:@"otherEdit"]) {
        if (![string isEqualToString:@"fail"]) {
            [SVProgressHUD showSuccessWithStatus:@"Success!"];
        }else
            [SVProgressHUD showErrorWithStatus:@"Error!"];
    }
    if ([name isEqualToString:@"addOrEditDevice"]) {
        if ([string isEqualToString:@"OK"]) {
            //这里也是使用了一个技巧
            NSLog(@"index is %i",[self.navigationController.childViewControllers indexOfObject:self]);
            NSLog(@"first vc is %@",self.navigationController.childViewControllers[0]);
            MyEDevicesViewController *vc = (MyEDevicesViewController *)[self.navigationController childViewControllers][[self.navigationController.childViewControllers indexOfObject:self]-1];
            vc.needRefresh = YES;
            [self.navigationController popViewControllerAnimated:YES];
        }else if (string.intValue == -500){
            [SVProgressHUD showWithStatus:@"device name exist"];
        }else
            [SVProgressHUD showErrorWithStatus:@"Error!"];
    }
}
-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error loaderName:(NSString *)name{
    [HUD hide:YES];
    [self doThisWhenNeedAlert];
}
#pragma mark - IQActionSheetPickerView delegate methods
-(void)MYEPickerView:(UIView *)pickerView didSelectTitles:(NSString *)title andRow:(NSInteger)row{
    NSIndexPath * indexPath = [NSIndexPath indexPathForRow:pickerView.tag inSection:0];
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    cell.detailTextLabel.text = title;
    [self.tableView reloadData];
}
#pragma mark - UIAlertView delegate methods
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    [self.navigationController popViewControllerAnimated:YES];
}
@end
