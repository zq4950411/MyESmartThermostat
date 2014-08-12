//
//  MyEDeviceAcViewController.m
//  MyEHome
//
//  Created by Ye Yuan on 10/8/13.
//  Copyright (c) 2013 My Energy Domain Inc. All rights reserved.
//

#import "MyEAcManualControlViewController.h"
#import "MyEAcUserModelViewController.h"


#define AC_INSTRUCTION_SET_DOWNLOADER_NMAE @"AcUserModelInstructionDownloader"
#define AC_TEMPERATURE_HUMIDITY_DOWNLOADER_NMAE @"AcTemperatureHumidityDownloader"

@interface MyEAcManualControlViewController (){
    NSInteger _humidity,_temperature,_runmode,_switchStatus,_windLevel,_temperatureSet,_instructionMode;
    MyEDeviceStatus *_status;
}

@end

@implementation MyEAcManualControlViewController
@synthesize accountData, device,runMode1,runMode2,runMode3,runMode4,runMode5,windLevel,windLevel0,windLevel1,windLevel2,windLevel3,runImage,runLabel,lockLabel,temperatureLabel,homeHumidityLabel,homeTemperatureLabel,tipsLabel,acControlView;

#pragma mark - life circle methods
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:YES];
    [timerToRefreshTemperatureAndHumidity invalidate];
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

    isBtnLocked = NO;
    [self downloadTemperatureHumidityFromServer];
//    [self setRunModeImageWithRunMode:_status.runMode];
//    [self setWindLevelImageWithWindLevel:_status.windLevel];
//    temperatureLabel.text = [NSString stringWithFormat:@"%li",(long)_status.setpoint];
//    [homeHumidityLabel setText:[NSString stringWithFormat:@"%li%%", (long)_status.humidity]];
//    [homeTemperatureLabel setText:[NSString stringWithFormat:@"%li℃", (long)_status.temperature]];
//    
//    if (_status.powerSwitch == 0) {
//        [self doThisWhenPowerOff];
//        powerOn = NO;
//    }else{
//        powerOn = YES;
//        [self doThisWhenPowerOn];
//    }
    acControlView.layer.shadowOffset = CGSizeMake(0, -2);
    acControlView.layer.shadowRadius = 5;
    acControlView.layer.shadowColor = [UIColor blackColor].CGColor;
    acControlView.layer.shadowOpacity = 0.5;
    acControlView.layer.cornerRadius = 5;
    
    if (!IS_IOS6) {
        for (UIButton *btn in self.view.subviews) {
            if ([btn isKindOfClass:[UIButton class]]) {
                [btn.layer setMasksToBounds:YES];
                [btn.layer setCornerRadius:5];
                [btn.layer setBorderWidth:1];
                [btn.layer setBorderColor:btn.tintColor.CGColor];
            }
        }
    }
    timerToRefreshTemperatureAndHumidity = [NSTimer scheduledTimerWithTimeInterval:600 target:self selector:@selector(downloadTemperatureHumidityFromServer) userInfo:nil repeats:YES];
}

#pragma mark -
#pragma mark URL Loading System methods
- (void) downloadTemperatureHumidityFromServer
{
    // this is a dumb download, don't add progress indicator or spinner here
    NSString *urlStr = [NSString stringWithFormat:@"%@?id=%@&tId=%@&houseId=%i",GetRequst(URL_FOR_AC_TEMPERATURE_HUMIDITY_VIEW),device.deviceId,device.tid,MainDelegate.houseData.houseId];
    MyEDataLoader *downloader = [[MyEDataLoader alloc] initLoadingWithURLString:urlStr postData:nil delegate:self loaderName:AC_TEMPERATURE_HUMIDITY_DOWNLOADER_NMAE  userDataDictionary:nil];
    NSLog(@"%@",downloader.name);
}
-(void)sendInstructionToServer{
    runImage.hidden = NO;
    NSString *urlStr = [NSString stringWithFormat:@"%@?houseId=%i&id=%@&switch_=%li&runMode=%li&setpoint=%li&windLevel=%li",
                        GetRequst(URL_FOR_AC_CONTROL_SAVE),
                        MainDelegate.houseData.houseId,
                        device.deviceId,
                        (long)_status.powerSwitch,
                        (long)_status.runMode,
                        (long)_status.setpoint,
                        (long)_status.windLevel];
    MyEDataLoader *downloader = [[MyEDataLoader alloc] initLoadingWithURLString:urlStr postData:nil delegate:self loaderName:@"sendInstructionToServer"  userDataDictionary:nil];
    NSLog(@"%@",downloader.name);
}

#pragma mark - URL delegate methods
// 响应下载上传
- (void) didReceiveString:(NSString *)string loaderName:(NSString *)name userDataDictionary:(NSDictionary *)dict{
    if([name isEqualToString:AC_TEMPERATURE_HUMIDITY_DOWNLOADER_NMAE]) {
        NSLog(@"ajax json = %@", string);
        if ([MyEUtil getResultFromAjaxString:string] == -1) {
            [SVProgressHUD showErrorWithStatus:@"fail"];
        }else{
            //{"temperature":"69","humidity":"11","switchStatus":0,"model":1,"winLevel":0,"temperatureSet":"25","result":1}
            SBJsonParser *parser = [[SBJsonParser alloc] init];
            NSDictionary *dict = [parser objectWithString:string];
            _temperature = [[dict objectForKey:@"temperature"] intValue];
            _humidity = [[dict objectForKey:@"humidity"] intValue];
            _switchStatus = [dict[@"switchStatus"] intValue];
            _runmode = [dict[@"model"] intValue];
            _windLevel = [dict[@"windLevel"] intValue];
            _temperatureSet = [dict[@"temperatureSet"] intValue];
            _instructionMode = [dict[@"ventilationFlag"] intValue];
            self.device.instructionMode = _instructionMode;
            _status = [[MyEDeviceStatus alloc] init];
            NSInteger i = [dict[@"temperatureRangeFlag"] intValue];
            NSInteger j = [dict[@"autoRunAcFlag"] intValue];
            UINavigationController *nav2 = self.tabBarController.childViewControllers[1];
            UINavigationController *nav3 = self.tabBarController.childViewControllers[2];

            if (i == 1) {
                nav3.tabBarItem.enabled = NO;
            }else
                nav3.tabBarItem.enabled = YES;
            
            if (j == 1) {
                nav2.tabBarItem.enabled = NO;
            }else
                nav2.tabBarItem.enabled = YES;
            [self refreshUI];
        }
    }
    if ([name isEqualToString:@"sendInstructionToServer"]) {
        NSLog(@"string is %@",string);
        runImage.hidden = YES;
        if ([MyEUtil getResultFromAjaxString:string] == -1) {
            [SVProgressHUD showErrorWithStatus:@"fail"];
        }else if ([MyEUtil getResultFromAjaxString:string] == 1){
        }else if ([MyEUtil getResultFromAjaxString:string] == 2){
            SBJsonParser *parser = [[SBJsonParser alloc] init];
            NSDictionary *dic = [parser objectWithString:string];
            _runmode = [dic[@"runMode"] intValue];
            _windLevel = [dic[@"windLevel"] intValue];
            _temperatureSet = [dic[@"setpoint"] intValue];
            [self refreshUI];
//            [self setRunModeImageWithRunMode:[dic[@"runMode"] intValue]];
//            [self setWindLevelImageWithWindLevel:[dic[@"windLevel"] intValue]];
//            temperatureLabel.text = [NSString stringWithFormat:@"%i",[dic[@"setpoint"] intValue]];
//            _status.runMode = [dic[@"runMode"] intValue];
//            _status.windLevel = [dic[@"windLevel"] intValue];
//            _status.setpoint = [dic[@"setpoint"] intValue];
            [MyEUtil showMessageOn:nil withMessage:@"The instruction are not learning, enable auto-complete function"];
        }
    }
}
- (void) connection:(NSURLConnection *)connection didFailWithError:(NSError *)error loaderName:(NSString *)name{
    [HUD hide:YES];
    [SVProgressHUD showErrorWithStatus:@"Connection Fail"];
}
#pragma mark - IBAction methods
- (IBAction)refreshTemperatureAndHumidity:(UIBarButtonItem *)sender {
    [self downloadTemperatureHumidityFromServer];
}
- (IBAction)poweOnOrOff:(UIButton *)sender {
    if (isBtnLocked) {
        return;
    }
    if (powerOn) {
        powerOn = NO;
        _status.powerSwitch = 0;
        [self doThisWhenPowerOff];
        [self sendInstructionToServer];
    }else{
        powerOn = YES;
        _status.powerSwitch = 1;
        [self doThisWhenPowerOn];
        [self sendInstructionToServer];
    }
}
- (IBAction)lock:(UIButton *)sender {
    if (!powerOn) {//当空调为关闭状态时，锁定功能无效
        return;
    }
    if (isBtnLocked) {
        isBtnLocked = NO;
    }else{
        isBtnLocked = YES;
    }
    lockLabel.hidden = !isBtnLocked;
}

- (IBAction)temperaturePlus:(UIButton *)sender {
    if (isBtnLocked) {
        return;
    }
    if (_status.powerSwitch == 0) {
        return;
    }
//    if (_status.tempMornitorEnabled == 1 && [temperatureLabel.text intValue] >= _status.acTmax) {
//        [MyEUtil showInstructionStatusWithYes:NO andView:self.navigationController.navigationBar andMessage:@"超出温度监控最高温度"];
//        return;
//    }

    //获取当前的温度
    NSInteger i = _status.setpoint;
    ++i;
    _status.setpoint = i;
    if (i > 30) {
        i = 30;
        _status.setpoint = i;
        runImage.hidden = YES;
    }
    temperatureLabel.text = [NSString stringWithFormat:@"%li",(long)i];
    [self observeBtnClickTimeInterval];
}

- (IBAction)temperatureMinus:(UIButton *)sender {
    if (isBtnLocked) {
        return;
    }
    if (_status.powerSwitch == 0) {
        return;
    }
//    if (_status.tempMornitorEnabled == 1 && [temperatureLabel.text intValue] <= _status.acTmin) {
//        [MyEUtil showInstructionStatusWithYes:NO andView:self.navigationController.navigationBar andMessage:@"低于温度监控最低温度"];
//        return;
//    }
    NSInteger i = _status.setpoint;
    --i;
    _status.setpoint = i;
    if (i<18) {
        i = 18;
        _status.setpoint = i;
        runImage.hidden = YES;
    }
    temperatureLabel.text = [NSString stringWithFormat:@"%li",(long)i];
    [self observeBtnClickTimeInterval];
}

- (IBAction)runModeChange:(UIButton *)sender {
    if (isBtnLocked) {
        return;
    }
    if (_status.powerSwitch == 1) {
        [self observeBtnClickTimeInterval];
    }
    NSInteger i = _status.runMode;
    i ++;
    if (_instructionMode == 1) {
        if (i > 5) {
            i = 1;
        }
    }else{
        if (i > 4) {
            i = 1;
        }
    }
    [self setRunModeImageWithRunMode:i];
    _status.runMode = i;
}

- (IBAction)windLevelChange:(UIButton *)sender {
    if (isBtnLocked) {
        return;
    }
    if (_status.powerSwitch == 0) {
        return;
    }
    NSInteger i = _status.windLevel;
    i++;
    if (i > 3) {
        i = 0;
    }
    [self setWindLevelImageWithWindLevel:i];
    _status.windLevel = i;
    [self observeBtnClickTimeInterval];
}
#pragma mark - private methods
- (void)dismissVC{
    [self dismissViewControllerAnimated:YES completion:nil];
}
-(void)refreshUI{
    if (_status.runMode != _runmode) {
        _status.runMode = _runmode;
        [self setRunModeImageWithRunMode:_status.runMode];
    }
    if (_status.windLevel != _windLevel) {
        _status.windLevel = _windLevel;
        [self setWindLevelImageWithWindLevel:_status.windLevel];
    }
    if (_status.setpoint != _temperatureSet) {
        _status.setpoint = _temperatureSet;
        temperatureLabel.text = [NSString stringWithFormat:@"%li",(long)_status.setpoint];
    }
    if (_status.humidity != _humidity) {
        _status.humidity = _humidity;
        [homeHumidityLabel setText:[NSString stringWithFormat:@"%li%%RH", (long)_status.humidity]];
    }
    if (_status.temperature != _temperature) {
        _status.temperature = _temperature;
        [homeTemperatureLabel setText:[NSString stringWithFormat:@"%li℃", (long)_temperature]];
    }
    if (_status.powerSwitch != _switchStatus) {
        _status.powerSwitch = _switchStatus;
        if (_status.powerSwitch == 0) {
            [self doThisWhenPowerOff];
            powerOn = NO;
        }else{
            powerOn = YES;
            [self doThisWhenPowerOn];
        }
    }
}
-(void)doThisWhenPowerOn{
    [self setRunModeImageWithRunMode:_status.runMode];
    [self setWindLevelImageWithWindLevel:_status.windLevel];
    runLabel.hidden = NO;
    windLevel.hidden = NO;
    tipsLabel.hidden = YES;
    self.sheshiduLabel.hidden = NO;
    self.temperatureLabel.hidden = NO;
}
-(void)doThisWhenPowerOff{
    //    runMode1.hidden = YES;
    //    runMode2.hidden = YES;
    //    runMode3.hidden = YES;
    //    runMode4.hidden = YES;
    //    runMode5.hidden = YES;
    self.sheshiduLabel.hidden = YES;
    self.temperatureLabel.hidden = YES;
    tipsLabel.hidden = NO;
    windLevel.hidden = YES;
    windLevel0.hidden = YES;
    windLevel1.hidden = YES;
    windLevel2.hidden = YES;
    windLevel3.hidden = YES;
    runLabel.hidden = YES;
    runImage.hidden = YES;
}
-(void)setRunModeImageWithRunMode:(NSInteger)runMode{
    switch (runMode) {
        case 1:
            runMode1.hidden = NO;
            runMode2.hidden = YES;
            runMode3.hidden = YES;
            runMode4.hidden = YES;
            runMode5.hidden = YES;
            break;
        case 2:
            runMode1.hidden = YES;
            runMode2.hidden = NO;
            runMode3.hidden = YES;
            runMode4.hidden = YES;
            runMode5.hidden = YES;
            break;
        case 3:
            runMode1.hidden = YES;
            runMode2.hidden = YES;
            runMode3.hidden = NO;
            runMode4.hidden = YES;
            runMode5.hidden = YES;
            break;
        case 4:
            runMode1.hidden = YES;
            runMode2.hidden = YES;
            runMode3.hidden = YES;
            runMode4.hidden = NO;
            runMode5.hidden = YES;
            break;
        case 5:
            runMode1.hidden = YES;
            runMode2.hidden = YES;
            runMode3.hidden = YES;
            runMode4.hidden = YES;
            runMode5.hidden = NO;
            break;
    }
}
-(void)setWindLevelImageWithWindLevel:(NSInteger)wind{
    switch (wind) {
        case 0:
            windLevel0.hidden = NO;
            windLevel1.hidden = YES;
            windLevel2.hidden = YES;
            windLevel3.hidden = YES;
            break;
        case 1:
            windLevel0.hidden = YES;
            windLevel1.hidden = NO;
            windLevel2.hidden = YES;
            windLevel3.hidden = YES;
            break;
        case 2:
            windLevel0.hidden = YES;
            windLevel1.hidden = NO;
            windLevel2.hidden = NO;
            windLevel3.hidden = YES;
            break;
        default:
            windLevel0.hidden = YES;
            windLevel1.hidden = NO;
            windLevel2.hidden = NO;
            windLevel3.hidden = NO;
            break;
    }
}
//这里实现连续点击btn，直至没有点击操作时执行
-(void)observeBtnClickTimeInterval{
    if (timer.isValid) {
        [timer invalidate];
        timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(sendInstructionToServer) userInfo:nil repeats:NO];
    }else{
        timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(sendInstructionToServer) userInfo:nil repeats:NO];
    }
}
@end
