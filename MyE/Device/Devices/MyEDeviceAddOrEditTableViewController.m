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
}
@end

@implementation MyEDeviceAddOrEditTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}
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
        if (self.device.typeId.intValue != 6) {
            [self uploadOrDownloadInfoFromServerWithURL:[NSString stringWithFormat:@"%@?houseId=%i&deviceId=%@&action=editDevice",GetRequst(URL_FOR_FIND_DEVICE),MainDelegate.houseData.houseId,self.device.deviceId] andName:@"downloadInfo"];
        }else
            [self uploadOrDownloadInfoFromServerWithURL:[NSString stringWithFormat:@"%@?houseId=%i&tId=%@",GetRequst(URL_FOR_SOCKET_PlUG_CONTROL),MainDelegate.houseData.houseId,self.device.deviceId] andName:@"downloadSocketInfo"];
        
    }
    //    [self uploadOrDownloadInfoFromServerWithURL:[NSString stringWithFormat:@"%@?houseId=%i&deviceId=%@&tId=%@",GetRequst(URL_FOR_INSTRUCTIONLIST_VIEW),MainDelegate.houseData.houseId,self.device.deviceId,self.device.tid] andName:@"instruction"];
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
    self.nameTextField.text = self.deviceEdit.device.deviceName;
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
                    cell.detailTextLabel.text = [self.deviceEdit getRoomNameByRoomId:self.device.locationId.intValue];
                    break;
                case 2:
                {MyEType *t = [self.deviceEdit getTypeByTypeId:[self.deviceEdit.device.typeId intValue]];
                    cell.detailTextLabel.text = t.typeName;}
                    break;
                default:
                {MyETerminal *t = [self.deviceEdit getTerminalByTid:self.deviceEdit.device.tid];
                    cell.detailTextLabel.text = t.terminalName;}
                    break;
            }
        }
    }
    if (self.device.typeId.intValue == 6) {
        self.nameTextField.text = self.socketInfo.name;
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:4 inSection:0];
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%i A",self.socketInfo.maxCurrent];
    }
    [self.tableView reloadData];
}
-(void)doThisWhenNeedAlert{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Warning" message:@"Connect failed! You cann't add or edit device" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    alert.delegate = self;
    [alert show];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - IBAction methods
- (IBAction)save:(UIBarButtonItem *)sender {
    self.device.deviceName = self.nameTextField.text;
    for (int i =1; i < 4; i++) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
        NSString *str = cell.detailTextLabel.text;
        switch (i) {
            case 1:
                self.device.locationId = [NSString stringWithFormat:@"%li",(long)[self.deviceEdit getRoomIdByRoomName:str]];
                NSLog(@"%@",self.device.locationId);
                break;
            case 2:
            {MyEType *type = [self.deviceEdit getTypeByTypeName:str];
                self.device.typeId = [NSString stringWithFormat:@"%li",(long)type.typeId];}
                break;
            default:
            {MyETerminal *terminal = [self.deviceEdit getTerminalByTName:str];
                self.device.tid = terminal.tId;
            }
                break;
        }
    }
    if (self.device.typeId.intValue == 6) {
        
    
    SBJsonWriter *writer = [[SBJsonWriter alloc] init];
    NSString *string = [writer stringWithObject:[self.device jsonDevice:self.device]];
    [self uploadOrDownloadInfoFromServerWithURL:[NSString stringWithFormat:@"%@?houseId=%i&deviceId=%i&action=%@&deviceMode=%@",GetRequst(URL_FOR_SAVE_DEVICE),MainDelegate.houseData.houseId,self.isAddDevice?0:self.device.deviceId.intValue,self.isAddDevice?@"addDevice":@"editDevice",string] andName:@"addOrEditDevice"];
    }else{
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:4 inSection:0];
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
        NSString *str = nil;
        if ([cell.detailTextLabel.text length] == 3) {
            str = [cell.detailTextLabel.text substringToIndex:1];
        }else
            str = [cell.detailTextLabel.text substringToIndex:2];
        [self uploadOrDownloadInfoFromServerWithURL:[NSString stringWithFormat:@"%@?houseId=%i&tId=%@&aliasName=%@&locationId=%@&maximalCurrent=%@",GetRequst(URL_FOR_SOCKET_SAVEPLUG),MainDelegate.houseData.houseId,self.device.tid,self.device.deviceName,self.device.locationId,str] andName:@"socketEdit"];
    }
}

#pragma mark - Table view delegate
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    NSString *str = cell.detailTextLabel.text;
    switch (indexPath.row) {
        case 0:
            [self.nameTextField becomeFirstResponder];
            break;
        case 1: //room
            [MyEUniversal doThisWhenNeedPickerWithTitle:@"room select" andDelegate:self andTag:1 andArray:@[_rooms] andSelectRow:[_rooms containsObject:str]?@[@([_rooms indexOfObject:str])]:@[@(0)] andViewController:self];
            break;
        case 2: //type
            if (!self.isAddDevice) {
                return;
            }
            [MyEUniversal doThisWhenNeedPickerWithTitle:@"type select" andDelegate:self andTag:2 andArray:@[_types] andSelectRow:[_types containsObject:str]?@[@([_types indexOfObject:str])]:@[@(0)] andViewController:self];
            break;
        case 3:    //tid
            [MyEUniversal doThisWhenNeedPickerWithTitle:@"terminal select" andDelegate:self andTag:3 andArray:@[_terminals] andSelectRow:[_terminals containsObject:str]?@[@([_terminals indexOfObject:str])]:@[@(0)] andViewController:self];
            break;
        default:
            [MyEUniversal doThisWhenNeedPickerWithTitle:@"maxElect select" andDelegate:self andTag:4 andArray:@[_elcts] andSelectRow:@[@(0)] andViewController:self];
            break;
    }
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
            [self getArraysFromMainData];
            [self refreshUI];
        }
    }
    if ([name isEqualToString:@"downloadSocketInfo"]) {
        if (![string isEqualToString:@"fail"]) {
            MyESocketInfo *info = [[MyESocketInfo alloc] initWithJSONString:string];
            self.socketInfo = info;
            [self getArraysFromMainData];
            [self refreshUI];
        }else
            [SVProgressHUD showErrorWithStatus:@"Error!"];
    }
    if ([name isEqualToString:@"socketEdit"]) {
        if (![string isEqualToString:@"fail"]) {
            [SVProgressHUD showSuccessWithStatus:@"Success!"];
        }else
            [SVProgressHUD showErrorWithStatus:@"Error!"];
    }
    if ([name isEqualToString:@"addOrEditDevice"]) {
        if ([string isEqualToString:@"OK"]) {
            NSLog(@"first vc is %@",self.navigationController.childViewControllers[0]);
            MyEDevicesViewController *vc = (MyEDevicesViewController *)[self.navigationController childViewControllers][0];
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
-(void)actionSheetPickerView:(IQActionSheetPickerView *)pickerView didSelectTitles:(NSArray *)titles{
    NSIndexPath * indexPath = [NSIndexPath indexPathForRow:pickerView.tag inSection:0];
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    cell.detailTextLabel.text = titles[0];
    [self.tableView reloadData];
}
#pragma mark - UIAlertView delegate methods
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    [self.navigationController popViewControllerAnimated:YES];
}
@end
