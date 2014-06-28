//
//  MyESocketManualViewController.m
//  MyE
//
//  Created by 翟强 on 14-4-24.
//  Copyright (c) 2014年 MyEnergy Domain. All rights reserved.
//

#import "MyESocketManualViewController.h"

@interface MyESocketManualViewController ()
{
    MBProgressHUD *HUD;
    NSInteger _delayTime;
    NSTimer *_timer;
}
@end

@implementation MyESocketManualViewController

#pragma mark - life circle methods
-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:YES];
    [_timer invalidate];
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    if (self.needRefresh) {
        self.needRefresh = NO;
        [self uploadOrDownloadInfoFromServerWithURL:[NSString stringWithFormat:@"%@?houseId=%i&tId=%@",GetRequst(URL_FOR_SOCKET_FIND),MainDelegate.houseData.houseId,self.device.tid] andName:@"downloadInfo"];
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

    [self uploadOrDownloadInfoFromServerWithURL:[NSString stringWithFormat:@"%@?houseId=%i&tId=%@",GetRequst(URL_FOR_SOCKET_FIND),MainDelegate.houseData.houseId,self.device.tid] andName:@"downloadInfo"];
//    _timer = [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(handleTimer) userInfo:nil repeats:YES];
}
#pragma mark - IBAction methods
- (IBAction)socketControl:(UIButton *)sender {
    [self uploadOrDownloadInfoFromServerWithURL:[NSString stringWithFormat:@"%@?houseId=%i&tId=%@",GetRequst(URL_FOR_SMARTUP_PlUG_CONTROL),MainDelegate.houseData.houseId,self.device.tid] andName:@"socketControl"];
}
- (IBAction)timeDelay:(UIButton *)sender {
    NSMutableArray *array = [NSMutableArray array];
    for (int i = 1; i < 61; i++) {
        [array addObject:[NSString stringWithFormat:@"%i min",i]];
    }
    [array insertObject:@"OFF" atIndex:0];
    MYEPickerView *picker = [[MYEPickerView alloc] initWithView:self.view andTag:100 title:@"Time select" dataSource:array andSelectRow:0];
    picker.delegate = self;
    [picker showInView:self.view];
}
- (IBAction)refreshData:(UIBarButtonItem *)sender {
    [self uploadOrDownloadInfoFromServerWithURL:[NSString stringWithFormat:@"%@?houseId=%i&tId=%@",GetRequst(URL_FOR_SOCKET_FIND),MainDelegate.houseData.houseId,self.device.tid] andName:@"downloadInfo"];
}

#pragma mark - private methods
-(void)dismissVC{
    [self dismissViewControllerAnimated:YES completion:nil];
}
-(void)refreshUI{
    self.currentPowerLabel.text = [NSString stringWithFormat:@"%i W",self.socketControlInfo.currentPower];
    if (self.socketControlInfo.switchStatus == 1) {
        self.socketControlBtn.selected = NO;
        if (self.socketControlInfo.surplusMinutes != 0) { //剩余时间不为零，那就肯定在延时
            self.timeDelayBtn.selected = NO;
            self.timeDelaySetLabel.hidden = NO;
            self.timeDelayLabel.hidden = NO;
            self.timeDelaySetLabel.text = [NSString stringWithFormat:@"%im set",self.socketControlInfo.timeSet];
            self.timeDelayLabel.text = [NSString stringWithFormat:@"%im left",self.socketControlInfo.surplusMinutes];
        }else{
            self.timeDelayBtn.selected = YES;
            self.timeDelayLabel.hidden = YES;
            self.timeDelaySetLabel.hidden = YES;
            self.timeDelaySetLabel.text = @"";
            self.timeDelayLabel.text = @"";
        }
    }else{
        self.socketControlBtn.selected = YES;
        self.timeDelayBtn.selected = YES;
        self.timeDelayLabel.hidden = YES;
        self.timeDelaySetLabel.hidden = NO;
        if (self.socketControlInfo.timeSet > 0) {
            self.timeDelaySetLabel.text = [NSString stringWithFormat:@"%im set",self.socketControlInfo.timeSet];
        }
    }
}
-(void)uploadOrDownloadInfoFromServerWithURL:(NSString *)url andName:(NSString *)name{
    if (HUD == nil) {
        HUD = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    }
    [HUD show:YES];
    MyEDataLoader *loader = [[MyEDataLoader alloc] initLoadingWithURLString:url postData:nil delegate:self loaderName:name userDataDictionary:nil];
    NSLog(@"loader is %@",loader.name);
}
-(void)handleTimer{
    MyEDataLoader *loader = [[MyEDataLoader alloc] initLoadingWithURLString:[NSString stringWithFormat:@"%@?houseId=%i&tId=%@",GetRequst(URL_FOR_SOCKET_FIND),MainDelegate.houseData.houseId,self.device.tid] postData:nil delegate:self loaderName:@"downloadInfo" userDataDictionary:nil];
    NSLog(@"loader is %@",loader.name);
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - URL Delegate methods
-(void)didReceiveString:(NSString *)string loaderName:(NSString *)name userDataDictionary:(NSDictionary *)dict{
    [HUD hide:YES];
    NSLog(@"receive string is %@",string);
    if ([name isEqualToString:@"downloadInfo"]) {
        if (![string isEqualToString:@"fail"]) {
            MyESocketControlInfo *info = [[MyESocketControlInfo alloc] initWithJSONString:string];
            self.socketControlInfo = info;
            [self refreshUI];
        } else {
            [SVProgressHUD showErrorWithStatus:@"Error!"];
        }
    }
    if ([name isEqualToString:@"socketControl"]) {
        if (string.intValue == -999) {
            [SVProgressHUD showWithStatus:@"device unlink"];
        }else if (![string isEqualToString:@"fail"]){
            if ([string isEqualToString:@"OK"]) {
                self.socketControlInfo.switchStatus = 1-self.socketControlInfo.switchStatus;
                self.device.switchStatus = [NSString stringWithFormat:@"%i",self.socketControlInfo.switchStatus];
                self.socketControlBtn.selected = !self.socketControlBtn.selected;
                [self handleTimer];  //这里要更新一次数据
            }
//            MyESocketControlInfo *info = [[MyESocketControlInfo alloc] initWithJSONString:string];
//            self.socketControlInfo = info;
//            [self refreshUI];
//            self.socketControlInfo.switchStatus = 1-self.socketControlInfo.switchStatus;
//            self.socketControlBtn.selected = !self.socketControlBtn.selected;
        }else
            [SVProgressHUD showErrorWithStatus:@"Error!"];
    }
    if ([name isEqualToString:@"delay"]) {
        if (![string isEqualToString:@"fail"]) {
            NSDictionary *dic = [string JSONValue];
            if (dic[@"isMutex"]) {
                if ([dic[@"isMutex"] isEqualToString:@"1"]) {
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Warning" message:@"This plug has been set to an auto mode. To enable the timer, the auto mode will be turned off. Do you want to continue?" delegate:self cancelButtonTitle:@"NO" otherButtonTitles:@"YES", nil];
                    [alert show];
                }else
                    [self uploadOrDownloadInfoFromServerWithURL:[NSString stringWithFormat:@"%@?houseId=%i&tId=%@&delayMinute=%i",GetRequst(URL_FOR_SOCKET_DELAY_SAVE),MainDelegate.houseData.houseId,self.device.tid,_delayTime] andName:@"delaySave"];
            }
        }else
            [SVProgressHUD showErrorWithStatus:@"Error!"];
    }
    if ([name isEqualToString:@"delaySave"]) {
        if (![string isEqualToString:@"fail"]) {
            [self handleTimer];
//            self.timeDelaySetLabel.text = [NSString stringWithFormat:@"%im set",_delayTime];
//            if (self.socketControlInfo.switchStatus == 1) {
//                self.timeDelayLabel.text = [NSString stringWithFormat:@"%im left",_delayTime];
//            }else
//                self.timeDelayLabel.text = @"";
        }else
            [SVProgressHUD showErrorWithStatus:@"Error!"];
    }
}
-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error loaderName:(NSString *)name{
    [HUD hide:YES];
    [SVProgressHUD showErrorWithStatus:@"Connection Fail"];
}

#pragma mark - MYEPickerView delegate methods
-(void)MYEPickerView:(UIView *)pickerView didSelectTitles:(NSString *)title andRow:(NSInteger)row{
    if ([title isEqualToString:@"OFF"]) {
        _delayTime = 0;
    }else
        _delayTime = [[title substringToIndex:[title length] == 3?1:2] intValue];
    [self uploadOrDownloadInfoFromServerWithURL:[NSString stringWithFormat:@"%@?houseId=%i&tId=%@&action=1",GetRequst(URL_FOR_SOCKET_MUTEX_DELAY),MainDelegate.houseData.houseId,self.device.tid] andName:@"delay"];
}
#pragma mark - UIAlertView delegate method
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 1) {
        UINavigationController *nav = self.tabBarController.childViewControllers[1];
        MyESocketAutoViewController *vc = nav.childViewControllers[0];
        vc.needRefresh = YES;
        [self uploadOrDownloadInfoFromServerWithURL:[NSString stringWithFormat:@"%@?houseId=%i&tId=%@&delayMinute=%i",GetRequst(URL_FOR_SOCKET_DELAY_SAVE),MainDelegate.houseData.houseId,self.device.tid,_delayTime] andName:@"delaySave"];
    }
}
@end
