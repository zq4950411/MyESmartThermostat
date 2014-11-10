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
    EGORefreshTableHeaderView *_refreshHeaderView;
    BOOL _isRefreshing;
    BOOL _isEditInstruction;
}
@end

@implementation MyEDeviceAddOrEditTableViewController

#pragma mark - life circle methods
- (void)viewDidLoad
{
    [super viewDidLoad];
    if (self.isAddDevice) {
        self.title = @"ADD Device";
        self.device = [[MyEDevice alloc] init];
    }else
        self.title = self.device.deviceName;
    
    [self downloadInfoFromServer];
    if (!_refreshHeaderView) {
        EGORefreshTableHeaderView *view = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - self.tableView.bounds.size.height, self.tableView.frame.size.width, self.tableView.bounds.size.height)];
        view.delegate = self;
        [self.tableView addSubview:view];
        _refreshHeaderView = view;
    }
    [_refreshHeaderView refreshLastUpdatedDate];   //更新最新时间
    [self defineTapGestureRecognizer];
    if (_irCodeBtn && !IS_IOS6) {
        _irCodeBtn.layer.cornerRadius = 4;
        _irCodeBtn.layer.borderWidth = 1.0f;
        _irCodeBtn.layer.borderColor = _irCodeBtn.tintColor.CGColor;
    }
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    if (_device.typeId.intValue == 1 && _isEditInstruction) {
        _isEditInstruction = NO;
        [self refreshUI];
    }
}
#pragma mark - private methods
-(void)defineTapGestureRecognizer{
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
    tapGesture.cancelsTouchesInView = NO;
    [self.tableView addGestureRecognizer:tapGesture];
}

-(void)hideKeyboard{
    [self.nameTextField endEditing:YES];
}

-(void)downloadInfoFromServer{
    if (self.isAddDevice) {
        [self uploadOrDownloadInfoFromServerWithURL:[NSString stringWithFormat:@"%@?houseId=%i&action=addDevice",GetRequst(URL_FOR_FIND_DEVICE),MainDelegate.houseData.houseId] andName:@"downloadInfo"];
    }else{
        if (self.device.typeId.intValue == 6) {  //插座
            [self uploadOrDownloadInfoFromServerWithURL:[NSString stringWithFormat:@"%@?houseId=%i&tId=%@",GetRequst(URL_FOR_SOCKET_INFO),MainDelegate.houseData.houseId,self.device.tid] andName:@"downloadOtherInfo"];
        }else if(self.device.typeId.intValue == 7 || self.device.typeId.intValue == 0){   //通用控制器或者温控器
            [self uploadOrDownloadInfoFromServerWithURL:[NSString stringWithFormat:@"%@?houseId=%i&tId=%@&deviceId=%@",GetRequst(URL_FOR_UNIVERSAL_CONTROLLER_INFO),MainDelegate.houseData.houseId,self.device.tid,self.device.deviceId] andName:@"downloadOtherInfo"];
        }else
            [self uploadOrDownloadInfoFromServerWithURL:[NSString stringWithFormat:@"%@?houseId=%i&deviceId=%@&action=editDevice",GetRequst(URL_FOR_FIND_DEVICE),MainDelegate.houseData.houseId,self.device.deviceId] andName:@"downloadInfo"];
    }
}
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
        if (t.typeId != 8) {
            [_types addObject:t.typeName];
        }
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
    self.acTypeLbl.text = [_device.brand isEqualToString:@""]?@"No IR Code":[NSString stringWithFormat:@"%@/%@",_device.brand,_device.model];
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
                    cell.detailTextLabel.text = _terminals.count==0?@"":_terminals[0];
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
                        cell.detailTextLabel.text = @"Smart DIY";
                    }else if(self.device.typeId.intValue == 9){
                        cell.detailTextLabel.text = @"Intrusion Detecto";
                    }else if(self.device.typeId.intValue == 10){
                        cell.detailTextLabel.text = @"Smoke Detector";
                    }else if(self.device.typeId.intValue == 11){
                        cell.detailTextLabel.text = @"Door/window Sensor";
                    }else if(self.device.typeId.intValue == 0){
                        cell.detailTextLabel.text = @"Thermostat";
                    }else{
                        MyEType *t = [self.deviceEdit getTypeByTypeId:[_newDevice.typeId intValue]];
                        cell.detailTextLabel.text = t.typeName;
                        cell.detailTextLabel.textColor = [UIColor lightGrayColor];
                    }}
                    break;
                default:
                {
                    if (self.device.typeId.intValue == 6) {
                        cell.detailTextLabel.text = self.device.tid;
                    }else if(self.device.typeId.intValue == 7){
                        cell.detailTextLabel.text = self.device.tid;
                    }else if(self.device.typeId.intValue == 0){
                        cell.detailTextLabel.text = self.device.tid;
                    }else{
                        cell.textLabel.text = @"Smart Remote";
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
    [self.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
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
- (IBAction)EditAcInstruction:(UIButton *)sender {
    _isEditInstruction = YES;
    UIStoryboard *story = [UIStoryboard storyboardWithName:@"AcInstruction" bundle:nil];
    MyEInstructionManageViewController *vc = [story instantiateViewControllerWithIdentifier:@"instructionVC"];
    vc.device = self.device;
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)save:(UIBarButtonItem *)sender {
    [self.nameTextField resignFirstResponder];
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
            {
                if ([str isEqualToString:@""] || str == nil) {  //这里也是做了防护措施
                    [SVProgressHUD showErrorWithStatus:@"No SmartRemote"];
                    return;
                }
                MyETerminal *terminal = [self.deviceEdit getTerminalByTName:str];
                _newDevice.tid = terminal.tId;
            }
                break;
        }
    }
    if (self.isAddDevice) {
        if (_newDevice.typeId.intValue == 1) {
            [self uploadOrDownloadInfoFromServerWithURL:[NSString stringWithFormat:@"%@?houseId=%i&id=%@&action=0&name=%@&tId=%@&roomId=%@",GetRequst(URL_FOR_AC_ADD_EDIT_SAVE),MainDelegate.houseData.houseId,_newDevice.deviceId,_newDevice.deviceName,_newDevice.tid,_newDevice.locationId] andName:@"addAC"];
        }else{
            SBJsonWriter *writer = [[SBJsonWriter alloc] init];
            NSString *string = [writer stringWithObject:[_newDevice jsonDevice:_newDevice]];
            NSLog(@"string is %@",string);
            [self uploadOrDownloadInfoFromServerWithURL:[NSString stringWithFormat:@"%@?houseId=%i&deviceId=%i&action=addDevice&deviceMode=%@",GetRequst(URL_FOR_SAVE_DEVICE),MainDelegate.houseData.houseId,self.isAddDevice?0:_newDevice.deviceId.intValue,string] andName:@"addOrEditDevice"];
        }
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
    }else if (self.device.typeId.intValue == 1){
        [self uploadOrDownloadInfoFromServerWithURL:[NSString stringWithFormat:@"%@?houseId=%i&id=%@&action=1&name=%@&tId=%@&roomId=%@",GetRequst(URL_FOR_AC_ADD_EDIT_SAVE),MainDelegate.houseData.houseId,_newDevice.deviceId,_newDevice.deviceName,_newDevice.tid,_newDevice.locationId] andName:@"editAC"];
    }else{
        SBJsonWriter *writer = [[SBJsonWriter alloc] init];
        NSString *string = [writer stringWithObject:[_newDevice jsonDevice:_newDevice]];
        NSLog(@"string is %@",string);
        [self uploadOrDownloadInfoFromServerWithURL:[NSString stringWithFormat:@"%@?houseId=%i&deviceId=%i&action=%@&deviceMode=%@",GetRequst(URL_FOR_SAVE_DEVICE),MainDelegate.houseData.houseId,self.isAddDevice?0:_newDevice.deviceId.intValue,self.isAddDevice?@"addDevice":@"editDevice",string] andName:@"addOrEditDevice"];
    }
}

#pragma mark - UITableView dataSource method
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    if (self.device.typeId.intValue == 1 && !_isAddDevice) {
        return 2;
    }
    return 1;
}
#pragma mark - Table view delegate
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    NSString *str = cell.detailTextLabel.text;
    if (self.nameTextField.editing) {
        [self.nameTextField endEditing:YES];
    }
    if (indexPath.section == 1) {
        return;
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
            //2:TV,  3: Audio, 4:Automated Curtain, 5: Other,  6 智能插座,7:通用控制器, 8:智能开关
            if ((self.device.typeId.intValue == 0 ||self.device.typeId.intValue == 6 || self.device.typeId.intValue == 7 || _device.typeId.intValue == 8)) {
                    return;
            }
//            if (!_isAddDevice && self.device.typeId.intValue == 1) {
//                return;
//            }
            if (![_terminals count]) {  //这里是个保护措施，当终端为零时点击之后没反应
                [SVProgressHUD showErrorWithStatus:@"No SmartRemote"];
                return;
            }
            _pickerView = [[MYEPickerView alloc] initWithView:self.view andTag:3 title:@"terminal select" dataSource:_terminals andSelectRow:[_terminals containsObject:str]?[_terminals indexOfObject:str]:0];
            break;
        default:
            _pickerView = [[MYEPickerView alloc] initWithView:self.view andTag:4 title:@"maxElect select" dataSource:_elcts andSelectRow:0];
            break;
    }
    if (indexPath.row != 0) {
        _pickerView.delegate = self;
        [_pickerView showInView:self.view];
    }
}
#pragma mark - URL Delegate methods
-(void)didReceiveString:(NSString *)string loaderName:(NSString *)name userDataDictionary:(NSDictionary *)dict{
    [HUD hide:YES];
    if (_isRefreshing) {
        _isRefreshing = NO;
        [_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:self.tableView];
    }
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
            [self performSelector:@selector(refreshUI) withObject:nil afterDelay:0.1f];
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
        if ([string isEqualToString:@"OK"]) {
            MyEDevicesViewController *vc = (MyEDevicesViewController *)[self.navigationController childViewControllers][[self.navigationController.childViewControllers indexOfObject:self]-1];
            vc.needRefresh = YES;
            [self.navigationController popViewControllerAnimated:YES];
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
    if ([name isEqualToString:@"addAC"]) {
        NSInteger i = [MyEUtil getResultFromAjaxString:string];
        if (i == 1) {
            NSDictionary *dic = [string JSONValue];
            if (dic[@"id"]) {
                MyEDevicesViewController *vc = (MyEDevicesViewController *)[self.navigationController childViewControllers][[self.navigationController.childViewControllers indexOfObject:self]-1];
                vc.needRefresh = YES;
                [self.navigationController popViewControllerAnimated:YES];
            }
        }else if (i == -1){
            [SVProgressHUD showErrorWithStatus:@"This Smart Remote has an AC"];
        }else if (i == -2){
            [SVProgressHUD showErrorWithStatus:@"Device name has existed"];
        }else{
            [SVProgressHUD showErrorWithStatus:@"fail"];
        }
    }
    if ([name isEqualToString:@"editAC"]) {
        NSInteger i = [MyEUtil getResultFromAjaxString:string];
        if (i == 1) {
            MyEDevicesViewController *vc = (MyEDevicesViewController *)[self.navigationController childViewControllers][[self.navigationController.childViewControllers indexOfObject:self]-1];
            vc.needRefresh = YES;
            [self.navigationController popViewControllerAnimated:YES];
        }else
            [SVProgressHUD showErrorWithStatus:@"fail"];
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
#pragma mark - UIScrollViewDelegate Methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
    [_refreshHeaderView egoRefreshScrollViewDidScroll:scrollView];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    
    [_refreshHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
}
#pragma mark - EGORefreshTableHeaderDelegate Methods

- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView*)view{
    _isRefreshing = YES;
    [self downloadInfoFromServer];
}
- (NSDate*)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView*)view{
    return [NSDate date]; // should return date data source was last changed
}

@end
