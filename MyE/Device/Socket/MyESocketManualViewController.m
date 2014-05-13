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
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self uploadOrDownloadInfoFromServerWithURL:[NSString stringWithFormat:@"%@?houseId=%i&tId=%@",GetRequst(URL_FOR_SOCKET_PlUG_CONTROL),MainDelegate.houseData.houseId,self.device.tid] andName:@"downloadInfo"];
    _timer = [NSTimer scheduledTimerWithTimeInterval:30 target:self selector:@selector(handleTimer) userInfo:nil repeats:YES];
}
#pragma mark - IBAction methods
- (IBAction)socketControl:(UIButton *)sender {
    [self uploadOrDownloadInfoFromServerWithURL:[NSString stringWithFormat:@"%@?houseId=%i&tId=%@&switchStatus=%i",GetRequst(URL_FOR_SOCKET_PlUG_CONTROL),MainDelegate.houseData.houseId,self.device.tid,[self.device.switchStatus isEqualToString:@"1"]?0:1] andName:@"socketControl"];
}
- (IBAction)timeDelay:(UIButton *)sender {
    NSMutableArray *array = [NSMutableArray array];
    for (int i = 1; i < 61; i++) {
        [array addObject:[NSString stringWithFormat:@"%i m",i]];
    }
    [MyEUniversal doThisWhenNeedPickerWithTitle:@"time select" andDelegate:self andTag:1 andArray:@[array] andSelectRow:@[@(0)] andViewController:self];
}
- (IBAction)refreshData:(UIBarButtonItem *)sender {
    [self uploadOrDownloadInfoFromServerWithURL:[NSString stringWithFormat:@"%@?houseId=%i&tId=%@",GetRequst(URL_FOR_SOCKET_PlUG_CONTROL),MainDelegate.houseData.houseId,self.device.deviceId] andName:@"downloadInfo"];
}

#pragma mark - private methods
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
    MyEDataLoader *loader = [[MyEDataLoader alloc] initLoadingWithURLString:[NSString stringWithFormat:@"%@?houseId=%i&tId=%@",GetRequst(URL_FOR_SOCKET_PlUG_CONTROL),MainDelegate.houseData.houseId,self.device.tid] postData:nil delegate:self loaderName:@"downloadInfo" userDataDictionary:nil];
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
            self.device.switchStatus = [self.device.switchStatus isEqualToString:@"1"]?@"0":@"1";
        }else
            [SVProgressHUD showErrorWithStatus:@"Error!"];
    }
    if ([name isEqualToString:@"delay"]) {
        if (![string isEqualToString:@"fail"]) {
            NSDictionary *dic = [string JSONValue];
            if (dic[@"isMutex"]) {
                if ([dic[@"isMutex"] isEqualToString:@"1"]) {
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Warning" message:@"is Mutex" delegate:self cancelButtonTitle:@"Cancle" otherButtonTitles:@"OK", nil];
                    [alert show];
                }else
                    [self uploadOrDownloadInfoFromServerWithURL:[NSString stringWithFormat:@"%@?houseId=%i&tId=%@&delayMinute=%i",GetRequst(URL_FOR_SOCKET_DELAY_SAVE),MainDelegate.houseData.houseId,self.device.tid,_delayTime] andName:@"delaySave"];
            }
        }else
            [SVProgressHUD showErrorWithStatus:@"Error!"];
    }
    if ([name isEqualToString:@"delaySave"]) {
        if (![string isEqualToString:@"fail"]) {
            self.timeDelaySetLabel.text = [NSString stringWithFormat:@"%im set",_delayTime];
            if (self.socketControlInfo.switchStatus == 1) {
                self.timeDelayLabel.text = [NSString stringWithFormat:@"%im left",_delayTime];
            }else
                self.timeDelayLabel.text = @"";
        }
    }
}
#pragma mark - IQActionSheet delegate methods
-(void)actionSheetPickerView:(IQActionSheetPickerView *)pickerView didSelectTitles:(NSArray *)titles{
    _delayTime = [[titles[0] substringToIndex:[titles[0] length] == 3?1:2] intValue];
    [self uploadOrDownloadInfoFromServerWithURL:[NSString stringWithFormat:@"%@?tId=%@&action=1",GetRequst(URL_FOR_SOCKET_MUTEX_DELAY),self.device.tid] andName:@"delay"];
}
#pragma mark - UIAlertView delegate method
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 1) {
        [self uploadOrDownloadInfoFromServerWithURL:[NSString stringWithFormat:@"%@?houseId=%i&tId=%@&delayMinute=%i",GetRequst(URL_FOR_SOCKET_DELAY_SAVE),MainDelegate.houseData.houseId,self.device.tid,_delayTime] andName:@"delaySave"];
    }
}
@end
