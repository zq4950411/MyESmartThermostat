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
    NSIndexPath *_deleteIndexPath;  //记录删除的行
    UISwitch *_controlSwitch;  //记录进行控制的switch
}
@end

@implementation MyESocketAutoViewController

#pragma mark - life Circle methods
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    [self.tableView reloadData];
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
}
#pragma mark - IBAction methods
- (IBAction)controlChange:(UISwitch *)sender {
    _controlSwitch = sender;
    CGPoint hit = [sender convertPoint:CGPointZero toView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:hit];
    NSLog(@"当前选定的行是 %i",indexPath.row);
    MyESocketSchedule *schedule = self.schedules.schedules[indexPath.row];
    [self uploadOrDownloadInfoFromServerWithURL:[NSString stringWithFormat:@"%@?houseId=%i&tId=%@&deviceId=%@&scheduleId=%i&onTime=%@&offTime=%@&weeks=%@&runFlag=%i&action=2",GetRequst(URL_FOR_SOCKET_SAVE_PLUG_SCHEDULE),MainDelegate.houseData.houseId,self.device.tid,self.device.deviceId,schedule.scheduleId,schedule.onTime,schedule.offTime,[schedule.weeks componentsJoinedByString:@","],schedule.runFlag] andName:@"control"];
}

#pragma mark - private methods
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
    cell.isOn = schedule.runFlag == 1?YES:NO;
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
            [_controlSwitch setOn:!_controlSwitch.isOn animated:YES];   //没有成功的话要将switch还原
        }else if (string.intValue == -501){
            [SVProgressHUD showWithStatus:@"No Schedule"];
            [_controlSwitch setOn:!_controlSwitch.isOn animated:YES];
        }else if (![string isEqualToString:@"fail"]){
            
        }else{
            [SVProgressHUD showErrorWithStatus:@"Error!"];
            [_controlSwitch setOn:!_controlSwitch.isOn animated:YES];
        }
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
}
-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error loaderName:(NSString *)name{
    NSLog(@"%@",[error localizedDescription]);
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
@end
