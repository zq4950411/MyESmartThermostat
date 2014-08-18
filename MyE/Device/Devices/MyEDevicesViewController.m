//
//  SmartUpViewController.m
//  MyE
//
//  Created by space on 13-8-6.
//  Copyright (c) 2013年 MyEnergy Domain. All rights reserved.
//

#import "MyEDevicesViewController.h"
//switch
#import "MyESwitchManualControlViewController.h"
#import "MyESwitchAutoViewController.h"
#import "MyESwitchEditViewController.h"
//tv or audio
#import "MyEIrControlPageViewController.h"
//curtain
#import "MyECurtainControlViewController.h"
//rooms
#import "MyERoomsTableViewController.h"
//device add or edit
#import "MyEDeviceAddOrEditTableViewController.h"
//socket
#import "MyESocketManualViewController.h"
//框架文件
#import "SWRevealViewController.h"
#import "MyEIrUserKeyViewController.h"

//通用控制器
#import "MyEUCAutoViewController.h"
#import "MyEUCManualViewController.h"
#import "MyEUCConditionViewController.h"

//温控器
#import "MyEThemostatTabBarController.h"
//AC
#import "MyEAcTempMonitorViewController.h"
#import "MyEAcEnergySavingViewController.h"
#import "MyEAutoControlViewController.h"
#import "MyEACManualControlNavController.h"

@interface MyEDevicesViewController(){
    NSArray *_rooms;
    NSIndexPath *_selectedIndexPath;  //当前选定的indexPath
    NSMutableDictionary *_mainDic;
    MBProgressHUD *HUD;
    NSMutableArray *_devices;
    EGORefreshTableHeaderView *_refreshHeaderView;
    BOOL _isRefreshing;
    BOOL _isDelete;  //表示删除模式，此时指定行是不能编辑的
    UITapGestureRecognizer *_tableTap;   //这两个手势主要用于排序
    UILongPressGestureRecognizer *_tableLong;
}
@end
@implementation MyEDevicesViewController

#pragma mark - life circle methods
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    [self.tableView reloadData];
    if (self.needRefresh) {
        self.needRefresh = NO;
        [self downloadDevicesFromServer];
    }
}
-(void) viewDidLoad
{
    [super viewDidLoad];
    _isDelete = YES;  //这里进行初始化
    self.navigationController.navigationBar.translucent = NO;
    UIView *view = [[UIView alloc] init];
    view.backgroundColor = [UIColor clearColor];
    self.tableView.tableFooterView = view;
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    //这里是用来更新button的UI
    UIButton *btn = (UIButton *)[self.view viewWithTag:98];
    if (!IS_IOS6) {
        [btn setBackgroundImage:[UIImage imageNamed:@"detailBtn"] forState:UIControlStateNormal];
    }else{
        [btn setBackgroundImage:[UIImage imageNamed:@"detailBtn-ios6"] forState:UIControlStateNormal];
    }
    [btn setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 30)];
    //初始化左上角菜单
    //    _sidebarButton.tintColor = [UIColor colorWithWhite:0.36f alpha:0.82f];
    _sidebarButton.target = self.revealViewController;
    _sidebarButton.action = @selector(revealToggle:);
    //    [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    //初始化下拉视图
    if (!_refreshHeaderView) {
        EGORefreshTableHeaderView *view = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - self.tableView.bounds.size.height, self.tableView.frame.size.width, self.tableView.bounds.size.height)];
        view.delegate = self;
        [self.tableView addSubview:view];
        _refreshHeaderView = view;
    }
    [_refreshHeaderView refreshLastUpdatedDate];   //更新最新时间
    
    [self downloadDevicesFromServer];
    _tableLong = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(beginTableViewEditing:)];
    [self.tableView addGestureRecognizer:_tableLong];
}

#pragma mark - URL  methods
-(void)downloadDevicesFromServer{
    [self uploadOrDownloadInfoFromServerWithURL:[NSString stringWithFormat:@"%@?houseId=%i",GetRequst(URL_FOR_SMARTUP_LIST),MainDelegate.houseData.houseId] andName:@"downloadDevices"];
}
-(void)uploadOrDownloadInfoFromServerWithURL:(NSString *)url andName:(NSString *)name{
    if (HUD == nil) {
        HUD = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    }
    [HUD show:YES];
    MyEDataLoader *loader = [[MyEDataLoader alloc] initLoadingWithURLString:url postData:nil delegate:self loaderName:name userDataDictionary:nil];
    NSLog(@"loader is %@",loader.name);
}

#pragma mark - device control and edit methods
-(void)deviceControl:(UITapGestureRecognizer *)tap
{
    CGPoint hit = [tap.view convertPoint:CGPointZero toView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:hit];
    _selectedIndexPath = indexPath;
    MyEDevice *device = _devices[indexPath.row];
    if (device.typeId.intValue == 0 || device.typeId.intValue == 1) {
        return;
    }
    if ([device.tid isEqualToString:@""]) {
        [SVProgressHUD showErrorWithStatus:@"SmartRemote is not specified"];
        return;
    }
    if (device.rfStatus.intValue == -1)
    {
        [SVProgressHUD showErrorWithStatus:@"device is not online"];
        return;
    }
    //2:TV,  3: Audio, 4:Automated Curtain, 5: Other,  6 智能插座,7:通用控制器  8:开关
    if (device.typeId.intValue == 8) {  //switch
        [self uploadOrDownloadInfoFromServerWithURL:[NSString stringWithFormat:@"%@?houseId=%i&tId=%@&action=1&switchStatus=%i",GetRequst(URL_FOR_SWITCH_CONTROL),MainDelegate.houseData.houseId,device.tid,device.switchStatus.intValue==1?0:1] andName:@"switchControl"];
    }
    else if (device.typeId.intValue == 7){  //通用控制器
        [self uploadOrDownloadInfoFromServerWithURL:[NSString stringWithFormat:@"%@?houseId=%i&tId=%@&switchStatus=%i",GetRequst(URL_FOR_UNIVERSAL_CONTROL_MANUEL_CONTROL),MainDelegate.houseData.houseId,device.tid,device.switchStatus.intValue==1?0:1] andName:@"universalControl"];
    }
    else if (device.typeId.intValue == 6){  // socket
        [self uploadOrDownloadInfoFromServerWithURL:[NSString stringWithFormat:@"%@?houseId=%i&tId=%@",GetRequst(URL_FOR_SMARTUP_PlUG_CONTROL),MainDelegate.houseData.houseId,device.tid] andName:@"socketControl"];
    }else{   //红外设备开关控制
        NSInteger controlValue = 0;
        if (device.typeId.intValue == 2) {
            controlValue = 203;
        }else if(device.typeId.intValue == 3){
            controlValue = 301;
        }else
            controlValue = 1 - device.switchStatus.intValue==1;
        [self uploadOrDownloadInfoFromServerWithURL:[NSString stringWithFormat:@"%@?houseId=%i&deviceId=%@&switchStatus=%i",GetRequst(URL_FOR_IRDEVICE_CONTROL),MainDelegate.houseData.houseId,device.deviceId,controlValue] andName:@"irDeviceControl"];
    }
}

-(void) editDevice:(UIButton *)sender
{
    //2:TV,  3: Audio, 4:Automated Curtain, 5: Other,  6 智能插座,7:通用控制器  8:开关
    CGPoint hit = [sender convertPoint:CGPointZero toView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:hit];
    MyEDevice *device = [_devices objectAtIndex:indexPath.row];
    if (device.typeId.intValue == 6)  //socket
    {
        UIStoryboard *story = [UIStoryboard storyboardWithName:@"Device" bundle:nil];
        MyEDeviceAddOrEditTableViewController *vc = [story instantiateViewControllerWithIdentifier:@"socketEdit"];
        vc.isAddDevice = NO;
        vc.device = device;
        vc.mainDevice = self.mainDevice;
        [self.navigationController pushViewController:vc animated:YES];
    }
    else if(device.typeId.intValue == 7 || device.typeId.intValue == 0)  //通用控制器和温控器
    {
        MyEDeviceAddOrEditTableViewController *vc = [[UIStoryboard storyboardWithName:@"Device" bundle:nil] instantiateViewControllerWithIdentifier:@"other"];
        vc.device = device;
        vc.isAddDevice = NO;
        vc.mainDevice = self.mainDevice;
        [self.navigationController pushViewController:vc animated:YES];
    }
    else if(device.typeId.intValue == 8)  //switch
    {
        UIStoryboard *story = [UIStoryboard storyboardWithName:@"Switch" bundle:nil];
        MyESwitchEditViewController *vc = [story instantiateViewControllerWithIdentifier:@"switchEdit"];
        vc.device = device;
        [self.navigationController pushViewController:vc animated:YES];
    }else
    {
        UIStoryboard *story = [UIStoryboard storyboardWithName:@"Device" bundle:nil];
        MyEDeviceAddOrEditTableViewController *vc = [story instantiateViewControllerWithIdentifier:@"deviceAddOrEdit"];
        vc.isAddDevice = NO;
        vc.device = device;
        [self.navigationController pushViewController:vc animated:YES];
    }
}
#pragma mark - private methods
-(void)beginTableViewEditing:(UILongPressGestureRecognizer *)sender{
    if (sender.state == UIGestureRecognizerStateBegan) {
        _isDelete = NO;
        if (self.tableView.editing) {
            return;
        }
        [self.tableView setEditing:!self.tableView.editing animated:YES];
        _tableTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapOnTableView:)];
        _tableTap.numberOfTapsRequired = 1;
        [self.tableView removeGestureRecognizer:_tableLong];
        [self.tableView addGestureRecognizer:_tableTap];
    }
}
// 对于双击和单击事件，不需要对状态进行判断，主要是他这个状态维持的时间很短
-(void)tapOnTableView:(UITapGestureRecognizer *)sender{
    _isDelete = YES;
    if (!self.tableView.editing) {
        return;
    }
    [self.tableView setEditing:!self.tableView.editing animated:YES];
    [self.tableView removeGestureRecognizer:_tableTap];
    [self.tableView addGestureRecognizer:_tableLong];
}
-(NSString *)getDeviceTypeNameByTypeId:(NSString *)typeId{
    NSString *string = nil;
    switch (typeId.intValue) {
        case 0:
            string = @"them";
            break;
        case 1:
            string = @"ac";
            break;
        case 2:
            string = @"tv";
            break;
        case 3:
            string = @"audio";
            break;
        case 4:
            string = @"curtain";
            break;
        case 5:
            string = @"other";
            break;
        case 6:
            string = @"socket";
            break;
        case 7:
            string = @"uc";
            break;
        case 8:
            string = @"switch";
            break;
        default:
            string = @"";
            break;
    }
    return string;
}
-(void)changeSwitchStatusImageView{
    MyEDevice *device = [_devices objectAtIndex:_selectedIndexPath.row];
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:_selectedIndexPath];
    UIImageView *image = (UIImageView *)[cell.contentView viewWithTag:100];
    //2:TV,  3: Audio, 4:Automated Curtain, 5: Other,  6 智能插座,7:通用控制器  8:开关
    image.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@-%@",[self getDeviceTypeNameByTypeId:device.typeId],device.switchStatus.intValue == 0 ?@"on":@"off"]];
    device.switchStatus = device.switchStatus.intValue == 0?@"1":@"0";
    //    if (device.switchStatus.intValue == 0)
    //    {
    //        device.switchStatus = @"1";
    //        image.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@-on",string]];
    //    }
    //    else
    //    {
    //        device.switchStatus = @"0";
    //        image.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@-off",string]];
    //    }
}
-(void)chooseRoom:(KxMenuItem *) sender{
    NSString *roomName = _rooms[sender.tag];
    [self.roomBtn setTitle:roomName forState:UIControlStateNormal];
    _devices = [_mainDic[roomName] mutableCopy];
    [self.tableView reloadData];
}
-(void)refreshData{
    _mainDic = [NSMutableDictionary dictionary];
    NSMutableArray *array = [NSMutableArray array];
    NSMutableArray *array1 = [NSMutableArray array];
    
    for (MyERoom *r in self.mainDevice.rooms) {
        for (MyEDevice *d in self.mainDevice.devices) {
            if ([d.locationName isEqualToString:r.roomName]) {
                [array addObject:d];
            }
            if ([d.locationName isEqualToString:@""]) {
                if (![array1 containsObject:d]) {
                    [array1 addObject:d];
                }
            }
        }
        [_mainDic setValue:array forKey:r.roomName];
        //        if ([array count] != 0) {
        //            [_mainDic setValue:array forKey:r.roomName];
        //        }else
        //            [_mainDic setValue:[NSArray array] forKey:r.roomName];
        array = [NSMutableArray array];
    }
    [_mainDic setValue:array1 forKey:@"unspecified"];
    [_mainDic setValue:self.mainDevice.devices forKey:@"All"];
    
    NSLog(@"_mainDic is %@",_mainDic);
}
#pragma mark - IBAction methods
- (IBAction)changeRoom:(UIButton *)sender {
    NSMutableArray *items = [NSMutableArray array];
    NSMutableArray *array = [_mainDic.allKeys mutableCopy];
    [array removeObject:@"All"];
    [array removeObject:@"unspecified"];
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"self" ascending:YES];
    NSMutableArray *newArray = [[array sortedArrayUsingDescriptors:@[sort]] mutableCopy];
    [newArray insertObject:@"All" atIndex:0];
    [newArray insertObject:@"unspecified" atIndex:[newArray count]];
    _rooms = newArray;
    for (int i = 0; i < _rooms.count; i++)
    {
        KxMenuItem *item = [KxMenuItem menuItem:_rooms[i]
                                          image:nil
                                         target:self
                                         action:@selector(chooseRoom:)];
        item.foreColor = [UIColor whiteColor];
        item.tag = i;
        [items addObject:item];
    }
    UIView *tile = (UIView *)sender;
    if (items.count > 0)
    {
        [KxMenu showMenuInView:self.view
                      fromRect:tile.frame
                     menuItems:items];
    }
}
- (IBAction)editRoom:(UIButton *)sender {
    UIStoryboard *story = [UIStoryboard storyboardWithName:@"Device" bundle:nil];
    MyERoomsTableViewController *vc = [story instantiateViewControllerWithIdentifier:@"roomsVC"];
    vc.mainDic = _mainDic;
    vc.mainDevice = self.mainDevice;
    [self.navigationController pushViewController:vc animated:YES];
}
- (IBAction)addDevice:(UIBarButtonItem *)sender {
    UIStoryboard *story = [UIStoryboard storyboardWithName:@"Device" bundle:nil];
    MyEDeviceAddOrEditTableViewController *vc = [story instantiateViewControllerWithIdentifier:@"deviceAddOrEdit"];
    vc.isAddDevice = YES;
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - UITableView dataSource methods

-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _devices.count;
}

-(UITableViewCell *) tableView:(UITableView *)tv cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    if (cell == nil) {
        cell = [self.tableView dequeueReusableCellWithIdentifier:@"deviceCell" forIndexPath:indexPath];
    }
    MyEDevice *device = [_devices objectAtIndex:indexPath.row];
    UIView *bgView = (UIView *)[cell.contentView viewWithTag:99];
    UIImageView *typeImageView = (UIImageView *)[cell.contentView viewWithTag:100];
    UILabel *nameLabel = (UILabel *)[cell.contentView viewWithTag:101];
    UILabel *roomLabel = (UILabel *)[cell.contentView viewWithTag:102];
    UIImageView *signal = (UIImageView *)[cell.contentView viewWithTag:103];
    UIButton *btn = (UIButton*)[cell.contentView viewWithTag:104];
    
    bgView.layer.cornerRadius = 4;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(deviceControl:)];
    [typeImageView addGestureRecognizer:tap];
    
    typeImageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@-%@",[self getDeviceTypeNameByTypeId:device.typeId],device.switchStatus.intValue==0?@"off":@"on"]];
    nameLabel.text = device.deviceName;
    roomLabel.text = device.locationName;
    //    roomLabel.text = [device.locationName isEqualToString:@""]?@"unspecified":device.locationName;
    if ([device.tid isEqualToString:@""]) {
        signal.image = [UIImage imageNamed:@"noconnection"];
    }else
        signal.image = [UIImage imageNamed:device.rfStatus.intValue == -1?@"signal0":[NSString stringWithFormat:@"signal%i",device.rfStatus.intValue]];
    [btn addTarget:self action:@selector(editDevice:) forControlEvents:UIControlEventTouchUpInside];
    
    return cell;
}

#pragma mark - UITableView delegate methods
-(void) tableView:(UITableView *)table didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    MyEDevice *device = [_devices objectAtIndex:indexPath.row];
    if (device.tid.length == 0)
    {
        [SVProgressHUD showErrorWithStatus:@"Please specify the SmartRemoteUsed"];
        return;
    }
    
    if (device.rfStatus.intValue == -1)
    {
        [SVProgressHUD showErrorWithStatus:@"device is not online"];
        return;
    }
    //0:温控器  2:TV,  3: Audio, 4:Automated Curtain, 5: Other,  6 智能插座,7:通用控制器  8:开关
    if (device.typeId.intValue == 0) {
        for (MyETerminalData *t in MainDelegate.houseData.terminals) {
            if ([t.tId isEqualToString:device.tid]) {
                MainDelegate.terminalData = t;
            }
        }
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"thermostat" bundle:nil];
        MyEThemostatTabBarController *vc = [storyboard instantiateViewControllerWithIdentifier:@"tab_bar_controller"];
        // 	温控器所有二级控制页面（Dashboard, Next24, Weekly, etc），标题都采用该温控器的别名。
        
        //        vc.title = MainDelegate.terminalData.tName;
        vc.title = device.deviceName;
        vc.device = device;
        NSLog(@"MainDelegate.thermostatData.tName = %@", MainDelegate.terminalData.tName);
        
        [self.navigationController pushViewController:vc animated:YES];
    }
    if (device.typeId.intValue == 1) {
        if ([device.brand isEqualToString:@""]) {
            [SVProgressHUD showErrorWithStatus:@"No IR Code"];
            return;
        }
        UITabBarController *tab = [[UIStoryboard storyboardWithName:@"AcDevice" bundle:nil] instantiateInitialViewController];
        MyEACManualControlNavController *nav1 = tab.childViewControllers[0];
        nav1.device = device;
        UINavigationController *nav2 = tab.childViewControllers[1];
        MyEAutoControlViewController *vc = nav2.childViewControllers[0];
        vc.device = device;
        UINavigationController *nav3 = tab.childViewControllers[2];
        MyEAcEnergySavingViewController *energy = nav3.childViewControllers[0];
        energy.device = device;
        UINavigationController *nav4 = tab.childViewControllers[3];
        MyEAcTempMonitorViewController *temp = nav4.childViewControllers[0];
        temp.device = device;
        [self presentViewController:tab animated:YES completion:nil];
    }
    if(device.typeId.intValue == 2 || device.typeId.intValue == 3)  //TV  Audio
    {
        UIStoryboard *story = [UIStoryboard storyboardWithName:@"Device" bundle:nil];
        MyEIrControlPageViewController *vc = [story instantiateViewControllerWithIdentifier:@"irControl"];
        vc.device = device;
        [self.navigationController pushViewController:vc animated:YES];
    }else if (device.typeId.intValue == 4){   //curtain
        MyECurtainControlViewController *vc = [[UIStoryboard storyboardWithName:@"Device" bundle:nil] instantiateViewControllerWithIdentifier:@"curtain"];
        vc.device = device;
        [self.navigationController pushViewController:vc animated:YES];
    }else if (device.typeId.intValue == 5){
        MyEIrUserKeyViewController *vc = [[UIStoryboard storyboardWithName:@"Device" bundle:nil] instantiateViewControllerWithIdentifier:@"IrUserKeyVC"];
        vc.device = device;
        [self.navigationController pushViewController:vc animated:YES];
    }
    else if (device.typeId.intValue == 6)  //插座
    {
        UIStoryboard *story = [UIStoryboard storyboardWithName:@"Socket" bundle:nil];
        UITabBarController *tab = [story instantiateViewControllerWithIdentifier:@"socket"];
        UINavigationController *nav1 = tab.childViewControllers[0];
        MyESocketManualViewController *vc1 = nav1.childViewControllers[0];
        vc1.device = device;
        UINavigationController *nav2 = tab.childViewControllers[1];
        MyESocketAutoViewController *vc2 = nav2.childViewControllers[0];
        vc2.device = device;
        [self presentViewController:tab animated:YES completion:nil];
    }
    else if(device.typeId.intValue == 7)
    {
        UITabBarController *tab = [[UIStoryboard storyboardWithName:@"UController" bundle:nil] instantiateInitialViewController];
        UINavigationController *nav = tab.childViewControllers[0];
        MyEUCManualViewController *vc1 = nav.childViewControllers[0];
        vc1.device = device;
        nav = tab.childViewControllers[1];
        MyEUCAutoViewController *vc2 = nav.childViewControllers[0];
        vc2.device = device;
        nav = tab.childViewControllers[2];
        MyEUCConditionViewController *vc3 = nav.childViewControllers[0];
        vc3.device = device;
        [self presentViewController:tab animated:YES completion:nil];
    }
    else if(device.typeId.intValue == 8)
    {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Switch" bundle:nil];
        UITabBarController *tabBarController = [storyboard instantiateViewControllerWithIdentifier:@"DeviceSwitchTabbar"];
        
        UINavigationController *nc = [[tabBarController childViewControllers] objectAtIndex:0];
        MyESwitchManualControlViewController *switchManualVC = [[nc childViewControllers] objectAtIndex:0];
        switchManualVC.device = device;
        
        UINavigationController *nc1 = [[tabBarController childViewControllers] objectAtIndex:1];
        MyESwitchAutoViewController *switchAutoVC = [[nc1 childViewControllers] objectAtIndex:0];
        switchAutoVC.device = device;
        [self presentViewController:tabBarController animated:YES completion:nil];
    }
}
-(void) tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        _selectedIndexPath = indexPath;
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Alert"
                                                            message:@"Deleting this device will also remove all settings associated with it. Are you sure to do so?"
                                                           delegate:self
                                                  cancelButtonTitle:@"NO"
                                                  otherButtonTitles:@"YES", nil];
        alertView.tag = 100;
        [alertView show];
    }
}

-(BOOL) tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_isDelete) {
        MyEDevice *device = _devices[indexPath.row];
        if (device.typeId.intValue < 1 || device.typeId.intValue > 5) {
            return NO;
        }
    }
    return YES;
}
- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath{
    return NO;
}
-(BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath{
    MyEDevice *device = _devices[fromIndexPath.row];
    [_devices removeObject:device];
    [_devices insertObject:device atIndex:toIndexPath.row];
    [self uploadOrDownloadInfoFromServerWithURL:[NSString stringWithFormat:@"%@?houseId=%i&deviceId=%@&sortId=%i",GetRequst(URL_FOR_SAVE_SORT),MainDelegate.houseData.houseId,device.deviceId,toIndexPath.row] andName:@"reorder"];
}

#pragma mark - network delegate methods
-(void)didReceiveString:(NSString *)string loaderName:(NSString *)name userDataDictionary:(NSDictionary *)dict{
    [HUD hide:YES];
    if (_isRefreshing) {
        _isRefreshing = NO;
        [_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:self.tableView];
    }
    NSLog(@"received string is %@",string);
    if ([name isEqualToString:@"downloadDevices"]) {
        if (string.intValue == -999) {
            [SVProgressHUD showErrorWithStatus:@"No Connection!"];
        }else if (![string isEqualToString:@"fail"]){
            MyEMainDevice *main = [[MyEMainDevice alloc] initWithJSONString:string];
            self.mainDevice = main;
            [self refreshData];
            if ([_mainDic.allKeys containsObject:self.roomBtn.currentTitle]) {
                _devices = _mainDic[self.roomBtn.currentTitle];
            }else{
                [self.roomBtn setTitle:@"All" forState:UIControlStateNormal];
                _devices = _mainDic[@"All"];
            }
            [self.tableView reloadData];
        }else
            [SVProgressHUD showErrorWithStatus:@"Error!"];
    }
    if ([name isEqualToString:@"irDeviceControl"] ||
        [name isEqualToString:@"switchControl"] ||
        [name isEqualToString:@"universalControl"] ||
        [name isEqualToString:@"socketControl"] ) {
        if ([@"OK" isEqualToString:string])
        {
            [self changeSwitchStatusImageView];
        }
        else if ([string isEqualToString:@"-999"]){
            [SVProgressHUD showWithStatus:@"No Connection"];
        }
        else
        {
            MyEDevice *device = _devices[_selectedIndexPath.row];
            if (device.typeId.intValue >= 2 && device.typeId.intValue < 6) {
                [SVProgressHUD showErrorWithStatus:@"Error,make sure ON/OFF has been recorded"];
                return;
            }
            [SVProgressHUD showErrorWithStatus:@"Error!"];
        }
    }
    if ([name isEqualToString:@"reorder"]) {
        
    }
    if ([name isEqualToString:@"delete"]) {
        if ([string isEqualToString:@"OK"]) {
            [_devices removeObjectAtIndex:_selectedIndexPath.row];
            [self.tableView deleteRowsAtIndexPaths:@[_selectedIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        }else
            [SVProgressHUD showErrorWithStatus:@"fail"];
    }
    if ([name isEqualToString:@"deleteAC"]) {
        NSInteger i = [MyEUtil getResultFromAjaxString:string];
        if (i == 1) {
            [_devices removeObjectAtIndex:_selectedIndexPath.row];
            [self.tableView deleteRowsAtIndexPaths:@[_selectedIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        }else
            [SVProgressHUD showErrorWithStatus:@"fail"];
    }
    
}
-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error loaderName:(NSString *)name{
    [HUD hide:YES];
    [SVProgressHUD showErrorWithStatus:@"Connection Fail"];
}

#pragma mark - UIAlertView delegate methods
-(void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 100 && buttonIndex == 1) {
        MyEDevice *device = _devices[_selectedIndexPath.row];
        if (device.typeId.intValue == 1) {
            [self uploadOrDownloadInfoFromServerWithURL:[NSString stringWithFormat:@"%@?houseId=%i&id=%@&action=2&name=%@&tId=%@&roomId=%@",GetRequst(URL_FOR_AC_ADD_EDIT_SAVE),MainDelegate.houseData.houseId,device.deviceId,device.deviceName,device.tid,device.locationId] andName:@"deleteAC"];
        }else
            [self uploadOrDownloadInfoFromServerWithURL:[NSString stringWithFormat:@"%@?houseId=%i&deviceId=%@&action=deleteDevice",GetRequst(URL_FOR_SAVE_DEVICE),MainDelegate.houseData.houseId,device.deviceId] andName:@"delete"];
    }
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
    [self downloadDevicesFromServer];
}
- (NSDate*)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView*)view{
    return [NSDate date]; // should return date data source was last changed
}

@end
