//
//  MyEAcUserModelControlViewController.m
//  MyEHome
//
//  Created by Ye Yuan on 10/9/13.
//  Copyright (c) 2013 My Energy Domain Inc. All rights reserved.
//

#import "MyEAcUserModelViewController.h"

#define AC_CONTROL_UPLOADER_NMAE @"AcControlUploader"

@interface MyEAcUserModelViewController (){
    NSMutableArray *_data;
    MyEDeviceStatus *_status;
}

@end

@implementation MyEAcUserModelViewController
@synthesize accountData, device;
#pragma mark - life circle methods
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

    self.tableView.tableFooterView = [[UIView alloc] init];
    self.tableView.tableFooterView.backgroundColor = [UIColor clearColor];
    [self downloadInstructionSetFromServer];
    [self downloadTemperatureHumidityFromServer];
    timerToRefreshTemperatureAndHumidity = [NSTimer scheduledTimerWithTimeInterval:600 target:self selector:@selector(downloadTemperatureHumidityFromServer) userInfo:nil repeats:YES];
}
-(void)viewWillDisappear:(BOOL)animated{
    [timerToRefreshTemperatureAndHumidity invalidate];
}
#pragma mark - private methods
- (void)dismissVC{
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (IBAction)refreshTemperatureAndHumidity:(UIBarButtonItem *)sender {
    [self downloadTemperatureHumidityFromServer];
}
-(void)refreshUI{
    [_humidityLabel setText:[NSString stringWithFormat:@"%li%%", (long)_status.humidity]];
    [self.tempLabel setText:[NSString stringWithFormat:@"%li℃",(long)_status.temperature]];
}
#pragma mark - URL private methods
- (void) downloadInstructionSetFromServer
{
    if(HUD == nil) {
        HUD = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
        HUD.delegate = self;
    } else
        [HUD show:YES];
    
    NSString *urlStr = [NSString stringWithFormat:@"%@?tId=%@&moduleId=%i&houseId=%i",GetRequst(URL_FOR_USER_AC_INSTRUCTION_SET_VIEW), self.device.tid, self.device.modelId,MainDelegate.houseData.houseId];
    MyEDataLoader *downloader = [[MyEDataLoader alloc] initLoadingWithURLString:urlStr postData:nil delegate:self loaderName:@"AC_INSTRUCTION_SET_DOWNLOADER_NMAE"  userDataDictionary:nil];
    NSLog(@"%@",downloader.name);
}
- (void) downloadTemperatureHumidityFromServer
{
    if(statusHUD == nil) {
        statusHUD = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    } else
        [statusHUD show:YES];

    NSString *urlStr = [NSString stringWithFormat:@"%@?tId=%@&id=%@&houseId=%i",GetRequst(URL_FOR_AC_TEMPERATURE_HUMIDITY_VIEW), self.device.tid,self.device.deviceId,MainDelegate.houseData.houseId];
    MyEDataLoader *downloader = [[MyEDataLoader alloc] initLoadingWithURLString:urlStr postData:nil delegate:self loaderName:@"acStatus"  userDataDictionary:nil];
    NSLog(@"%@",downloader.name);
}
- (void) submitControlToServerPower:(NSInteger)powerSwitch runMode:(NSInteger)runMode setpoint:(NSInteger)setpoint windLevel:(NSInteger)windLevel
{
    
    if(HUD == nil) {
        HUD = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
        HUD.delegate = self;
    } else
        [HUD show:YES];
    
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                          [NSNumber numberWithInteger:powerSwitch], @"powerSwitch",
                          [NSNumber numberWithInteger:runMode], @"runMode",
                          [NSNumber numberWithInteger:setpoint], @"setpoint",
                          [NSNumber numberWithInteger:windLevel], @"windLevel",
                          nil ];
    NSString *urlStr = [NSString stringWithFormat:@"%@?houseId=%i&id=%@&switch_=%ld&runMode=%ld&setpoint=%ld&windLevel=%ld",GetRequst(URL_FOR_AC_CONTROL_SAVE),MainDelegate.houseData.houseId,self.device.deviceId, (long)powerSwitch,
                        (long)runMode, (long)setpoint, (long)windLevel];
    MyEDataLoader *downloader = [[MyEDataLoader alloc] initLoadingWithURLString:urlStr postData:nil delegate:self loaderName:AC_CONTROL_UPLOADER_NMAE  userDataDictionary:dict];
    NSLog(@"%@",downloader.name);
}
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [_data count] + 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"row0" forIndexPath:indexPath];
        return cell;
    }
    static NSString *CellIdentifier = @"AcInstructionCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    MyEAcInstruction *instruction = [_data objectAtIndex:indexPath.row - 1];
    // Configure the cell...
    UILabel *label = (UILabel *)[cell.contentView viewWithTag:11];
    [label setText:[MyEAcUtil getStringForPowerSwitch:instruction.powerSwitch]];
    
    UIImageView *iv = (UIImageView *)[cell.contentView viewWithTag:12];
    [iv setImage:[UIImage imageNamed:[MyEAcUtil getFilenameForRunMode:instruction.runMode]]];
    
    label = (UILabel *)[cell.contentView viewWithTag:13];
    [label setText:[MyEAcUtil getStringForSetpoint:instruction.setpoint]];
    
    label = (UILabel *)[cell.contentView viewWithTag:14];
    [label setText:[MyEAcUtil getStringForWindLevel:instruction.windLevel]];
    
    return cell;
}
#pragma mark - tableView delegate methods
-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == 0) {
        cell.backgroundColor = [UIColor lightGrayColor];
    }
}
-(NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == 0) {
        return nil;
    }
    return indexPath;
}
// Tap on table Row
- (void) tableView: (UITableView *) tableView didSelectRowAtIndexPath: (NSIndexPath *) indexPath {
    
    MyEAcInstruction *instruction = [_data objectAtIndex:indexPath.row -1];
    NSLog(@"power=%ld, runmode=%ld, setpoint=%ld, windlevel=%ld", (long)instruction.powerSwitch, (long)instruction.runMode, (long)instruction.setpoint, (long)instruction.windLevel);
    [self submitControlToServerPower:instruction.powerSwitch runMode:instruction.runMode setpoint:instruction.setpoint windLevel:instruction.windLevel];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - URL delegate methods
// 响应下载上传
- (void) didReceiveString:(NSString *)string loaderName:(NSString *)name userDataDictionary:(NSDictionary *)dict{
    if([name isEqualToString:@"acStatus"]) {
        [statusHUD hide:YES];
        NSLog(@"ajax json = %@", string);
        if ([MyEUtil getResultFromAjaxString:string] == -3) {
            [MyEUniversal doThisWhenUserLogOutWithVC:self];
  //          [MyEUtil showMessageOn:nil withMessage:@"用户已注销登录"];
        }else if ([MyEUtil getResultFromAjaxString:string] != 1){
            [SVProgressHUD showErrorWithStatus:@"fail"];
        }else{
//            SBJsonParser *parser = [[SBJsonParser alloc] init];
//            NSDictionary *dict = [parser objectWithString:string];
//            self.device.status.temperature = [[dict objectForKey:@"temperature"] intValue];
//            self.device.status.humidity = [[dict objectForKey:@"humidity"] intValue];
//            self.tempLabel.text = [NSString stringWithFormat:@"%li℃",(long)self.device.status.temperature];
//            self.humidityLabel.text = [NSString stringWithFormat:@"%li%%",(long)self.device.status.humidity];
            _status = [[MyEDeviceStatus alloc] initWithJSONString:string];
            UINavigationController *nav2 = self.tabBarController.childViewControllers[1];
            UINavigationController *nav3 = self.tabBarController.childViewControllers[2];
            if (_status.tempMornitorEnabled == 1) {
                nav3.tabBarItem.enabled = NO;
            }else
                nav3.tabBarItem.enabled = YES;
            if (_status.acAutoRunEnabled == 1) {
                nav2.tabBarItem.enabled = NO;
            }else
                nav2.tabBarItem.enabled = YES;
            [self refreshUI];
        }
    }
    if([name isEqualToString:@"AC_INSTRUCTION_SET_DOWNLOADER_NMAE"]) {
        [HUD hide:YES];
        if ([MyEUtil getResultFromAjaxString:string] != 1) {
            [SVProgressHUD showErrorWithStatus:@"fail"];
        } else{
            NSLog(@"ajax json = %@", string);
            MyEAcInstructionSet *instructionSet = [[MyEAcInstructionSet alloc] initWithJSONString:string];
//            self.device.acInstructionSet = instructionSet;
            _data = [NSMutableArray arrayWithArray:instructionSet.mainArray];
            [self.tableView reloadData];
        }
    }
    if([name isEqualToString:AC_CONTROL_UPLOADER_NMAE]) {
        [HUD hide:YES];
        NSLog(@"ajax json = %@", string);
        if ([MyEUtil getResultFromAjaxString:string] != 1 && [MyEUtil getResultFromAjaxString:string] != 2) {
        } else{
            _status.powerSwitch = [[dict objectForKey:@"powerSwitch"] intValue];
            _status.runMode = [[dict objectForKey:@"runMode"] intValue];
            _status.setpoint = [[dict objectForKey:@"setpoint"] intValue];
            _status.windLevel = [[dict objectForKey:@"windLevel"] intValue];
        }
    }
}
- (void) connection:(NSURLConnection *)connection didFailWithError:(NSError *)error loaderName:(NSString *)name{
    [HUD hide:YES];
    [SVProgressHUD showErrorWithStatus:@"Connection Fail"];
}
@end
