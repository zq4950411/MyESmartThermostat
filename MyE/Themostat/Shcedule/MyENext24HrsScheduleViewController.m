//
//  MyENext24HrsScheduleViewController.m
//  MyE
//
//  Created by Ye Yuan on 5/11/14.
//  Copyright (c) 2014 MyEnergy Domain. All rights reserved.
//

#import "MyENext24HrsScheduleViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "MyETodayPeriodData.h"
#import "MyEScheduleNext24HrsData.h"
#import "MyEHouseListViewController.h"
#import "MyEScheduleViewController.h"

#import "MyEAccountData.h"
#import "MyEHouseData.h"
#import "MyEThermostatData.h"

#import "MyENext24HrsDayItemData.h"
#import "MyEScheduleNext24HrsData.h"
#import "SBJson.h"
#import "MyEUtil.h"

@interface MyENext24HrsScheduleViewController ()
- (void)_restoreToLastUnchanged;
//此处取得跨过当前时刻的半点的id，由于是next24小时，开始时刻始终处于第0个或第一个半点处，所以此处返回的sector id只能是0或1
- (NSInteger)_sectorIdSpaningCurrentTime;

//获取跨越当前时刻的period的最后一个sector的id
- (NSInteger)_lastSectorIdOfPeriodSpaningCurrentTime;

- (void)_createPeriodEditingViewIfNecessary;
- (void)_togglePeriodEditingView;
- (void)_createHoldEditingViewIfNecessary;
- (void)_toggleHoldEditingView;
- (void)_createPeriodInforViewIfNecessary;
- (void)_togglePeriodInforView;
- (void)_createPeriodInforDoughnutViewIfNecessary;
- (void)_togglePeriodInforDoughnutView;

// 判定是否服务器相应正常，如果正常返回YES，如果服务器相应为-999/-998，
// 那么函数迫使Navigation View Controller跳转到Houselist view，并返回NO。
// 如果要中断外层函数执行，必须捕捉此函数返回的NO值，并中断外层函数。
- (BOOL)_processHttpRespondForString:(NSString *)respondText;
@end

@implementation MyENext24HrsScheduleViewController

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
    // Do any additional setup after loading the view.
    _periodEditingViewShowing = NO;
    _holdEditingViewShowing = NO;
    _periodInforViewShowing = NO;
    _periodInforDoughnutViewShowing = NO;
    
    //    _doughnutView = [[MyEDoughnutView alloc] initWithFrame:CGRectMake(30, 15, NEXT24HRS_DOUGHNUT_VIEW_SIZE, NEXT24HRS_DOUGHNUT_VIEW_SIZE) delegate:self]; // originally 2014-2-24
    _doughnutView = [[MyEDoughnutView alloc] initWithFrame:CGRectMake(15, 0, NEXT24HRS_DOUGHNUT_VIEW_SIZE, NEXT24HRS_DOUGHNUT_VIEW_SIZE) delegate:self]; // changed @  2014-2-24
    _doughnutView.delegate = self;
    /*
     // 当前时刻运行在0:0~0:30的情况示例
     self.next24hrsModel = [[MyEScheduleNext24HrsData alloc] initWithJSONString:@"{\"currentTime\":\"7/19/2012 0:2\",\"dayItems\":[{\"date\":19,\"month\":7,\"periods\":[{\"color\":\"0XF2CF45\",\"cooling\":78,\"etid\":13,\"heating\":70,\"hold\":\"None\",\"stid\":0},{\"color\":\"0X5598CB\",\"cooling\":83,\"etid\":14,\"heating\":66,\"hold\":\"None\",\"stid\":13},{\"color\":\"0XFA6748\",\"cooling\":74,\"etid\":27,\"heating\":70,\"hold\":\"None\",\"stid\":14},{\"color\":\"0XDD99D8\",\"cooling\":80,\"etid\":48,\"heating\":64,\"hold\":\"None\",\"stid\":27}],\"year\":2012},{\"date\":20,\"month\":7,\"periods\":[{\"color\":\"0x5598cb\",\"cooling\":78,\"etid\":12,\"heating\":66,\"hold\":\"None\",\"stid\":0},{\"color\":\"0xfa6748\",\"cooling\":74,\"etid\":16,\"heating\":70,\"hold\":\"None\",\"stid\":12},{\"color\":\"0xdd99d8\",\"cooling\":80,\"etid\":34,\"heating\":64,\"hold\":\"None\",\"stid\":16},{\"color\":\"0xf2cf45\",\"cooling\":74,\"etid\":42,\"heating\":70,\"hold\":\"None\",\"stid\":34},{\"color\":\"0x5598cb\",\"cooling\":78,\"etid\":48,\"heating\":66,\"hold\":\"None\",\"stid\":42}],\"year\":2012}],\"hold\":0,\"houseId\":419,\"setpoint\":78,\"userId\":\"1000100000000000317\",\"locWeb\":\"enabled\"}"];
     // 当前时刻运行在0:30~1:00的情况示例
     self.next24hrsModel = [[MyEScheduleNext24HrsData alloc] initWithJSONString:@"{\"currentTime\":\"7/19/2012 0:40\",\"dayItems\":[{\"date\":19,\"month\":7,\"periods\":[{\"color\":\"0x5598cb\",\"cooling\":78,\"etid\":14,\"heating\":66,\"hold\":\"None\",\"stid\":0},{\"color\":\"0xfa6748\",\"cooling\":74,\"etid\":17,\"heating\":70,\"hold\":\"None\",\"stid\":14},{\"color\":\"0xdd99d8\",\"cooling\":80,\"etid\":36,\"heating\":64,\"hold\":\"None\",\"stid\":17},{\"color\":\"0xf2cf45\",\"cooling\":74,\"etid\":44,\"heating\":70,\"hold\":\"None\",\"stid\":36},{\"color\":\"0x5598cb\",\"cooling\":78,\"etid\":48,\"heating\":66,\"hold\":\"None\",\"stid\":44}],\"year\":2012},{\"date\":20,\"month\":7,\"periods\":[{\"color\":\"0x5598cb\",\"cooling\":78,\"etid\":12,\"heating\":66,\"hold\":\"None\",\"stid\":0},{\"color\":\"0xfa6748\",\"cooling\":74,\"etid\":16,\"heating\":70,\"hold\":\"None\",\"stid\":12},{\"color\":\"0xdd99d8\",\"cooling\":80,\"etid\":34,\"heating\":64,\"hold\":\"None\",\"stid\":16},{\"color\":\"0xf2cf45\",\"cooling\":74,\"etid\":42,\"heating\":70,\"hold\":\"None\",\"stid\":34},{\"color\":\"0x5598cb\",\"cooling\":78,\"etid\":48,\"heating\":66,\"hold\":\"None\",\"stid\":42}],\"year\":2012}],\"hold\":0,\"houseId\":419,\"setpoint\":78,\"userId\":\"1000100000000000317\",\"locWeb\":\"enabled\"}"];
     self.next24hrsModelCache = [self.next24hrsModel copy];
     
     self.next24hrsModel = [[MyEScheduleNext24HrsData alloc] initWithJSONString:@"{\"currentTime\":\"7/20/2012 22:14\",\"dayItems\":[{\"date\":20,\"month\":7,\"periods\":[{\"color\":\"0x5598cb\",\"cooling\":78,\"etid\":14,\"heating\":66,\"hold\":\"None\",\"stid\":0},{\"color\":\"0xfa6748\",\"cooling\":74,\"etid\":18,\"heating\":70,\"hold\":\"None\",\"stid\":14},{\"color\":\"0xdd99d8\",\"cooling\":80,\"etid\":36,\"heating\":64,\"hold\":\"None\",\"stid\":18},{\"color\":\"0xf2cf45\",\"cooling\":74,\"etid\":44,\"heating\":70,\"hold\":\"None\",\"stid\":36},{\"color\":\"0x5598cb\",\"cooling\":78,\"etid\":48,\"heating\":66,\"hold\":\"None\",\"stid\":44}],\"year\":2012},{\"date\":21,\"month\":7,\"periods\":[{\"color\":\"0x5598cb\",\"cooling\":78,\"etid\":12,\"heating\":66,\"hold\":\"None\",\"stid\":0},{\"color\":\"0xfa6748\",\"cooling\":74,\"etid\":16,\"heating\":70,\"hold\":\"None\",\"stid\":12},{\"color\":\"0xf2cf45\",\"cooling\":74,\"etid\":42,\"heating\":70,\"hold\":\"None\",\"stid\":16},{\"color\":\"0x5598cb\",\"cooling\":78,\"etid\":48,\"heating\":66,\"hold\":\"None\",\"stid\":42}],\"year\":2012}],\"hold\":0,\"houseId\":419,\"setpoint\":66,\"userId\":\"1000100000000000317\",\"locWeb\":\"enabled\"}"];
     */
    // 测试运行在零点
    self.next24hrsModel = [[MyEScheduleNext24HrsData alloc] initWithJSONString:@"{\"currentTime\":\"7/21/2012 0:29\",\"dayItems\":[{\"date\":21,\"month\":7,\"periods\":[{\"color\":\"0xfa6748\",\"cooling\":74,\"etid\":8,\"heating\":70,\"hold\":\"None\",\"stid\":0},{\"color\":\"0xf2cf45\",\"cooling\":74,\"etid\":22,\"heating\":70,\"hold\":\"None\",\"stid\":8},{\"color\":\"0x5598cb\",\"cooling\":78,\"etid\":48,\"heating\":66,\"hold\":\"None\",\"stid\":22}],\"year\":2012},{\"date\":22,\"month\":7,\"periods\":[{\"color\":\"0x5598cb\",\"cooling\":78,\"etid\":12,\"heating\":66,\"hold\":\"None\",\"stid\":0},{\"color\":\"0xfa6748\",\"cooling\":74,\"etid\":16,\"heating\":70,\"hold\":\"None\",\"stid\":12},{\"color\":\"0xf2cf45\",\"cooling\":74,\"etid\":42,\"heating\":70,\"hold\":\"None\",\"stid\":16},{\"color\":\"0x5598cb\",\"cooling\":78,\"etid\":48,\"heating\":66,\"hold\":\"None\",\"stid\":42}],\"year\":2012}],\"hold\":0,\"houseId\":419,\"setpoint\":66,\"userId\":\"1000100000000000317\",\"locWeb\":\"enabled\"}"];
    self.next24hrsModelCache = [self.next24hrsModel copy];
    
    //    NSLog(@"next24hrsModel = %@ ", [self.next24hrsModel description]);
    //    NSLog(@"next24hrsModelCache = %@ ", [self.next24hrsModelCache description]);
    //
    NSInteger sectorIdSpaningCurrentTime = [self _sectorIdSpaningCurrentTime];
    NSLog(@"Next24Hrs panel viewDidLoad: sectorIdSpaningCurrentTime = %i",sectorIdSpaningCurrentTime);
    // 生成hold数组
    NSMutableArray *holdArray = [self.next24hrsModel holdArray];
    _doughnutView.holdArray = holdArray;
    _doughnutView.sectorIdSpaningCurrentTime = sectorIdSpaningCurrentTime;
    _doughnutView.zeroHourSectorId = NUM_SECTOR - [self.next24hrsModel getHoursForCurrentTime] * 2;
    
    NSMutableArray * modeIdArray = [self.next24hrsModel modeIdArray];
    //调用这个函数前，如果是Today面板，应该准备好sectorHoldArray，sectorIdSpaningCurrentTime
    //对于today和weekly两种面板，都要准备好并传入模式数组modeIdArray，才能正确绘制。
    [_doughnutView createViewsWithModeArray:modeIdArray scheduleType:SCHEDULE_TYPE_NEXT24HRS];
    self.currentSelectedModeId = [[modeIdArray objectAtIndex:sectorIdSpaningCurrentTime] intValue];//用当前时刻所在的sector的modeId作为当前选择的modeId
    NSMutableArray * periodIndexArray = [self.next24hrsModel periodIndexArray];
    self.currentSelectedPeriodIndex = [[periodIndexArray objectAtIndex:sectorIdSpaningCurrentTime] intValue];//用当前时刻所在的sector的periodIndexArray作为当前选择的periodIndexArray
    
    [self.centerContainerView insertSubview:_doughnutView atIndex:0];
    
    
    [self.useWeeklyButton setBackgroundImage:[UIImage imageNamed:@"buttonbg.png"] forState:UIControlStateNormal];
    [self.useWeeklyButton setBackgroundImage:[UIImage imageNamed:@"buttonbgdisabled.png"] forState:UIControlStateDisabled];
    [self.useWeeklyButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.useWeeklyButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateDisabled];
    
    [self.applyButton setBackgroundImage:[UIImage imageNamed:@"buttonbg.png"] forState:UIControlStateNormal];
    [self.applyButton setBackgroundImage:[UIImage imageNamed:@"buttonbgdisabled.png"] forState:UIControlStateDisabled];
    [self.applyButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.applyButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateDisabled];
    
    [self.resetButton setImage:[UIImage imageNamed:@"reset.png"] forState:UIControlStateNormal];
    [self.resetButton setImage:[UIImage imageNamed:@"reset_disabled.png"] forState:UIControlStateDisabled];
    
    self.applyButton.enabled = NO;
    self.resetButton.enabled = NO;
    
    _scheduleChangedByUserTouch = NO;
    
    // 描绘本容器view的边界，以便于调试
    //        CALayer *theLayer= [self.view layer];
    //        theLayer.borderColor = [UIColor purpleColor].CGColor;
    //        theLayer.borderWidth = 1;
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    //可以用下面语句生成一个新Edit button，并替换掉父容器TabBarController的navigationItem的右边按钮
    self.parentViewController.navigationItem.rightBarButtonItems = nil;
    UIBarButtonItem *refreshButton = [[UIBarButtonItem alloc]
                                      initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh
                                      target:self
                                      action:@selector(refreshAction)];
    self.parentViewController.navigationItem.rightBarButtonItem = refreshButton;
    
    //下面为父容器TabBarController的navigationItem的右边按钮添加一个action处理函数，和上面注释掉语句功能类似，只是不替换为新的button，而是对原有button修改target和action
    self.parentViewController.navigationItem.rightBarButtonItem.target = self;
    self.parentViewController.navigationItem.rightBarButtonItem.action = @selector(refreshAction);
    

    [self downloadModelFromServer];


}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


-(void) setIsRemoteControl:(BOOL)isRemoteControl {
    _isRemoteControl = isRemoteControl;
    if (!isRemoteControl) {
        self.useWeeklyButton.hidden = YES;
        self.applyButton.hidden = YES;
        self.resetButton.hidden = YES;
    }else {
        self.applyButton.hidden = NO;
        self.useWeeklyButton.hidden = NO;
        self.resetButton.hidden = NO;
    }
}


#pragma mark -
#pragma mark URL Loading System methods
- (void) downloadModelFromServer
{
    ///////////////////////////////////////////////////////////////////////
    // Demo 用户登录
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    
    NSString *username = [prefs objectForKey:@"username"];
    
    if (username != nil && [username caseInsensitiveCompare:@"demo"] == NSOrderedSame) // 如果是demo账户
        return;
    ///////////////////////////////////////////////////////////////////////
    
    
    if(HUD == nil) {
        HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        //        HUD.dimBackground = YES;//容易产生灰条
        HUD.delegate = self;
    } else
        [HUD show:YES];
    
    NSString *urlStr = [NSString stringWithFormat:@"%@?userId=%@&houseId=%i&tId=%@",GetRequst(URL_FOR_NEXT24HRS_SCHEDULE_VIEW), MainDelegate.accountData.userId, MainDelegate.houseData.houseId, MainDelegate.thermostatData.tId];
    MyEDataLoader *downloader = [[MyEDataLoader alloc] initLoadingWithURLString:urlStr postData:nil delegate:self loaderName:@"Next24HrsDownloader" userDataDictionary:nil];
    NSLog(@"Next24HrsDownloader.name = %@",downloader.name);
}
- (void) downloadWeeklyModelFromServer
{
    ///////////////////////////////////////////////////////////////////////
    // Demo 用户登录
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    
    NSString *username = [prefs objectForKey:@"username"];
    
    if (username != nil && [username caseInsensitiveCompare:@"demo"] == NSOrderedSame) // 如果是demo账户
        return;
    ///////////////////////////////////////////////////////////////////////
    
    
    if(HUD == nil) {
        HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        //        HUD.dimBackground = YES;//容易产生灰条
        HUD.delegate = self;
    } else
        [HUD show:YES];
    
    NSString *urlStr = [NSString stringWithFormat:@"%@?userId=%@&houseId=%i&tId=%@",GetRequst(URL_FOR_NEXT24HRS_DEFAULT_SCHEDULE_VIEW), MainDelegate.accountData.userId, MainDelegate.houseData.houseId, MainDelegate.thermostatData.tId];
    MyEDataLoader *downloader = [[MyEDataLoader alloc] initLoadingWithURLString:urlStr postData:nil delegate:self loaderName:@"Next24HrsUseWeeklyDownloader" userDataDictionary:nil];
    NSLog(@"Next24HrsUseWeeklyDownloader : %@",downloader.name);
}


- (void) uploadModelToServer
{
    ///////////////////////////////////////////////////////////////////////
    // Demo 用户登录
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    
    NSString *username = [prefs objectForKey:@"username"];
    
    if (username != nil && [username caseInsensitiveCompare:@"demo"] == NSOrderedSame) // 如果是demo账户
        return;
    ///////////////////////////////////////////////////////////////////////
    
    
    if(HUD == nil) {
        HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        //        HUD.dimBackground = YES;//容易产生灰条
        HUD.delegate = self;
    } else
        [HUD show:YES];
    
    NSMutableString *body = [NSMutableString stringWithFormat:@"schedule=%@", [[self.next24hrsModel JSONDictionary] JSONRepresentation]];
    
    NSLog(@"Today ScheduleUploader body is \n%@", body);
    [body replaceOccurrencesOfString:@"\\" withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0,[body length])];
    
    NSString *urlStr = [NSString stringWithFormat:@"%@?userId=%@&houseId=%i&tId=%@",GetRequst(URL_FOR_NEXT24HRS_SCHEDULE_SAVE), MainDelegate.accountData.userId, MainDelegate.houseData.houseId, MainDelegate.thermostatData.tId];
    
    MyEDataLoader *uploader = [[MyEDataLoader alloc] initLoadingWithURLString:urlStr postData:body delegate:self loaderName:@"Next24HrsScheduleUploader" userDataDictionary:nil];
    NSLog(@"Next24HrsScheduleUploader is %@",uploader.name);
    
}

- (void) uploadHoldModelToServerWithSetpoint:(NSInteger)setpoint hold:(NSInteger)hold
{
    ///////////////////////////////////////////////////////////////////////
    // Demo 用户登录
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    
    NSString *username = [prefs objectForKey:@"username"];
    
    if (username != nil && [username caseInsensitiveCompare:@"demo"] == NSOrderedSame) // 如果是demo账户
        return;
    ///////////////////////////////////////////////////////////////////////
    
    
    if(HUD == nil) {
        HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        //        HUD.dimBackground = YES;//容易产生灰条
        HUD.delegate = self;
    } else
        [HUD show:YES];
    
    NSString *urlStr = [NSString stringWithFormat:@"%@?userId=%@&houseId=%i&tId=%@&setpoint=%i&hold=%i",GetRequst(URL_FOR_NEXT24HRS_HOLD_SAVE), MainDelegate.accountData.userId, MainDelegate.houseData.houseId, MainDelegate.thermostatData.tId, setpoint, hold];
    
    MyEDataLoader *uploader = [[MyEDataLoader alloc] initLoadingWithURLString:urlStr postData:nil delegate:self loaderName:@"Next24HrsHoldUploader" userDataDictionary:nil];
    NSLog(@"Next24HrsHoldUploader is %@",uploader.name);
    
}


- (void) didReceiveString:(NSString *)string loaderName:(NSString *)name userDataDictionary:(NSDictionary *)dict{
    NSLog(@"Next24Hrs schedule JSON String from server is \n%@",string);
    
    if([name isEqualToString:@"Next24HrsDownloader"]) {
        
        // 判定是否服务器相应正常，如果服务器相应为-999/-998，那么_processHttpRespondForString函数会迫使
        // Navigation View Controller跳转到Houselist view。
        // 如果要中断本层函数执行，必须捕捉_processHttpRespondForString函数返回的NO值，并中断本层函数。
        if (![self _processHttpRespondForString:string])
            return;
        
        // 获得next24Hrs model
        MyEScheduleNext24HrsData *next24hrsModel = [[MyEScheduleNext24HrsData alloc] initWithJSONString:string];
        if (next24hrsModel != nil) {
            self.next24hrsModel = next24hrsModel;
            MyEScheduleNext24HrsData *cloned = [next24hrsModel copy];
            self.next24hrsModelCache = cloned;
            
            NSInteger sectorIdSpaningCurrentTime = [self _sectorIdSpaningCurrentTime];
            NSLog(@"sectorIdSpaningCurrentTime = %i",sectorIdSpaningCurrentTime);
            // 生成hold数组
            NSMutableArray *holdArray = [self.next24hrsModel holdArray];
            _doughnutView.holdArray = holdArray;
            _doughnutView.sectorIdSpaningCurrentTime = sectorIdSpaningCurrentTime;
            
            _doughnutView.zeroHourSectorId = NUM_SECTOR - [self.next24hrsModel getHoursForCurrentTime] * 2;
            NSLog(@" _doughnutView.zeroHourSectorId = %i",  _doughnutView.zeroHourSectorId);
            
            NSMutableArray * modeIdArray = [self.next24hrsModel modeIdArray];
            //调用这个函数前，如果是Today面板，应该准备好sectorHoldArray，sectorIdSpaningCurrentTime
            [_doughnutView updateWithModeIdArray:modeIdArray];
            
            _scheduleChangedByUserTouch = NO;
            [self.applyButton setEnabled:NO];
            [self.resetButton setEnabled:NO];
            
            //刷新远程控制的状态。
            self.isRemoteControl = [next24hrsModel.locWeb caseInsensitiveCompare:@"enabled"] == NSOrderedSame;
        } else {
            UIAlertView *alert =[[UIAlertView alloc]initWithTitle:@"Error"
                                                          message:@"Communication error. Please try again."
                                                         delegate:self
                                                cancelButtonTitle:@"Ok"
                                                otherButtonTitles:nil];
            [alert show];
        }
    } else if([name isEqualToString:@"Next24HrsUseWeeklyDownloader"]) {
        // 判定是否服务器相应正常，如果服务器相应为-999/-998，那么_processHttpRespondForString函数会迫使
        // Navigation View Controller跳转到Houselist view。
        // 如果要中断本层函数执行，必须捕捉_processHttpRespondForString函数返回的NO值，并中断本层函数。
        if (![self _processHttpRespondForString:string])
            return;
        
        if ([string isEqualToString:@"fail"]) {
            UIAlertView *alert =[[UIAlertView alloc]initWithTitle:@"Error"
                                                          message:@"Communication error. Please try again."
                                                         delegate:self
                                                cancelButtonTitle:@"Ok"
                                                otherButtonTitles:nil];
            [alert show];
        } else {
            
            // 获得Next24Hrs model
            MyEScheduleNext24HrsData *next24hrsModel = [[MyEScheduleNext24HrsData alloc] initWithJSONString:string];
            if (next24hrsModel) {
                self.next24hrsModel = next24hrsModel;
                self.next24hrsModelCache = [self.next24hrsModel copy];
                
                NSInteger sectorIdSpaningCurrentTime = [self _sectorIdSpaningCurrentTime];
                NSLog(@"sectorIdSpaningCurrentTime = %i",sectorIdSpaningCurrentTime);
                // 生成hold数组
                NSMutableArray *holdArray = [self.next24hrsModel holdArray];
                _doughnutView.holdArray = holdArray;
                _doughnutView.sectorIdSpaningCurrentTime = sectorIdSpaningCurrentTime;
                
                _doughnutView.zeroHourSectorId = NUM_SECTOR - [self.next24hrsModel getHoursForCurrentTime] * 2;
                NSLog(@" _doughnutView.zeroHourSectorId = %i",  _doughnutView.zeroHourSectorId);
                
                NSMutableArray * modeIdArray = [self.next24hrsModel modeIdArray];
                //调用这个函数前，如果是Today面板，应该准备好sectorHoldArray，sectorIdSpaningCurrentTime
                [_doughnutView updateWithModeIdArray:modeIdArray];
                
                _scheduleChangedByUserTouch = NO;
                [self.applyButton setEnabled:NO];
                [self.resetButton setEnabled:NO];
            } else {
                UIAlertView *alert =[[UIAlertView alloc]initWithTitle:@"Error"
                                                              message:@"Communication error. Please try again."
                                                             delegate:self
                                                    cancelButtonTitle:@"Ok"
                                                    otherButtonTitles:nil];
                [alert show];
            }
        }
    } else if ([name isEqualToString:@"Next24HrsScheduleUploader"]) {
        // 判定是否服务器相应正常，如果服务器相应为-999/-998，那么_processHttpRespondForString函数会迫使
        // Navigation View Controller跳转到Houselist view。
        // 如果要中断本层函数执行，必须捕捉_processHttpRespondForString函数返回的NO值，并中断本层函数。
        if (![self _processHttpRespondForString:string])
            return;
        
        if ([string isEqualToString:@"OK"]) {
            _scheduleChangedByUserTouch = NO;
            [self.applyButton setEnabled:NO];
            [self.resetButton setEnabled:NO];
            self.next24hrsModelCache = [self.next24hrsModel copy];
        } else {// 如果上传有错误，就提示用户，用户可以选择再次上传
            UIAlertView *alert =[[UIAlertView alloc]initWithTitle:@"Error"
                                                          message:@"Communication error. Please try again."
                                                         delegate:self
                                                cancelButtonTitle:@"Ok"
                                                otherButtonTitles:nil];
            [alert show];
        }
    }
    else if ([name isEqualToString:@"Next24HrsHoldUploader"]) {
        // 判定是否服务器相应正常，如果服务器相应为-999/-998，那么_processHttpRespondForString函数会迫使
        // Navigation View Controller跳转到Houselist view。
        // 如果要中断本层函数执行，必须捕捉_processHttpRespondForString函数返回的NO值，并中断本层函数。
        if (![self _processHttpRespondForString:string])
            return;
        
        if ([string isEqualToString:@"fail"]) {
            UIAlertView *alert =[[UIAlertView alloc]initWithTitle:@"Error"
                                                          message:@"Communication error. Please try again."
                                                         delegate:self
                                                cancelButtonTitle:@"Ok"
                                                otherButtonTitles:nil];
            [alert show];
        } else {
            
            // 获得Next24Hrs model
            MyEScheduleNext24HrsData *next24hrsModel = [[MyEScheduleNext24HrsData alloc] initWithJSONString:string];
            if (next24hrsModel) {
                self.next24hrsModel = next24hrsModel;
                self.next24hrsModelCache = [self.next24hrsModel copy];
                
                NSInteger sectorIdSpaningCurrentTime = [self _sectorIdSpaningCurrentTime];
                NSLog(@"sectorIdSpaningCurrentTime = %i",sectorIdSpaningCurrentTime);
                // 生成hold数组
                NSMutableArray *holdArray = [self.next24hrsModel holdArray];
                _doughnutView.holdArray = holdArray;
                _doughnutView.sectorIdSpaningCurrentTime = sectorIdSpaningCurrentTime;
                
                _doughnutView.zeroHourSectorId = NUM_SECTOR - [self.next24hrsModel getHoursForCurrentTime] * 2;
                NSLog(@" _doughnutView.zeroHourSectorId = %i",  _doughnutView.zeroHourSectorId);
                
                NSMutableArray * modeIdArray = [self.next24hrsModel modeIdArray];
                //调用这个函数前，如果是Today面板，应该准备好sectorHoldArray，sectorIdSpaningCurrentTime
                [_doughnutView updateWithModeIdArray:modeIdArray];
                
                _scheduleChangedByUserTouch = NO;
                [self.applyButton setEnabled:NO];
                [self.resetButton setEnabled:NO];
            } else {
                UIAlertView *alert =[[UIAlertView alloc]initWithTitle:@"Error"
                                                              message:@"Communication error. Please try again."
                                                             delegate:self
                                                    cancelButtonTitle:@"Ok"
                                                    otherButtonTitles:nil];
                [alert show];
            }
        }
    }
    [HUD hide:YES];
    
    // 在从服务器获得数据后，如果哪个子面板还在显示，就隐藏它
    if (_periodEditingViewShowing) {
        [self _togglePeriodEditingView];
    }
    if (_holdEditingViewShowing) {
        [self _toggleHoldEditingView];
    }
    if (_periodInforViewShowing) {
        [self _togglePeriodInforView];
    }
    if (_periodInforDoughnutViewShowing) {
        [self _togglePeriodInforDoughnutView];
    }
}
- (void) connection:(NSURLConnection *)connection didFailWithError:(NSError *)error loaderName:(NSString *)name{
    [HUD hide:YES];
    UIAlertView *alert =[[UIAlertView alloc]initWithTitle:@"Error"
                                                  message:@"Communication error. Please try again."
                                                 delegate:self
                                        cancelButtonTitle:@"Ok"
                                        otherButtonTitles:nil];
    [alert show];
    // inform the user
    NSLog(@"In delegate Connection failed! Error - %@ %@",
          [error localizedDescription],
          [[error userInfo] objectForKey:NSURLErrorFailingURLStringErrorKey]);
}

#pragma mark -
#pragma mark action methods
- (IBAction)applyNewSchedule:(id)sender {
    // 上传当前最新数据到服务器
    [self uploadModelToServer];
}

- (IBAction)resetSchedule:(id)sender {
    [self _restoreToLastUnchanged];
}

- (IBAction)useWeekly:(id)sender {
    [self downloadWeeklyModelFromServer];
}


#pragma mark -
#pragma mark MyETodayPeriodEditingViewDelegate methods
- (void) didFinishEditingPeriodIndex:(NSInteger)periodIndex cooling:(float)cooling heating:(float)heating {
    [self _togglePeriodEditingView];
    if(periodIndex >= 0){// periodIndex<0 表示用户点击了period editing panel的Cancel按钮
        [self.next24hrsModel updateWithPeriodIndex:periodIndex heating:heating cooling:cooling];
        
        //因为编辑了setpoint信息，所以需要把这些信息更新到_doughnutView的数据模型中
        [_doughnutView updateWithModeIdArray:[self.next24hrsModel modeIdArray]];
        
        
        // 上传当前最新数据到服务器
        [self uploadModelToServer];
    }
}
#pragma mark MyETodayHoldEditingViewDelegate methods
- (void) didFinishHoldEditingWithAction:(NSInteger)action setpoint:(NSInteger)setpoint run:(BOOL)isRun{
    NSLog(@"action = %i, setpoint = %i, run = %@", action, setpoint, (isRun ? @"YES" : @"NO"));
    [self _toggleHoldEditingView];
    
    // action: 0-run, 1-ok, 2-cancel
    if (action == 0) {
        [self uploadHoldModelToServerWithSetpoint:setpoint hold:0];
    }
    if (action == 1) {
        [self uploadHoldModelToServerWithSetpoint:setpoint hold:self.next24hrsModel.hold];
    }
}
#pragma mark MyETodayPeriodInforViewDelegate methods
- (void) didFinishPeriodInforView {
    [self _togglePeriodInforView];
}
#pragma mark MyETodayPeriodInforViewDelegate methods
- (void) didFinishPeriodInforDoughnutView {
    [self _togglePeriodInforDoughnutView];
}

#pragma mark -
#pragma mark MyEDoughnutViewDelegate methods
// 每当用户手指触摸修改了若干sector的模式，用户手指抬起来后，就向delegate发送这个消息
// Doughnutview 传递来的参数modeIdArray有可能为nil，表示用户只是触摸了sector，但并没修改Doughnut上的Schedule
- (void)didSchecduleChangeWithModeIdArray:(NSArray *)modeIdArray {
    if (modeIdArray) {
        _scheduleChangedByUserTouch = YES;
        [self.applyButton setEnabled:YES];
        [self.resetButton setEnabled:YES];
        [self.next24hrsModel updateWithModeIdArray:modeIdArray];
        _doughnutView.holdArray = [self.next24hrsModel holdArray];//现在允许拖动hold时段了，所以必须更新holdArray
    }
    
    // 下面代码用于修正bug：通过涂抹操作调整时间点后，在手抬起来的那一刹那，经常错误触发显示setpoint的单击事件。
    if(_periodInforDoughnutViewShowing)
        [self _togglePeriodInforDoughnutView];
}
// 当用户单击一个Secotr时，表示要显示heating/cooling数据，把这个sector的序号传递回去
- (void)didSingleTapSectorIndex:(NSUInteger)sectorInedx {
    NSLog(@"Single touched sector of index: %i", sectorInedx);
    [self _togglePeriodInforDoughnutView];
}
// 当用户双击一个Secotr时，表示要修改这个sector所在period的heating/cooling或颜色，把这个sector的序号传递回去
- (void)didDoubleTapSectorIndex:(NSUInteger)sectorInedx {
    NSMutableArray * modeIdArray = [self.next24hrsModel modeIdArray];
    self.currentSelectedModeId = [[modeIdArray objectAtIndex:sectorInedx] intValue];
    NSMutableArray * periodIndexArray = [self.next24hrsModel periodIndexArray];
    self.currentSelectedPeriodIndex = [[periodIndexArray objectAtIndex:sectorInedx] intValue];
    MyETodayPeriodData *period = [self.next24hrsModel.periods objectAtIndex:self.currentSelectedPeriodIndex];
    NSInteger lastSectorIdOfPeriodSpaningCurrentTime = [self _lastSectorIdOfPeriodSpaningCurrentTime];
    
    NSInteger sectorIdSpaningCurrentTime = [self _sectorIdSpaningCurrentTime];
    if (sectorInedx <  sectorIdSpaningCurrentTime || !self.isRemoteControl){
        [self _togglePeriodInforView];
    }
    else if(sectorInedx >=sectorIdSpaningCurrentTime && sectorInedx <=  lastSectorIdOfPeriodSpaningCurrentTime){
        if([period.hold caseInsensitiveCompare:@"none"] != NSOrderedSame){
            [self _toggleHoldEditingView];
        } else {
            [self _togglePeriodInforView];
        }
    }
    else {//if (sectorInedx > lastSectorIdOfPeriodSpaningCurrentTime)
        if([period.hold caseInsensitiveCompare:@"none"] != NSOrderedSame){
            [self _toggleHoldEditingView];
        } else {
            [self _togglePeriodEditingView];
        }
        
    }
}


#pragma mark MyEDoughnutViewDelegate methods
- (UIColor *)currentModeColor
{
    NSMutableDictionary *modeIdColorDictionary = [self.next24hrsModel modeIdColorDictionary];
    return [modeIdColorDictionary objectForKey:[NSNumber numberWithInt:self.currentSelectedModeId]];
}
// 给定modeId，获取它对应的颜色
- (UIColor *)colorForModeId:(NSInteger)modeId
{
    NSMutableDictionary *modeIdColorDictionary = [self.next24hrsModel modeIdColorDictionary];
    return [modeIdColorDictionary objectForKey:[NSNumber numberWithInt:modeId]];
}

#pragma mark
#pragma mark private method
- (void)_restoreToLastUnchanged {
    self.next24hrsModel = [self.next24hrsModelCache copy];//将主数据模型整体恢复为缓冲数据模型里面保持的老的数据，这里不需要恢复Modes部分，所以注释了
    NSMutableArray *holdArray = [self.next24hrsModel holdArray];
    _doughnutView.holdArray = holdArray;
    
    NSMutableArray * modeIdArray = [self.next24hrsModel modeIdArray];
    [_doughnutView updateWithModeIdArray:modeIdArray];
    
    _scheduleChangedByUserTouch = NO;
    self.applyButton.enabled = NO;
    self.resetButton.enabled = NO;
}
//此处取得跨过当前时刻的半点的id，由于是next24小时，开始时刻始终处于第0个或第一个半点处，所以此处返回的sector id只能是0或1
- (NSInteger)_sectorIdSpaningCurrentTime
{
    if(self.next24hrsModel ==nil || [self.next24hrsModel.periods count]==0)
        return 0;
    
    // Doughnut view 的类型是Today，就需要设置如下的参数，指定刚好跨越当前时刻的sector
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MM/dd/yyyy HH:mm"];
    [dateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"] ];
    NSDate *currentTime = [dateFormatter dateFromString:self.next24hrsModel.currentTime];
    
    //下面几行用另外一个方法获得各个分量的字符
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *comps;
    NSInteger unitFlags = NSYearCalendarUnit |
    NSMonthCalendarUnit |
    NSDayCalendarUnit |
    NSHourCalendarUnit |
    NSMinuteCalendarUnit;
    
    comps = [calendar components:unitFlags fromDate:currentTime];
    int min = [comps minute];
    
    // 在这里加代码计算那个sector跨过当前的时刻。
    if (min >= 30) {
        return 1;
    }
    return 0;
}


//获取跨越当前时刻的period的最后一个sector的id
- (NSInteger)_lastSectorIdOfPeriodSpaningCurrentTime {
    NSInteger sectorIdSpaningCurrentTime = [self _sectorIdSpaningCurrentTime];
    for (MyETodayPeriodData *period in self.next24hrsModel.periods) {
        // 注意时段的结束半点id是下一个时段的开始半点id，
        if (period.stid <= sectorIdSpaningCurrentTime && period.etid-1 >= sectorIdSpaningCurrentTime) {
            return period.etid-1;
        }
    }
    return NUM_SECTOR - 1;
    
}
- (void)refreshAction
{
    [self downloadModelFromServer];
}

#pragma mark -
#pragma mark methods for mode editing view
- (void)_createPeriodEditingViewIfNecessary {
    
    if (!_periodEditingView) {
        //  获取最底层ScheduleView,这里本来应该把此View添加到self.view的，可以保持低耦合，不过这里为了特殊显示效果，才把_periodEditingView添加到底层ScheduleView的
        UIView *baseView = self.view;

        CGRect bounds = [baseView bounds];
        CGRect frame = CGRectMake(CGRectGetMinX(bounds), CGRectGetMaxY(bounds), bounds.size.width, bounds.size.height);
        _periodEditingView = [[MyETodayPeriodEditingView alloc] initWithFrame:frame];
        [_periodEditingView setDelegate:self];
        [baseView addSubview:_periodEditingView];
    }
}

- (void)_togglePeriodEditingView
{
    [self _createPeriodEditingViewIfNecessary]; // no-op if slideUpView has already been created
    
    CGRect frame = [_periodEditingView frame];
    if (_periodEditingViewShowing) {
        frame.origin.y += frame.size.height;
        
    } else {
        frame.origin.y -= frame.size.height;
        
        _periodEditingView.periodIndex = self.currentSelectedPeriodIndex;
        
        MyETodayPeriodData *period = [self.next24hrsModel.periods objectAtIndex:self.currentSelectedPeriodIndex];
        NSAssert((period != nil),@"error in [MyENext24HrsScheduleController _togglePeriodEditingViewWithType]: period is nil! ");
        
        NSLog(@"period = %@", [period description]);
        //注意必须先设置heating，再设置cooling，因为heating的picker允许范围不依赖其它，而cooling的picker允许范围要依赖于heating
        [_periodEditingView setHeatingCooling:period.heating cooling:period.cooling] ;
    }
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.3];
    [_periodEditingView setFrame:frame];
    [UIView commitAnimations];
    
    _periodEditingViewShowing = !_periodEditingViewShowing;
}
- (void)_createHoldEditingViewIfNecessary{
    if (!_holdEditingView) {
        //  获取最底层ScheduleView,这里本来应该把此View添加到self.view的，可以保持低耦合，不过这里为了特殊显示效果，才把_holdEditingView添加到底层ScheduleView的
        UIView *baseView = self.view;
        CGRect bounds = [baseView bounds];
        CGRect frame = CGRectMake(CGRectGetMinX(bounds), CGRectGetMaxY(bounds), bounds.size.width, bounds.size.height);
        _holdEditingView = [[MyETodayHoldEditingView alloc] initWithFrame:frame];
        [_holdEditingView setDelegate:self];
        [baseView addSubview:_holdEditingView];
    }
}
- (void)_toggleHoldEditingView {
    [self _createHoldEditingViewIfNecessary]; // no-op if slideUpView has already been created
    
    CGRect frame = [_holdEditingView frame];
    if (_holdEditingViewShowing) {
        frame.origin.y += frame.size.height;

    } else {
        frame.origin.y -= frame.size.height;
        
        _periodEditingView.periodIndex = self.currentSelectedPeriodIndex;
        
        _holdEditingView.setpoint = self.next24hrsModel.setpoint;
    }
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.3];
    [_holdEditingView setFrame:frame];
    [UIView commitAnimations];
    
    _holdEditingViewShowing = !_holdEditingViewShowing;
}

- (void)_createPeriodInforViewIfNecessary {
    if (!_periodInforView) {
        //  获取底层ScheduleView,这里本来应该把此view添加到self.view的，可以保持低耦合，不过这里为了特殊显示效果，才把_modeEditingView添加到底层ScheduleView的
        UIView *baseView = self.view;
        CGRect bounds = [baseView bounds];
        CGRect frame = CGRectMake(CGRectGetMinX(bounds), CGRectGetMaxY(bounds), bounds.size.width, bounds.size.height);
        _periodInforView = [[MyETodayPeriodInforView alloc] initWithFrame:frame];
        [_periodInforView setDelegate:self];
        [baseView addSubview:_periodInforView];
    }
}
- (void)_togglePeriodInforView {
    [self _createPeriodInforViewIfNecessary]; // no-op if slideUpView has already been created
    
    CGRect frame = [_periodInforView frame];
    if (_periodInforViewShowing) {
        frame.origin.y += frame.size.height;

    } else {
        frame.origin.y -= frame.size.height;
        
        MyETodayPeriodData *period = [self.next24hrsModel.periods objectAtIndex:self.currentSelectedPeriodIndex];
        if(period == nil)
            NSLog(@"error in [MyETodayScheduleController _togglePeriodEditingViewWithType]: period is nil! ");
        
        [_periodInforView setHeating: period.heating];
        [_periodInforView setCooling: period.cooling];
        [_periodInforView setHoldString: period.hold];
    }
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.3];
    [_periodInforView setFrame:frame];
    [UIView commitAnimations];
    
    _periodInforViewShowing = !_periodInforViewShowing;
}

- (void)_createPeriodInforDoughnutViewIfNecessary {
    if (!_periodInforDoughnutView) {
        //  获取底层ScheduleView,这里本来应该把此添加到self.view的，可以保持低耦合，不过这里为了特殊显示效果，才把_modeEditingView添加到底层ScheduleView的
        UIView *baseView = self.view;
        
        CGRect bounds = [baseView bounds];
        // 为了Retina4屏幕而修改的Doughnut圈高度固定
        //        CGRect frame = CGRectMake(CGRectGetMinX(bounds)-5, CGRectGetMinY(bounds), bounds.size.width, bounds.size.height);// x方向向做微调了5
        // CGRect frame = CGRectMake(CGRectGetMinX(bounds)-5, CGRectGetMinY(bounds), bounds.size.width, 367);// x方向向做微调了5 originally 2014-2-24
        CGRect frame = CGRectMake(CGRectGetMinX(bounds), CGRectGetMinY(bounds), bounds.size.width, 307);// x方向向做微调了5  changed @ : 2014-2-24
        _periodInforDoughnutView = [[MyEPeriodInforDoughnutView alloc] initWithFrame:frame];
        _periodInforDoughnutView.doughnutViewRadius = TODAY_DOUGHNUT_VIEW_SIZE / 2;
        [_periodInforDoughnutView setDelegate:self];
        [baseView addSubview:_periodInforDoughnutView];
    }
}
- (void)_togglePeriodInforDoughnutView{
    [self _createPeriodInforDoughnutViewIfNecessary]; // no-op if slideUpView has already been created
    
    if (_periodInforDoughnutViewShowing) {
        [_periodInforDoughnutView setHidden:YES];
        
        self.useWeeklyButton.alpha = 1.0;
        self.applyButton.alpha = 1.0;
    } else {
        [_periodInforDoughnutView setHidden:NO];
        
        self.applyButton.alpha = 0.66;
        self.useWeeklyButton.alpha = 0.66;
        _periodInforDoughnutView.periods = self.next24hrsModel.periods;
    }
    
    _periodInforDoughnutViewShowing = !_periodInforDoughnutViewShowing;
}

#pragma mark
#pragma mark 处理服务器异常数据的函数
// 判定是否服务器相应正常，如果正常返回YES，如果服务器相应为-999/-998，
// 那么函数迫使Navigation View Controller跳转到Houselist view，并返回NO。
// 如果要中断外层函数执行，必须捕捉此函数返回的NO值，并中断外层函数。
- (BOOL)_processHttpRespondForString:(NSString *)respondText {
    NSInteger respondInt = [respondText intValue];// 从字符串开始寻找整数，如果碰到字母就结束，如果字符串不能转换成整数，那么此转换结果就是0
    if (respondInt == -999 || respondInt == -998) {
        
        //首先获取Houselist view controller
        NSMutableArray *allViewControllers = [NSMutableArray arrayWithArray:self.navigationController.viewControllers];
        MyEHouseListViewController *hlvc = [allViewControllers objectAtIndex:0];
        
        //下面代码返回到Houselist viiew
        [self.navigationController popViewControllerAnimated:YES];
        
        // Houselist view controller 从服务器获取最新数据。
        [hlvc downloadModelFromServer ];
        
        //获取当前正在操作的house的name
        NSString *currentHouseName = [hlvc.accountData getHouseNameByHouseId:self.houseId];
        NSString *message;
        
        if (respondInt == -999) {
            message = [NSString stringWithFormat:@"The thermostat of hosue %@ was disconnected.", currentHouseName];
        } else if (respondInt == -998) {
            message = [NSString stringWithFormat:@"The thermostat of hosue %@ was set to Remote Control Disabled.", currentHouseName];
        }
        
        [hlvc showAutoDisappearAlertWithTile:@"Alert" message:message delay:10.0f];
        return NO;
    } 
    return YES;
    
}

@end
