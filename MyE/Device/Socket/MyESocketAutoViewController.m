//
//  MyESocketAutoViewController.m
//  MyE
//
//  Created by 翟强 on 14-4-24.
//  Copyright (c) 2014年 MyEnergy Domain. All rights reserved.
//

#import "MyESocketAutoViewController.h"

@interface MyESocketAutoViewController ()
{
    MBProgressHUD *HUD;
}
@end

@implementation MyESocketAutoViewController

#pragma mark - life Circle methods
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self uploadOrDownloadInfoFromServerWithURL:[NSString stringWithFormat:@"%@?houseId=%i&tId=%@",GetRequst(URL_FOR_SOCKET_GET_SCHEDULELIST),MainDelegate.houseData.houseId,self.device.tid] andName:@"downloadInfo"];
}
#pragma mark - IBAction methods
- (IBAction)controlChange:(UISegmentedControl *)sender {
    [self uploadOrDownloadInfoFromServerWithURL:[NSString stringWithFormat:@"%@?houseId=%i&tId=%@&autoMode=%i",GetRequst(URL_FOR_SAVE_SOCKET_AUTO),MainDelegate.houseData.houseId,self.device.tid,1-sender.selectedSegmentIndex] andName:@"control"];
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}
#pragma mark - table view dataSource
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.schedules.schedules count];
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"scheduleCell" forIndexPath:indexPath];
    MyESocketSchedule *schedule = self.schedules.schedules[indexPath.row];
    UILabel *lblTime = (UILabel *)[cell.contentView viewWithTag:200];
    UISwitch *controlSwitch = (UISwitch *)[cell.contentView viewWithTag:201];
    MYEWeekButtons *weekBtns = (MYEWeekButtons *)[cell.contentView viewWithTag:202];
    lblTime.text = [NSString stringWithFormat:@"%@-%@",schedule.onTime,schedule.offTime];
    [controlSwitch setOn:schedule.runFlag animated:YES];
    weekBtns.selectedButtons = schedule.weeks;
    return cell;
}
#pragma mark - URL DELEGATE methods
-(void)didReceiveString:(NSString *)string loaderName:(NSString *)name userDataDictionary:(NSDictionary *)dict{
    NSLog(@"receive string is %@",string);
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
            
        }else{
            [SVProgressHUD showErrorWithStatus:@"Error!"];
        }
    }
}
-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error loaderName:(NSString *)name{
    NSLog(@"%@",[error localizedDescription]);
}
@end
