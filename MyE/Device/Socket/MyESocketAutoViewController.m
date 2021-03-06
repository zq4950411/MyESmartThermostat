//
//  MyESocketAutoViewController.m
//  MyE
//
//  Created by 翟强 on 14-4-24.
//  Copyright (c) 2014年 MyEnergy Domain. All rights reserved.
//

#import "MyESocketAutoViewController.h"
#import "MyESocketScheduleAddOrEditViewController.h"

@interface MyESocketAutoViewController ()
{
    MBProgressHUD *HUD;
    NSIndexPath *_deleteIndexPath;  //记录正在操作（选定和删除）的行
    EGORefreshTableHeaderView *_refreshHeaderView;
    BOOL _isRefreshing;
}
@end

@implementation MyESocketAutoViewController

#pragma mark - life Circle methods
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    [self.tableView reloadData];
    if (self.needRefresh) {
        self.needRefresh = NO;
        [self uploadOrDownloadInfoFromServerWithURL:[NSString stringWithFormat:@"%@?houseId=%i&tId=%@",GetRequst(URL_FOR_SOCKET_GET_SCHEDULELIST),MainDelegate.houseData.houseId,self.device.tid] andName:@"downloadInfo"];
    }
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
    [btn setFrame:CGRectMake(0, 0, 50, 30)];
    [btn setBackgroundImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
    if (!IS_IOS6) {
        [btn setTitleEdgeInsets:UIEdgeInsetsMake(0, 20, 0, 0)];
    }    
    [btn addTarget:self action:@selector(dismissVC) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btn];

    [self uploadOrDownloadInfoFromServerWithURL:[NSString stringWithFormat:@"%@?houseId=%i&tId=%@",GetRequst(URL_FOR_SOCKET_GET_SCHEDULELIST),MainDelegate.houseData.houseId,self.device.tid] andName:@"downloadInfo"];
    if (!_refreshHeaderView) {
        EGORefreshTableHeaderView *view = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - self.tableView.bounds.size.height, self.tableView.frame.size.width, self.tableView.bounds.size.height)];
        view.delegate = self;
        [self.tableView addSubview:view];
        _refreshHeaderView = view;
    }
    [_refreshHeaderView refreshLastUpdatedDate];   //更新最新时间
}
#pragma mark - IBAction methods
- (IBAction)controlChange:(UISwitch *)sender {
    CGPoint hit = [sender convertPoint:CGPointZero toView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:hit];
    _deleteIndexPath = indexPath; //这里是借用了这个变量
    NSLog(@"当前选定的行是 %i",indexPath.row);
    [self uploadOrDownloadInfoFromServerWithURL:[NSString stringWithFormat:@"%@?houseId=%i&tId=%@&action=2",GetRequst(URL_FOR_SOCKET_MUTEX_DELAY),MainDelegate.houseData.houseId,self.device.tid] andName:@"check"];
}

#pragma mark - private methods
-(void)uploadThingsToServer{
    if (HUD == nil) {
        HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    }else
        [HUD show:YES];
    MyESocketSchedule *schedule = self.schedules.schedules[_deleteIndexPath.row];
    [self uploadOrDownloadInfoFromServerWithURL:[NSString stringWithFormat:@"%@?houseId=%i&tId=%@&deviceId=%@&scheduleId=%i&onTime=%@&offTime=%@&weeks=%@&runFlag=%i&action=2",GetRequst(URL_FOR_SOCKET_SAVE_PLUG_SCHEDULE),MainDelegate.houseData.houseId,self.device.tid,self.device.deviceId,schedule.scheduleId,schedule.onTime,schedule.offTime,[schedule.weeks componentsJoinedByString:@","],1-schedule.runFlag] andName:@"control"];
}
-(void)uploadOrDownloadInfoFromServerWithURL:(NSString *)url andName:(NSString *)name{
    if (HUD == nil) {
        HUD = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    }
    [HUD show:YES];
    MyEDataLoader *loader = [[MyEDataLoader alloc] initLoadingWithURLString:url postData:nil delegate:self loaderName:name userDataDictionary:nil];
    NSLog(@"loader is %@",loader.name);
}
-(void)dismissVC{
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}
#pragma mark - table view dataSource
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.schedules.schedules count];
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    MyEScheduleCell *cell = [tableView dequeueReusableCellWithIdentifier:@"scheduleCell" forIndexPath:indexPath];
    MyESocketSchedule *schedule = self.schedules.schedules[indexPath.row];
    UIView *view = (UIView *)[cell.contentView viewWithTag:999];
    cell.time = [NSString stringWithFormat:@"%@-%@",schedule.onTime,schedule.offTime];
    cell.isOn = schedule.runFlag == 1;
    cell.weeks = schedule.weeks;
    view.layer.cornerRadius = 4;
    return cell;
}
-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    _deleteIndexPath = indexPath;
    MyESocketSchedule *schedule = self.schedules.schedules[indexPath.row];
    DXAlertView *alert = [[DXAlertView alloc] initWithTitle:@"Alert" contentText:@"Are you sure to delete this schedule?" leftButtonTitle:@"Cancle" rightButtonTitle:@"OK"];
    alert.rightBlock = ^{
        [self uploadOrDownloadInfoFromServerWithURL:[NSString stringWithFormat:@"%@?houseId=%i&tId=%@&deviceId=%@&scheduleId=%i&runFlag=%i&action=3",GetRequst(URL_FOR_SOCKET_SAVE_PLUG_SCHEDULE),MainDelegate.houseData.houseId,self.device.tid,self.device.deviceId,schedule.scheduleId,schedule.runFlag] andName:@"delete"];
    };
    [alert show];
}
#pragma mark - URL DELEGATE methods
-(void)didReceiveString:(NSString *)string loaderName:(NSString *)name userDataDictionary:(NSDictionary *)dict{
    NSLog(@"receive string is %@",string);
    [HUD hide:YES];
    if (_isRefreshing) {
        _isRefreshing = NO;
        [_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:self.tableView];
    }
    if ([name isEqualToString:@"downloadInfo"]) {
        if (string.intValue == -999) {
            [SVProgressHUD showWithStatus:@"No Connection"];
        }else if(![string isEqualToString:@"fail"]){
            MyESocketSchedules *schedules = [[MyESocketSchedules alloc] initWithJSONString:string];
            self.schedules = schedules;
            [self.tableView reloadData];
        }else
            [SVProgressHUD showErrorWithStatus:@"Error!"];
    }
    if ([name isEqualToString:@"control"]) {
        if (string.intValue == -999) {
            [SVProgressHUD showWithStatus:@"No Connection"];
        }else if (string.intValue == -501){
            [SVProgressHUD showWithStatus:@"No Schedule"];
        }else if (![string isEqualToString:@"fail"]){
            UINavigationController *nav = self.tabBarController.childViewControllers[0];
            MyESocketManualViewController *vc = nav.childViewControllers[0];
            vc.needRefresh = YES;
            MyESocketSchedule *schedule = self.schedules.schedules[_deleteIndexPath.row];
            schedule.runFlag = 1-schedule.runFlag;
        }else{
            [SVProgressHUD showErrorWithStatus:@"Error!"];
        }
        [self.tableView reloadData]; //之前是要记录操作的是哪个switch，现在不用担心这个了
    }
    if ([name isEqualToString:@"delete"]) {
        if (string.intValue == -999) {
            [SVProgressHUD showWithStatus:@"No Connection"];
        }else if ([string isEqualToString:@"OK"]){
            [self.schedules.schedules removeObjectAtIndex:_deleteIndexPath.row];
            [self.tableView deleteRowsAtIndexPaths:@[_deleteIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        }else
            [SVProgressHUD showErrorWithStatus:@"Error!"];
    }
    if ([name isEqualToString:@"check"]) {
        if ([string isEqualToString:@"fail"]) {
            [HUD hide:YES];
            [SVProgressHUD showErrorWithStatus:@"Error!"];
        }else{
            NSDictionary *dic = [string JSONValue];
            NSInteger result = [dic[@"isMutex"] intValue];
            if (result == 1) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Alert" message:@"A timer has been set for this plug. To enable the auto mode, the timer will be disabled. Do you want to continue?" delegate:self cancelButtonTitle:@"NO" otherButtonTitles:@"YES", nil];
                alert.tag = 900;
                [alert show];
            }else{
                [self uploadThingsToServer];
            }
        }
    }
}
-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error loaderName:(NSString *)name{
    [HUD hide:YES];
    [SVProgressHUD showErrorWithStatus:@"Connection Fail"];
}
#pragma mark - Navigation methods
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    MyESocketScheduleAddOrEditViewController *vc = segue.destinationViewController;
    vc.device = self.device;
    if ([segue.identifier isEqualToString:@"addSchedule"]) {
        MyESocketSchedule *schedule = [[MyESocketSchedule alloc] init];
        vc.schedule = schedule;
        vc.schedules = self.schedules;
        vc.isAdd = YES;
    }
    if ([segue.identifier isEqualToString:@"editSchedule"]) {
        MyESocketSchedule *schedule = self.schedules.schedules[[self.tableView indexPathForCell:sender].row];
        vc.schedule = schedule;
        vc.schedules = self.schedules;
        vc.isAdd = NO;
    }
}
#pragma mark - UIAlertView delegate methods
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (alertView.tag == 900) {
        if (buttonIndex == 1) {
            [self uploadThingsToServer];
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
    [self uploadOrDownloadInfoFromServerWithURL:[NSString stringWithFormat:@"%@?houseId=%i&tId=%@",GetRequst(URL_FOR_SOCKET_GET_SCHEDULELIST),MainDelegate.houseData.houseId,self.device.tid] andName:@"downloadInfo"];
}
- (NSDate*)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView*)view{
    return [NSDate date]; // should return date data source was last changed
}

@end
