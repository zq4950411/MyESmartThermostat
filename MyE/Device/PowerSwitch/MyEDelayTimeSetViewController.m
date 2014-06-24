//
//  MyEDelayTimeSetViewController.m
//  MyEHomeCN2
//
//  Created by 翟强 on 14-3-5.
//  Copyright (c) 2014年 My Energy Domain Inc. All rights reserved.
//

#import "MyEDelayTimeSetViewController.h"

@interface MyEDelayTimeSetViewController ()

@end

@implementation MyEDelayTimeSetViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    _selectedRow = 61;  //对该值进行初始化
    _tableArray = [NSMutableArray arrayWithCapacity:60];
    for (int i = 1; i <= 60; i++) {
        [_tableArray addObject:[NSString stringWithFormat:@"%i Minute(s)",i]];  //可变数组在使用前一定要先初始化
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}
#pragma mark - IBAction methods
- (IBAction)submitResult:(id)sender {
//    if ([self.timeValueLabel.text intValue] < 5) {
//        [MyEUtil showInstructionStatusWithYes:YES andView:self.navigationController.navigationBar andMessage:@"延时时间不能小于5分钟"];
//        return;
//    }
    [self doThisWhenNeedDownLoadOrUploadInfoWithURLString:[NSString stringWithFormat:@"%@?houseId=%li&tId=%@&channels=%@&action=1",GetRequst(URL_FOR_SWITCH_TIME_DELAY),(long)MainDelegate.houseData.houseId,self.device.tid,[NSString stringWithFormat:@"%i",self.index.row+1]] andName:@"checkIfRight"];
}
- (IBAction)cancel:(id)sender {
    [self mz_dismissFormSheetControllerAnimated:YES completionHandler:nil];
}
#pragma mark - private methods
-(void)doThisWhenNeedDownLoadOrUploadInfoWithURLString:(NSString *)url andName:(NSString *)name{
    if (HUD == nil) {
        HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    }
    [HUD show:YES];
    NSLog(@"%@ string is %@",name,url);
    MyEDataLoader *loader = [[MyEDataLoader alloc] initLoadingWithURLString:url postData:nil delegate:self loaderName:name userDataDictionary:nil];
    NSLog(@"%@ is %@",name,loader.name);
}
-(void)doThisToChangeStatus{
    self.status.delayStatus = 1;
    [self doThisWhenNeedDownLoadOrUploadInfoWithURLString:[NSString stringWithFormat:@"%@?houseId=%li&tId=%@&allChannel=%@",GetRequst(URL_FOR_SWITCH_TIME_DELAY_SAVE),(long)MainDelegate.houseData.houseId,self.device.tid,[[MyESwitchChannelStatus alloc] jsonStringWithStatus:self.status]] andName:@"uploadDelayInfo"];
}
#pragma mark - url delegate Methods
-(void)didReceiveString:(NSString *)string loaderName:(NSString *)name userDataDictionary:(NSDictionary *)dict{
    [HUD hide:YES];
    if([name isEqualToString:@"checkIfRight"]){
        NSLog(@"checkIfRight string is %@",string);
        if (![string isEqualToString:@"fail"]) {
            SBJsonParser *parser = [[SBJsonParser alloc] init];
            NSDictionary *dict = [parser objectWithString:string];
            if([[dict objectForKey:@"isMutex"] intValue] == 1){
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Alert" message:@"There are conflict in Delay setting and timing setting of current lights, sure to continue?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
                alert.tag = 999;
                [alert show];
            } else [self doThisToChangeStatus];
        } else {
            [MyEUtil showMessageOn:nil withMessage:@"Failed to communicate with server."];
        }
    }
    if ([name isEqualToString:@"uploadDelayInfo"]) {
        NSLog(@"uploadDelayInfo string is %@",string);
        if (![string isEqualToString:@"fail"]) {
            self.selectedBtnIndex = 100;
            [self mz_dismissFormSheetControllerAnimated:YES completionHandler:nil];
        }else {
            [MyEUtil showMessageOn:nil withMessage:@"Failed to communicate with server."];
        }
    }
}
-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error loaderName:(NSString *)name{
    [HUD hide:YES];
    [SVProgressHUD showErrorWithStatus:@"Connection Fail"];
}
#pragma mark - UITableView dataSource methods
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [_tableArray count];
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.textLabel.text = _tableArray[indexPath.row];
    if (indexPath.row == _selectedRow) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    return cell;
}
#pragma mark - UITableView delegate methods
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    _selectedRow = indexPath.row;
    self.status.delayMinute = indexPath.row+1;
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [tableView reloadData];
}
//- (UITableViewCellAccessoryType)tableView:(UITableView *)tableView accessoryTypeForRowWithIndexPath:(NSIndexPath *)indexPath
//{
//    int  row  = [indexPath row];
//    if(row == _selectedRow)
//        return UITableViewCellAccessoryCheckmark;
//    return UITableViewCellAccessoryNone;
//}
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (alertView.tag == 999 && buttonIndex == 1) {
        [self doThisToChangeStatus];
    }else
        [self mz_dismissFormSheetControllerAnimated:YES completionHandler:nil];
}
@end
