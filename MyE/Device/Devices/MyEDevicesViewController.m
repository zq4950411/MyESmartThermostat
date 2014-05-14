//
//  SmartUpViewController.m
//  MyE
//
//  Created by space on 13-8-6.
//  Copyright (c) 2013年 MyEnergy Domain. All rights reserved.
//

#import "MyEDevicesViewController.h"
#import "AddDeviceTableViewView.h"
//switch
#import "MyESwitchManualControlViewController.h"
#import "MyESwitchAutoViewController.h"
#import "MyESwitchElecInfoViewController.h"
//tv or audio
#import "MyEIrControlPageViewController.h"
//curtain
#import "MyECurtainControlViewController.h"

#import "MyEHouseData.h"

#import "MyEDevice.h"
#import "SWRevealViewController.h"

@implementation MyEDevicesViewController

#pragma mark - life circle methods

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    if (self.needRefresh) {
        self.needRefresh = NO;
        [self sendGetDatas];
    }
}

-(void) viewDidLoad
{
    [super viewDidLoad];
    self.mainDevice = [[MyEMainDevice alloc] init]; //初始化完毕，以备用
    self.parentViewController.navigationItem.title = @"Devices";
    [self sendGetDatas];
    
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
    
    //这里添加长按手势，以便进行排序，方便让tableview进入编辑模式
    UILongPressGestureRecognizer *tap = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
    [self.tableView addGestureRecognizer:tap];
    
    //初始化顶部视图，也就是加入下拉刷新功能
    [self initHeaderView:self];
    
    // Change button color
    _sidebarButton.tintColor = [UIColor colorWithWhite:0.36f alpha:0.82f];
    // Set the side bar button action. When it's tapped, it'll show up the sidebar.
    _sidebarButton.target = self.revealViewController;
    _sidebarButton.action = @selector(revealToggle:);
    
    // Set the gesture,主要是为了完成向右滑动打开菜单的功能
    [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
}

-(MyEDevice *) getCurrentSmartup
{
    return [self.datas safeObjectAtIndex:currentSelectedIndex];
}

#pragma mark - private methods
-(void) deviceControl:(UITapGestureRecognizer *) tap
{
    CGPoint hit = [tap.view convertPoint:CGPointZero toView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:hit];
    _selectedIndexPath = indexPath;
    MyEDevice *device = (MyEDevice *)self.datas[indexPath.row];
    if (device.typeId.intValue == 4 || device.typeId.intValue == 5) {
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
    
    self.isShowLoading = YES;
    //2:TV,  3: Audio, 4:Automated Curtain, 5: Other,  6 智能插座,7:通用控制器  8:开关
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    NSString *string = nil;
    [params safeSetObject:[NSString stringWithFormat:@"%d",MainDelegate.houseData.houseId] forKey:@"houseId"];
    if (device.typeId.intValue == 8) {  //switch
        [params safeSetObject:device.tid forKey:@"tId"];
        [params safeSetObject:@"1" forKey:@"action"];
        string = URL_FOR_SWITCH_CONTROL;
    }
    else if (device.typeId.intValue == 7){  //通用控制器
        [params safeSetObject:device.tid forKey:@"tId"];
        string = URL_FOR_UNIVERSAL_CONTROL_MANUEL_CONTROL;
    }
    else if (device.typeId.intValue == 6){  // socket
        [params safeSetObject:device.tid forKey:@"tId"];
    }
    else{
        [params safeSetObject:device.deviceId forKey:@"deviceId"];
        string = URL_FOR_IRDEVICE_CONTROL;
    }
    if (device.typeId.intValue == 2) {
        [params safeSetObject:@"203" forKey:@"switchStatus"];
    }else if(device.typeId.intValue == 3){
        [params safeSetObject:@"301" forKey:@"switchStatus"];
    }else
        [params safeSetObject:device.switchStatus.intValue==1?@"0":@"1" forKey:@"switchStatus"];
    [[NetManager sharedManager] requestWithURL:GetRequst(string) delegate:self withUserInfo:@{REQUET_PARAMS: params}];
}

-(void) sendGetDatas
{
    self.isShowLoading = YES;
    
    //    [MyEUniversal doThisWhenNeedUploadOrDownloadDataFromServerWithURL:URL_FOR_ROOMLIST_VIEW andUIViewController:self andDictionary:@{@"houseId": @(MainDelegate.houseData.houseId)}];
    [MyEUniversal doThisWhenNeedUploadOrDownloadDataFromServerWithURL:URL_FOR_SMARTUP_LIST2 andUIViewController:self andDictionary:@{@"houseId": @(MainDelegate.houseData.houseId)}];
    
}

-(void) moveWithDeviceId:(NSString *) deviceId andSortedId:(NSString *) sort
{
    self.isShowLoading = YES;
    [MyEUniversal doThisWhenNeedUploadOrDownloadDataFromServerWithURL:URL_FOR_SAVE_SORT andUIViewController:self andDictionary:@{@"houseId": @(MainDelegate.houseData.houseId),@"deviceId":deviceId,@"sortId":sort}];
}

-(void) deleteWithDeviceId:(NSString *) deviceId andHouseId:(int) houseId
{
    self.isShowLoading = YES;
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    
    [params safeSetObject:[NSString stringWithFormat:@"%d",MainDelegate.houseData.houseId] forKey:@"houseId"];
    [params safeSetObject:deviceId forKey:@"deviceId"];
    [params safeSetObject:@"deleteDevice" forKey:@"action"];
    
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:params,REQUET_PARAMS, nil];
    
    [[NetManager sharedManager] requestWithURL:GetRequst(URL_FOR_SAVE_DEVICE)
                                      delegate:self
                                  withUserInfo:dic];
}
-(void) edit:(UIButton *) sender
{
    //2:TV,  3: Audio, 4:Automated Curtain, 5: Other,  6 智能插座,7:通用控制器  8:开关
    CGPoint hit = [sender convertPoint:CGPointZero toView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:hit];
    currentTapIndex = indexPath.row;
    currentSelectedIndex = indexPath.row;
    MyEDevice *device = [self.datas objectAtIndex:indexPath.row];
    //    if (device.typeId.intValue == 2)  //TV
    //    {
    //        PlugControlViewController *plug = [[PlugControlViewController alloc] initWithEditType];
    //        [self.navigationController pushViewController:plug animated:YES];
    //    }
    if (device.typeId.intValue == 6)  //socket
    {
        UIStoryboard *story = [UIStoryboard storyboardWithName:@"Device" bundle:nil];
        MyEDeviceAddOrEditTableViewController *vc = [story instantiateViewControllerWithIdentifier:@"socketEdit"];
        vc.isAddDevice = NO;
        vc.device = device;
        [self.navigationController pushViewController:vc animated:YES];
        //        PlugControlViewController *plug = [[PlugControlViewController alloc] initWithEditType];
    }
    else if(device.typeId.intValue == 7)  //通用控制器
    {
    }
    else if(device.typeId.intValue == 8)  //switch
    {
        UIStoryboard *story = [UIStoryboard storyboardWithName:@"Switch" bundle:nil];
        MyESwitchEditViewController *vc = [story instantiateViewControllerWithIdentifier:@"switchEdit"];
        vc.device = device;
        [self.navigationController pushViewController:vc animated:YES];
    }
    else
    {
        UIStoryboard *story = [UIStoryboard storyboardWithName:@"Device" bundle:nil];
        MyEDeviceAddOrEditTableViewController *vc = [story instantiateViewControllerWithIdentifier:@"deviceAddOrEdit"];
        vc.isAddDevice = NO;
        vc.device = device;
        [self.navigationController pushViewController:vc animated:YES];
        
        //        AddDeviceTableViewView *vc = [[AddDeviceTableViewView alloc] init];
        //        vc.smartup = device;
        //
        //        [self.navigationController pushViewController:vc animated:YES];
    }
}
-(void) tap:(UILongPressGestureRecognizer *) tap
{
    if (tap.state == UIGestureRecognizerStateEnded)
    {
        [self.tableView setEditing:!self.tableView.editing animated:YES];
    }
}
-(void) refreshAction:(id) sender
{
    [self sendGetDatas];
}
-(NSString *)getDeviceTypeNameByTypeId:(NSString *)typeId{
    NSString *string = nil;
    switch (typeId.intValue) {
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
            string = @"uControl";
            break;
        case 8:
            string = @"switch";
            break;
        default:
            string = @"tv";
            break;
    }
    return string;
}
-(void)changeSwitchStatusImageView{
    MyEDevice *device = [self.datas safeObjectAtIndex:_selectedIndexPath.row];
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
-(void)reloadRoomsTableViewContents{
    
    [_roomsTableView reloadData];
    [_roomsTableView initTableViewDataSourceAndDelegate:^(UITableView *tableView,NSUInteger section){
        return [_mainDic.allKeys count];
        
    } setCellForIndexPathBlock:^(UITableView *tableview,NSIndexPath *indexPath){
        static NSString *cellIdetifier = @"cell";
        UITableViewCell *cell=[tableview dequeueReusableCellWithIdentifier:cellIdetifier];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdetifier];
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, tableview.frame.size.width, 35)];
            label.font = [UIFont systemFontOfSize:15];
            label.tag = 998;
            label.textAlignment = NSTextAlignmentCenter;
            [cell.contentView addSubview:label];
        }
        UILabel *label = (UILabel *)[cell.contentView viewWithTag:998];
        label.text = _mainDic.allKeys[indexPath.row];
        return cell;
    } setDidSelectRowBlock:^(UITableView *tableview,NSIndexPath *indexPath){
        UITableViewCell *cell=(UITableViewCell*)[tableview cellForRowAtIndexPath:indexPath];
        UILabel *label = (UILabel *)[cell.contentView viewWithTag:998];
        NSArray *array = _mainDic[label.text];
        self.datas = [NSMutableArray arrayWithArray:array];
        [self.tableView reloadData];
        [self.roomBtn sendActionsForControlEvents:UIControlEventTouchUpInside];   //这句代码的意思就是说让按钮的方法运行一遍，这个想法不错
    } beginEditingStyleForRowAtIndexPath :nil];
    _roomsTableView.tableFooterView = [[UIView alloc] init];
    [_roomsTableView.layer setBorderColor:[UIColor lightGrayColor].CGColor];
    [_roomsTableView.layer setBorderWidth:1];
}
-(void)refreshData{
    _mainDic = [NSMutableDictionary dictionary];
    NSMutableArray *array = [NSMutableArray array];
    NSMutableArray *array1 = [NSMutableArray array];
    [_mainDic setValue:self.mainDevice.devices forKey:@"All"];
    
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
    NSLog(@"_mainDic is %@",_mainDic);
}
#pragma mark - IBAction methods
- (IBAction)changeRoom:(UIButton *)sender {
    [self refreshData];
    if ([sender isSelected]) {   //isSelected 就是selected
        [UIView animateWithDuration:0.3 animations:^{
            //            UIImage *closeImage=[UIImage imageNamed:@"dropdown.png"];
            //            [_showBtn setImage:closeImage forState:UIControlStateNormal];
            CGRect frame=_roomsTableView.frame;
            frame.size.height=1;
            [_roomsTableView setFrame:frame];
        } completion:^(BOOL finished){
            _roomsTableView.hidden = YES;
            [sender setSelected:NO];
        }];
    }else{
        [UIView animateWithDuration:0.3 animations:^{
            //            UIImage *openImage=[UIImage imageNamed:@"dropup.png"];
            //            [_showBtn setImage:openImage forState:UIControlStateNormal];
            
            CGRect frame=_roomsTableView.frame;
            if ([_mainDic count] < 6 ) {
                frame.size.height = 35 * _mainDic.count;
            }else
                frame.size.height=150;
            [_roomsTableView setFrame:frame];
        } completion:^(BOOL finished){
            _roomsTableView.hidden = NO;
            [self reloadRoomsTableViewContents];
            [sender setSelected:YES];
        }];
    }
}
- (IBAction)editRoom:(UIButton *)sender {
    [self refreshData];
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
    return self.datas.count;
}

-(UITableViewCell *) tableView:(UITableView *)tv cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    if (cell == nil) {
        cell = [self.tableView dequeueReusableCellWithIdentifier:@"deviceCell" forIndexPath:indexPath];
    }
    MyEDevice *device = [self.datas objectAtIndex:indexPath.row];
    UIView *bgView = (UIView *)[cell.contentView viewWithTag:99];
    UIImageView *typeImageView = (UIImageView *)[cell.contentView viewWithTag:100];
    UILabel *nameLabel = (UILabel *)[cell.contentView viewWithTag:101];
    UILabel *roomLabel = (UILabel *)[cell.contentView viewWithTag:102];
    UIImageView *signal = (UIImageView *)[cell.contentView viewWithTag:103];
    UIButton *btn = (UIButton*)[cell.contentView viewWithTag:104];
    
    bgView.layer.cornerRadius = 4;
    //    bgView.layer.borderColor = [UIColor blackColor].CGColor;
    //    bgView.layer.borderWidth = 0.5;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(deviceControl:)];
    [typeImageView addGestureRecognizer:tap];
    typeImageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@-%@",[self getDeviceTypeNameByTypeId:device.typeId],device.switchStatus.intValue==0?@"off":@"on"]];
    nameLabel.text = device.deviceName;
    roomLabel.text = device.instructionName;
    signal.image = [UIImage imageNamed:device.rfStatus.intValue == -1?@"noconnection":[NSString stringWithFormat:@"signal%i",device.rfStatus.intValue]];
    [btn addTarget:self action:@selector(edit:) forControlEvents:UIControlEventTouchUpInside];
    return cell;
}

#pragma mark - UITableView delegate methods
-(void) tableView:(UITableView *)table didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    MyEDevice *device = [self.datas objectAtIndex:indexPath.row];
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
    
    //UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithTitle:@"Smart-Up" style:UIBarButtonItemStyleBordered target:nil action:nil];
    //[self.parentViewController.navigationItem setBackBarButtonItem:backItem];
    
    currentSelectedIndex = indexPath.row;
    //2:TV,  3: Audio, 4:Automated Curtain, 5: Other,  6 智能插座,7:通用控制器  8:开关
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
    }else if (device.typeId.intValue == 6)  //插座
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
        
        UINavigationController *nc2 = [[tabBarController childViewControllers] objectAtIndex:2];
        MyESwitchElecInfoViewController *elecInfoVC = [[nc2 childViewControllers] objectAtIndex:0];
        elecInfoVC.device = device;
        [self presentViewController:tabBarController animated:YES completion:nil];
    }
}
-(BOOL) tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

-(BOOL) tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

-(void) tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@""
                                                            message:@"Deleting this device will also remove all settings associated with it. Are you sure to do so?"
                                                           delegate:self
                                                  cancelButtonTitle:@"YES"
                                                  otherButtonTitles:@"NO"
                                  , nil];
        alertView.tag = indexPath.row;
        [alertView show];
    }
}
// 可选，对那些被移动栏格作特定操作
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
    if (fromIndexPath.row == toIndexPath.row)
    {
        return;
    }
    MyEDevice *smart = [self.datas objectAtIndex:fromIndexPath.row];
    [self moveWithDeviceId:smart.deviceId andSortedId:[NSString stringWithFormat:@"%d",toIndexPath.row]];
}

#pragma mark - network delegate methods
-(void) netFinish:(id) jsonString withUserInfo:(NSDictionary *) userInfo andURL:(NSString *) u
{
    [self headerFinish];
    NSLog(@"%@\n%@\n%@",jsonString,u,userInfo);
    if ([u rangeOfString:URL_FOR_SMARTUP_LIST2].location != NSNotFound)
    {
        MyEMainDevice *main = [[MyEMainDevice alloc] initWithJSONString:jsonString];
        self.mainDevice = main;
        self.datas = self.mainDevice.devices;
        [self.tableView reloadData];
    }
    else if ([u rangeOfString:URL_FOR_SAVE_SORT].location != NSNotFound)
    {
        
        if([jsonString isEqualToString:@"OK"])
        {
            [SVProgressHUD showSuccessWithStatus:@"Successs"];
        }
        else
        {
            [SVProgressHUD showSuccessWithStatus:@"Error"];
        }
        [self.tableView setEditing:NO];
    }
    else if ([u rangeOfString:URL_FOR_SWITCH_CONTROL].location != NSNotFound)   //Switch Control
    {
        if ([@"OK" isEqualToString:jsonString])
        {
            [self changeSwitchStatusImageView];
        }
        else if ([jsonString isEqualToString:@"-999"]){
            [SVProgressHUD showWithStatus:@"No Connection"];
        }
        else
        {
            [SVProgressHUD showErrorWithStatus:@"Error!"];
        }
    }
    else if ([MyEUniversal requstString:u hasURLString:URL_FOR_IRDEVICE_CONTROL]){  //irDevice Control
        if ([jsonString isEqualToString:@"OK"]) {
            [self changeSwitchStatusImageView];
        }else if ([jsonString isEqualToString:@"-999"]){
            [SVProgressHUD showWithStatus:@"No Connection"];
        }else
            [SVProgressHUD showErrorWithStatus:@"Error!"];
        
    }
    else if ([MyEUniversal requstString:u hasURLString:URL_FOR_UNIVERSAL_CONTROL_MANUEL_CONTROL]){ //universal control
        if ([jsonString isEqualToString:@"OK"]) {
            [self changeSwitchStatusImageView];
        }else if ([jsonString isEqualToString:@"-999"]){
            [SVProgressHUD showWithStatus:@"No Connection"];
        }else
            [SVProgressHUD showErrorWithStatus:@"Error!"];
    }
    else if ([u rangeOfString:URL_FOR_SMARTUP_PlUG_CONTROL].location != NSNotFound)  //socket control
    {
        if ([@"OK" isEqualToString:jsonString])
        {
            [self changeSwitchStatusImageView];
        }
        else if ([jsonString isEqualToString:@"-999"]){
            [SVProgressHUD showWithStatus:@"No Connection"];
        }
        else
        {
            [SVProgressHUD showErrorWithStatus:@"Error!"];
        }
    }
    else if ([u rangeOfString:URL_FOR_SAVE_DEVICE].location != NSNotFound)
    {
        if([jsonString isEqualToString:@"OK"])
        {
            [self.datas safeRemovetAtIndex:currentSelectedIndex];
            [self.tableView reloadData];
            [SVProgressHUD showSuccessWithStatus:@"Successs"];
        }
        else
        {
            [SVProgressHUD showSuccessWithStatus:@"Error"];
        }
        [self.tableView setEditing:NO];
    }
    
}

-(void) netError:(id)errorMsg withUserInfo:(NSDictionary *)userInfo andURL:(NSString *) u
{
    if ([u rangeOfString:URL_FOR_SMARTUP_LIST].location != NSNotFound)
    {
        
    }
    else if ([u rangeOfString:URL_FOR_SAVE_SORT].location != NSNotFound)
    {
        [self.tableView setEditing:NO];
    }
    else if ([u rangeOfString:URL_FOR_SMARTUP_PlUG_CONTROL].location != NSNotFound)
    {
        
    }
    else if ([u rangeOfString:URL_FOR_SAVE_DEVICE].location != NSNotFound)
    {
        
    }
}

#pragma mark - UIAlertView delegate methods
-(void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0)
    {
        MyEDevice *smartUP = (MyEDevice *)[self.datas safeObjectAtIndex:alertView.tag];
        currentSelectedIndex = alertView.tag;
        
        [self deleteWithDeviceId:smartUP.deviceId andHouseId:MainDelegate.houseData.houseId];
    }
}

@end
