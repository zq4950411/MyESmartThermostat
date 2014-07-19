//
//  MyESwitchAutoViewController.m
//  MyEHomeCN2
//
//  Created by 翟强 on 14-3-6.
//  Copyright (c) 2014年 My Energy Domain Inc. All rights reserved.
//

#import "MyESwitchAutoViewController.h"

@interface MyESwitchAutoViewController (){
    NSIndexPath *_selectIndex;
    EGORefreshTableHeaderView *_refreshHeaderView;
    BOOL _isRefreshing;
}

@end

@implementation MyESwitchAutoViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self doThisWhenNeedDownLoadOrUploadInfoWithURLString:[NSString stringWithFormat:@"%@?houseId=%li&tId=%@",GetRequst(URL_FOR_SWITCH_SCHEDULE_LIST),(long)MainDelegate.houseData.houseId, self.device.tid] andName:@"scheduleList"];
    UIView *bgView = [[UIView alloc] init];
    bgView.backgroundColor = [UIColor clearColor];
    self.tableView.tableFooterView = bgView;
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
    [btn setFrame:CGRectMake(0, 0, 50, 30)];
    [btn setBackgroundImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
    if (!IS_IOS6) {
        [btn setTitleEdgeInsets:UIEdgeInsetsMake(0, 20, 0, 0)];
    }    
    [btn addTarget:self action:@selector(dismissVC) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btn];
    if (!_refreshHeaderView) {
        EGORefreshTableHeaderView *view = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - self.tableView.bounds.size.height, self.tableView.frame.size.width, self.tableView.bounds.size.height)];
        view.delegate = self;
        [self.tableView addSubview:view];
        _refreshHeaderView = view;
    }
    [_refreshHeaderView refreshLastUpdatedDate];   //更新最新时间
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    [self.tableView reloadData];
    //这里这个刷新是为了使得二者不要发生冲突
    if (self.needRefresh) {
        self.needRefresh = NO;
        [self doThisWhenNeedDownLoadOrUploadInfoWithURLString:[NSString stringWithFormat:@"%@?houseId=%li&tId=%@",GetRequst(URL_FOR_SWITCH_SCHEDULE_LIST),(long)MainDelegate.houseData.houseId, self.device.tid] andName:@"scheduleList"];
    }
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}
#pragma mark - IBAction methods
- (IBAction)enableProcess:(UISwitch *)sender {
    CGPoint hit = [sender convertPoint:CGPointZero toView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:hit];
    _selectIndex = indexPath;
    NSLog(@"index is %i",indexPath.row);
    MyESwitchSchedule *_scheduleNew = self.control.SSList[indexPath.row];
    [self doThisWhenNeedDownLoadOrUploadInfoWithURLString:[NSString stringWithFormat:@"%@?houseId=%li&tId=%@&channels=%@&action=2",GetRequst(URL_FOR_SWITCH_TIME_DELAY),(long)MainDelegate.houseData.houseId, self.device.tid,[_scheduleNew.channels componentsJoinedByString:@","]] andName:@"check"];
}
#pragma mark - private methods
-(void)dismissVC{
    [self dismissViewControllerAnimated:YES completion:nil];
}
-(void)doThisWhenNeedDownLoadOrUploadInfoWithURLString:(NSString *)url andName:(NSString *)name{
    if (HUD == nil) {
        HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    }
    [HUD show:YES];
    MyEDataLoader *loader = [[MyEDataLoader alloc] initLoadingWithURLString:url postData:nil delegate:self loaderName:name userDataDictionary:nil];
    NSLog(@"%@ is %@",name,loader.name);
}
-(void)uploadInfoToServer{
    MyESwitchSchedule *_scheduleNew = self.control.SSList[_selectIndex.row];
    [self doThisWhenNeedDownLoadOrUploadInfoWithURLString:[NSString stringWithFormat:@"%@?houseId=%li&tId=%@&deviceId=%i&scheduleId=%li&onTime=%@&offTime=%@&channels=%@&weeks=%@&runFlag=%i&action=2",GetRequst(URL_FOR_SWITCH_SCHEDULE_SAVE),
                                                           (long)MainDelegate.houseData.houseId, self.device.tid,[self.device.deviceId intValue],
                                                           (long)_scheduleNew.scheduleId,
                                                           _scheduleNew.onTime,
                                                           _scheduleNew.offTime,
                                                           [_scheduleNew.channels componentsJoinedByString:@","],
                                                           [_scheduleNew.weeks componentsJoinedByString:@","],1-_scheduleNew.runFlag] andName:@"scheduleEdit"];
}
#pragma mark - UITableView delegate methods
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.control.SSList.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    MyEScheduleCell *cell = [tableView dequeueReusableCellWithIdentifier:@"scheduleCell" forIndexPath:indexPath];
    UIView *bgView = (UIView *)[cell.contentView viewWithTag:1024];
    bgView.layer.cornerRadius = 4;
    MyESwitchSchedule *schedule = self.control.SSList[indexPath.row];
    cell.maxChannel = self.control.numChannel;
    cell.time = [NSString stringWithFormat:@"%@-%@",schedule.onTime,schedule.offTime];
    cell.isOn = schedule.runFlag == 1?YES:NO;
    cell.weeks = schedule.weeks;
    cell.channels = schedule.channels;
    return cell;
}
#pragma mark - UITableView delegate methods
-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    _selectIndex = indexPath;
    DXAlertView *alert = [[DXAlertView alloc] initWithTitle:@"Alert" contentText:@"Do you want to delete this schedule?" leftButtonTitle:@"NO" rightButtonTitle:@"YES"];
    alert.rightBlock = ^{
        MyESwitchSchedule *_scheduleNew = self.control.SSList[indexPath.row];
        [self doThisWhenNeedDownLoadOrUploadInfoWithURLString:[NSString stringWithFormat:@"%@?houseId=%li&tId=%@&deviceId=%i&scheduleId=%li&action=3",GetRequst(URL_FOR_SWITCH_SCHEDULE_SAVE),
                                                               (long)MainDelegate.houseData.houseId, self.device.tid,[self.device.deviceId intValue],
                                                               (long)_scheduleNew.scheduleId] andName:@"delete"];
    };
    [alert show];
}
#pragma mark - navigation methods
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    MyESwitchScheduleSettingViewController *vc = segue.destinationViewController;
    vc.device = self.device;
    vc.control = self.control;
    if ([segue.identifier isEqualToString:@"add"]) {
        vc.actionType = 1;  //表示新增进程
        vc.schedule = [[MyESwitchSchedule alloc] init];
    }else{
        vc.actionType = 2; //表示编辑进程
        vc.schedule = self.control.SSList[[self.tableView indexPathForCell:sender].row];
    }
}
#pragma mark - url delegate methods
-(void)didReceiveString:(NSString *)string loaderName:(NSString *)name userDataDictionary:(NSDictionary *)dict{
    NSLog(@"receive string is %@",string);
    [HUD hide:YES];
    if (_isRefreshing) {
        _isRefreshing = NO;
        [_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:self.tableView];
    }
    if ([name isEqualToString:@"scheduleEdit"]) {
        if ([string isEqualToString:@"OK"]) {
            UINavigationController *nav = self.tabBarController.childViewControllers[0];
            MyESwitchManualControlViewController *vc = nav.childViewControllers[0];
            vc.needRefresh = YES;
             MyESwitchSchedule *schedule = self.control.SSList[_selectIndex.row];
            schedule.runFlag = 1 - schedule.runFlag;
        }else{
            [SVProgressHUD showErrorWithStatus:@"fail"];
        }
        [self.tableView reloadData]; //这个是精髓
    }
    if ([name isEqualToString:@"delete"]) {
        if ([string isEqualToString:@"OK"]) {
            [self.control.SSList removeObjectAtIndex:_selectIndex.row];
            [self.tableView deleteRowsAtIndexPaths:@[_selectIndex] withRowAnimation:UITableViewRowAnimationAutomatic];
        }else
            [SVProgressHUD showErrorWithStatus:@"fail"];
    }
    if ([name isEqualToString:@"scheduleList"]) {
        if (![string isEqualToString:@"fail"]) {
            MyESwitchAutoControl *control = [[MyESwitchAutoControl alloc] initWithString:string];
            self.control = control;
            [self.tableView reloadData];
        }else {
            [MyEUtil showMessageOn:nil withMessage:@"Failed to download auto process data"];
        }
    }
    if ([name isEqualToString:@"check"]) {
        NSLog(@"check string is %@",string);
        if (![string isEqualToString:@"fail"]) {
            SBJsonParser *parser = [[SBJsonParser alloc] init];
            NSDictionary *dict = [parser objectWithString:string];
            int isMutex = [[dict objectForKey:@"isMutex"] intValue];
            
            if(isMutex == 1){
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Alert" message:@"A timer has been set for this switch. To enable the auto mode, the timer will be disabled. Do you want to continue?" delegate:self cancelButtonTitle:@"NO" otherButtonTitles:@"YES", nil];
                alert.tag = 900;
                [alert show];
            }else if(isMutex == 2){
                [self uploadInfoToServer];
            }else
                [MyEUtil showMessageOn:nil withMessage:[NSString stringWithFormat:@"Wrong code:%i from server",isMutex]];
        }else {
            [MyEUtil showMessageOn:nil withMessage:@"Failed to communicate with server"];
        }
    }
}
-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error loaderName:(NSString *)name{
    [HUD hide:YES];
    [SVProgressHUD showErrorWithStatus:@"Connection Fail"];
}

#pragma mark - UIAlertView Delegate methods
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (alertView.tag == 900) {
        if (buttonIndex == 1) {
            [self uploadInfoToServer];
        }else
            [self.tableView reloadData];
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
    [self doThisWhenNeedDownLoadOrUploadInfoWithURLString:[NSString stringWithFormat:@"%@?houseId=%li&tId=%@",GetRequst(URL_FOR_SWITCH_SCHEDULE_LIST),(long)MainDelegate.houseData.houseId, self.device.tid] andName:@"scheduleList"];
}
- (NSDate*)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView*)view{
    return [NSDate date]; // should return date data source was last changed
}
@end
