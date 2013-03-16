//
//  MyETodayScheduleController.m
//  MyE
//
//  Created by Ye Yuan on 2/7/12.
//  Copyright (c) 2012 MyEnergy Domain. All rights reserved.
//

#import "MyETodayScheduleController.h"
#import <QuartzCore/QuartzCore.h>
#import "MyETodayPeriodData.h"
#import "MyEScheduleTodayData.h"
#import "MyEHouseListViewController.h"
#import "MyEScheduleViewController.h"
#import "MyEAccountData.h"
#import "SBJson.h"
#import "MyEUtil.h"


@interface MyETodayScheduleController(PrivateMethods)
//根据当前时刻获取跨越当前时刻的sector的id
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

- (void)_applyChange;
- (void)_useWeekly;
@end



@implementation MyETodayScheduleController
@synthesize navigationController = _navigationController;
@synthesize delegate = _delegate;
@synthesize view = _view;
@synthesize todayModel = _todayModel;
@synthesize currentSelectedModeId = _currentSelectedModeId;
@synthesize userId = _userId;
@synthesize houseId = _houseId;
@synthesize tId = _tId;
@synthesize isRemoteControl = _isRemoteControl;

- (id)init {
    self = [super init];
    if (self != nil)
    {
        _periodEditingViewShowing = NO;
        _holdEditingViewShowing = NO;
        _periodInforViewShowing = NO;
        _periodInforDoughnutViewShowing = NO;
                
        CGRect  viewRect = CGRectMake(0, 0, 320, 334);
        UIView *todayView = [[UIView alloc] initWithFrame:viewRect];
//        [todayView setBackgroundColor:[UIColor colorWithRed:0.89f green:0.89f blue:0.999f alpha:0.9f]];
        
        _doughnutView = [[MyEDoughnutView alloc] initWithFrame:CGRectMake(30, 15, TODAY_DOUGHNUT_VIEW_SIZE, TODAY_DOUGHNUT_VIEW_SIZE) delegate:self];
        _doughnutView.delegate = self;
        /*
        self.todayModel = [[MyEScheduleTodayData alloc] initWithJSONString:@"{\"currentTime\":\"7/23/2012 1:20\",\"hold\":2,\"houseId\":419,\"isheatcool\":1,\"periods\":[{\"color\":\"0xfa6748\",\"cooling\":74,\"etid\":1,\"heating\":70,\"hold\":\"None\",\"stid\":0,\"title\":\"Period1\"},{\"color\":\"0xf06e70\",\"cooling\":74,\"etid\":10,\"heating\":69,\"hold\":\"Temporary Hold\",\"stid\":1,\"title\":\"Period2\"},{\"color\":\"0xdd99d8\",\"cooling\":80,\"etid\":26,\"heating\":64,\"hold\":\"None\",\"stid\":10,\"title\":\"Period3\"},{\"color\":\"0xf2cf45\",\"cooling\":75,\"etid\":42,\"heating\":69,\"hold\":\"None\",\"stid\":26,\"title\":\"Period4\"},{\"color\":\"0x5598cb\",\"cooling\":78,\"etid\":48,\"heating\":66,\"hold\":\"None\",\"stid\":42,\"title\":\"Period5\"}],\"setpoint\":69,\"userId\":\"1000100000000000317\",\"weeklyid\":0,\"locWeb\":\"enabled\"}"];
        */
        self.todayModel = [[MyEScheduleTodayData alloc] initWithJSONString:@"{\"currentTime\":\"8/15/2012 12:3\",\"hold\":0,\"houseId\":419,\"isheatcool\":2,\"periods\":[{\"color\":\"0x5598cb\",\"cooling\":80,\"etid\":12,\"heating\":64,\"hold\":\"None\",\"stid\":0,\"title\":\"Period1\"},{\"color\":\"0xfa6748\",\"cooling\":74,\"etid\":16,\"heating\":70,\"hold\":\"None\",\"stid\":12,\"title\":\"Period2\"},{\"color\":\"0xdd99d8\",\"cooling\":85,\"etid\":23,\"heating\":60,\"hold\":\"None\",\"stid\":16,\"title\":\"Period3\"},{\"color\":\"0xf2cf45\",\"cooling\":74,\"etid\":25,\"heating\":70,\"hold\":\"None\",\"stid\":23,\"title\":\"Period4\"},{\"color\":\"0x5598cb\",\"cooling\":80,\"etid\":48,\"heating\":64,\"hold\":\"None\",\"stid\":25,\"title\":\"Period5\"}],\"setpoint\":74,\"userId\":\"1000100000000000317\",\"weeklyid\":0,\"locWeb\":\"enabled\"}"];
        
        NSInteger sectorIdSpaningCurrentTime = [self _sectorIdSpaningCurrentTime];
        NSLog(@"sectorIdSpaningCurrentTime = %i",sectorIdSpaningCurrentTime);
        // 生成hold数组
        NSMutableArray *holdArray = [self.todayModel holdArray];
        _doughnutView.holdArray = holdArray;
        _doughnutView.sectorIdSpaningCurrentTime = sectorIdSpaningCurrentTime;
        
        NSMutableArray * modeIdArray = [self.todayModel modeIdArray];
        //调用这个函数前，如果是Today面板，应该准备好sectorHoldArray，sectorIdSpaningCurrentTime
        //对于today和weekly两种面板，都要准备好并传入模式数组modeIdArray，才能正确绘制。
        [_doughnutView createViewsWithModeArray:modeIdArray scheduleType:SCHEDULE_TYPE_TODAY];
        self.currentSelectedModeId = [[modeIdArray objectAtIndex:sectorIdSpaningCurrentTime] intValue];//用当前时刻所在的sector的modeId作为当前选择的modeId

        [todayView addSubview:_doughnutView];

        self.view = todayView;
        
        _scheduleChangedByUserTouch = NO;

        _applyButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        _applyButton.frame = CGRectMake(CGRectGetMaxX(self.view.bounds)-110, CGRectGetMaxY(self.view.bounds)-50, 100, 35);
        [_applyButton setTitle:@"Apply" forState:UIControlStateNormal];
        [_applyButton setBackgroundImage:[UIImage imageNamed:@"buttonbg.png"] forState:UIControlStateNormal];
        [_applyButton setBackgroundImage:[UIImage imageNamed:@"buttonbgdisabled.png"] forState:UIControlStateDisabled];
        [_applyButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_applyButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateDisabled];
        [_applyButton addTarget:self action:@selector(_applyChange) forControlEvents:UIControlEventTouchUpInside];
        [_applyButton setEnabled:NO];
        [todayView addSubview:_applyButton];
        
        
        
        
        _useWeeklyButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        _useWeeklyButton.frame = CGRectMake(10, CGRectGetMaxY(self.view.bounds) - 50, 100, 35);
        [_useWeeklyButton setTitle:@"Use Weekly" forState:UIControlStateNormal];
        [_useWeeklyButton setBackgroundImage:[UIImage imageNamed:@"buttonbg.png"] forState:UIControlStateNormal];
        [_useWeeklyButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_useWeeklyButton addTarget:self action:@selector(_useWeekly) forControlEvents:UIControlEventTouchUpInside];
        [todayView addSubview:_useWeeklyButton];
        
        
        
        
        // 描绘本容器view的边界，以便于调试
//        CALayer *theLayer= [self.view layer];
//        theLayer.borderColor = [UIColor purpleColor].CGColor;
//        theLayer.borderWidth = 1;
    }
    
    return self;
}
- (void) viewDidUnload {
    
}

-(void) setIsRemoteControl:(BOOL)isRemoteControl {
    _isRemoteControl = isRemoteControl;
    if (!isRemoteControl) {
        _useWeeklyButton.hidden = YES;
        _applyButton.hidden = YES;
    }else {
        _applyButton.hidden = NO;
         _useWeeklyButton.hidden = NO;
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
    
    NSString *urlStr = [NSString stringWithFormat:@"%@?userId=%@&houseId=%i&tId=%@",URL_FOR_TODAY_SCHEDULE_VIEW, self.userId, self.houseId, self.tId];
    MyEDataLoader *downloader = [[MyEDataLoader alloc] initLoadingWithURLString:urlStr postData:nil delegate:self loaderName:@"TodayDownloader" userDataDictionary:nil];
    NSLog(@"%@",downloader.name);
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
    
    NSString *urlStr = [NSString stringWithFormat:@"%@?userId=%@&houseId=%i&tId=%@",URL_FOR_TODAY_DEFAULT_SCHEDULE_VIEW, self.userId, self.houseId, self.tId];
    MyEDataLoader *downloader = [[MyEDataLoader alloc] initLoadingWithURLString:urlStr postData:nil delegate:self loaderName:@"TodayUseWeeklyModelDownloader" userDataDictionary:nil];
    NSLog(@"downloader.name = %@",downloader.name);
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
    
    NSMutableString *body = [NSMutableString stringWithFormat:@"schedule=%@", [[self.todayModel JSONDictionary] JSONRepresentation]];
    NSLog(@"Today ScheduleUploader body is \n%@", body);
    [body replaceOccurrencesOfString:@"\\" withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0,[body length])];
    
    NSString *urlStr = [NSString stringWithFormat:@"%@?userId=%@&houseId=%i&tId=%@",URL_FOR_TODAY_SCHEDULE_SAVE, self.userId, self.houseId, self.tId];
    
    MyEDataLoader *uploader = [[MyEDataLoader alloc] initLoadingWithURLString:urlStr postData:body delegate:self loaderName:@"TodayScheduleUploader" userDataDictionary:nil];
    NSLog(@"TodayScheduleUploader is %@",uploader.name);
    
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
    
    
    NSString *urlStr = [NSString stringWithFormat:@"%@?userId=%@&houseId=%i&tId=%@&setpoint=%i&hold=%i",URL_FOR_TODAY_HOLD_SAVE, self.userId, self.houseId, self.tId, setpoint, hold];
    
    MyEDataLoader *uploader = [[MyEDataLoader alloc] initLoadingWithURLString:urlStr postData:nil delegate:self loaderName:@"TodayHoldUploader" userDataDictionary:nil];
    NSLog(@"TodayHoldUploader.name is %@",uploader.name);
    
}


- (void) didReceiveString:(NSString *)string loaderName:(NSString *)name userDataDictionary:(NSDictionary *)dict{
    NSLog(@"Today schedule JSON String from server is \n%@",string);

    if([name isEqualToString:@"TodayDownloader"]) {
        
        // 判定是否服务器相应正常，如果服务器相应为-999/-998，那么_processHttpRespondForString函数会迫使
        // Navigation View Controller跳转到Houselist view。
        // 如果要中断本层函数执行，必须捕捉_processHttpRespondForString函数返回的NO值，并中断本层函数。
        if (![self _processHttpRespondForString:string])
            return; 
        
        // 获得today model
        MyEScheduleTodayData *todayModel = [[MyEScheduleTodayData alloc] initWithJSONString:string];
        if (todayModel) {
            self.todayModel = todayModel; 
            
            NSInteger sectorIdSpaningCurrentTime = [self _sectorIdSpaningCurrentTime];
            NSLog(@"sectorIdSpaningCurrentTime = %i",sectorIdSpaningCurrentTime);
            // 生成hold数组
            NSMutableArray *holdArray = [self.todayModel holdArray];
            _doughnutView.holdArray = holdArray;
            _doughnutView.sectorIdSpaningCurrentTime = sectorIdSpaningCurrentTime;
            
            NSMutableArray * modeIdArray = [self.todayModel modeIdArray];
            //调用这个函数前，如果是Today面板，应该准备好sectorHoldArray，sectorIdSpaningCurrentTime
            [_doughnutView updateWithModeIdArray:modeIdArray];
            
            _scheduleChangedByUserTouch = NO;
            [_applyButton setEnabled:NO];
            
            //刷新远程控制的状态。 
            self.isRemoteControl = [todayModel.locWeb caseInsensitiveCompare:@"enabled"] == NSOrderedSame;
            
        } else {
            UIAlertView *alert =[[UIAlertView alloc]initWithTitle:@"Error" 
                                                          message:@"Communication error. Please try again."
                                                         delegate:self 
                                                cancelButtonTitle:@"Ok"
                                                otherButtonTitles:nil];
            [alert show];
        }
    } else if([name isEqualToString:@"TodayUseWeeklyModelDownloader"]) {
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
            
            // 获得today model
            MyEScheduleTodayData *todayModel = [[MyEScheduleTodayData alloc] initWithJSONString:string];
            if (todayModel) {
                self.todayModel = todayModel; 
                
                NSInteger sectorIdSpaningCurrentTime = [self _sectorIdSpaningCurrentTime];
                NSLog(@"sectorIdSpaningCurrentTime = %i",sectorIdSpaningCurrentTime);
                // 生成hold数组
                NSMutableArray *holdArray = [self.todayModel holdArray];
                _doughnutView.holdArray = holdArray;
                _doughnutView.sectorIdSpaningCurrentTime = sectorIdSpaningCurrentTime;
                
                NSMutableArray * modeIdArray = [self.todayModel modeIdArray];
                //调用这个函数前，如果是Today面板，应该准备好sectorHoldArray，sectorIdSpaningCurrentTime
                [_doughnutView updateWithModeIdArray:modeIdArray];
                
                _scheduleChangedByUserTouch = NO;
                [_applyButton setEnabled:NO];
            } else {
                UIAlertView *alert =[[UIAlertView alloc]initWithTitle:@"Error" 
                                                              message:@"Communication error. Please try again."
                                                             delegate:self 
                                                    cancelButtonTitle:@"Ok"
                                                    otherButtonTitles:nil];
                [alert show];
            }
        }
    } else if ([name isEqualToString:@"TodayScheduleUploader"]) {
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
        } else if ([string isEqualToString:@"OK"]) {
            _scheduleChangedByUserTouch = NO;
            [_applyButton setEnabled:NO];
        }
    } else if ([name isEqualToString:@"TodayHoldUploader"]) {
        // 判定是否服务器相应正常，如果服务器相应为-999/-998，那么_processHttpRespondForString函数会迫使
        // Navigation View Controller跳转到Houselist view。
        // 如果要中断本层函数执行，必须捕捉_processHttpRespondForString函数返回的NO值，并中断本层函数。
        if (![self _processHttpRespondForString:string])
            return;

        // 获得today model
        MyEScheduleTodayData *todayModel = [[MyEScheduleTodayData alloc] initWithJSONString:string];
        if (todayModel) {
            self.todayModel = todayModel; 
            
            NSInteger sectorIdSpaningCurrentTime = [self _sectorIdSpaningCurrentTime];
            NSLog(@"sectorIdSpaningCurrentTime = %i",sectorIdSpaningCurrentTime);
            // 生成hold数组
            NSMutableArray *holdArray = [self.todayModel holdArray];
            _doughnutView.holdArray = holdArray;
            _doughnutView.sectorIdSpaningCurrentTime = sectorIdSpaningCurrentTime;
            
            NSMutableArray * modeIdArray = [self.todayModel modeIdArray];
            //调用这个函数前，如果是Today面板，应该准备好sectorHoldArray，sectorIdSpaningCurrentTime
            [_doughnutView updateWithModeIdArray:modeIdArray];
            
            _scheduleChangedByUserTouch = NO;
            [_applyButton setEnabled:NO];
        } else {
            UIAlertView *alert =[[UIAlertView alloc]initWithTitle:@"Error" 
                                                          message:@"Communication error. Please try again."
                                                         delegate:self 
                                                cancelButtonTitle:@"Ok"
                                                otherButtonTitles:nil];
            [alert show];
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
#pragma mark MyETodayPeriodEditingViewDelegate methods
- (void) didFinishEditingPeriodIndex:(NSInteger)periodIndex cooling:(float)cooling heating:(float)heating {
    [self _togglePeriodEditingView];
    if(periodIndex >= 0){// periodIndex<0 表示用户点击了period editing panel的Cancel按钮
        [self.todayModel updateWithPeriodIndex:periodIndex heating:heating cooling:cooling];

        //因为编辑了setpoint信息，所以需要把这些信息更新到_doughnutView的数据模型中
        [_doughnutView updateWithModeIdArray:[self.todayModel modeIdArray]];

        
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
        [self uploadHoldModelToServerWithSetpoint:setpoint hold:self.todayModel.hold];
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
        [_applyButton setEnabled:YES];
        [self.todayModel updateWithModeIdArray:modeIdArray];
        _doughnutView.holdArray = [self.todayModel holdArray];//现在允许拖动hold时段了，所以必须更新holdArray
    }
    
    // 下面代码用于修正bug：2.1.	通过涂抹操作调整时间点后，在手抬起来的那一刹那，经常错误触发显示setpoint的单击事件。
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
    NSLog(@"Double touched sector of index: %i", sectorInedx);
    NSMutableArray * modeIdArray = [self.todayModel modeIdArray];
    self.currentSelectedModeId = [[modeIdArray objectAtIndex:sectorInedx] intValue];
    MyETodayPeriodData *period = [self.todayModel.periods objectAtIndex:self.currentSelectedModeId];
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
//    NSArray *holdArray = [self.todayModel holdArray];
//    NSString *hold = [holdArray objectAtIndex:self.currentSelectedModeId];
//    if ([hold caseInsensitiveCompare:@"none"] == NSOrderedSame) {
//        <#statements#>
//    }
    NSMutableDictionary *modeIdColorDictionary = [self.todayModel modeIdColorDictionary];
    return [modeIdColorDictionary objectForKey:[NSNumber numberWithInt:self.currentSelectedModeId]];
}
// 给定modeId，获取它对应的颜色
- (UIColor *)colorForModeId:(NSInteger)modeId
{
    NSMutableDictionary *modeIdColorDictionary = [self.todayModel modeIdColorDictionary];
    return [modeIdColorDictionary objectForKey:[NSNumber numberWithInt:modeId]];
}



@end




@implementation MyETodayScheduleController(PrivateMethods)

- (NSInteger)_sectorIdSpaningCurrentTime
{
    if(self.todayModel ==nil || [self.todayModel.periods count]==0)
        return 0;
    
    // Doughnut view 的类型是Today，就需要设置如下的参数，指定刚好跨越当前时刻的sector
//    NSLog(@"11111from server Current time is %@", self.todayModel.currentTime);
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MM/dd/yyyy HH:mm"];
    [dateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"] ];
    NSDate *currentTime = [dateFormatter dateFromString:self.todayModel.currentTime];
//    NSLog(@"222222from server Current time is %@", currentTime);
    
    // 下面几行是测试用日期格式化器来取得每个分量的字符
    //        NSLog(@"date: %@", [dateFormatter stringFromDate:currentTime]);
    //        [dateFormatter setDateFormat:@"HH"];
    //        NSString *hours = [dateFormatter stringFromDate:currentTime];
    //        [dateFormatter setDateFormat:@"mm"];
    //        NSString *minutes = [dateFormatter stringFromDate:currentTime];
    //        NSLog(@"hours:%@, minutes:%@", hours, minutes);
    
    //下面几行用另外一个方法获得各个分量的字符
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *comps;
    NSInteger unitFlags = NSYearCalendarUnit | 
    NSMonthCalendarUnit |
    NSDayCalendarUnit | 
    NSHourCalendarUnit |
    NSMinuteCalendarUnit;
    
    comps = [calendar components:unitFlags fromDate:currentTime];
    //    int year=[comps year]; 
    //    int month = [comps month];
    //    int day = [comps day];
    int hour = [comps hour];
    int min = [comps minute];
    
    //    NSLog(@"year = %d",year);
    //    NSLog(@"month = %d",month);
    //    NSLog(@"day = %d",day);
    //    NSLog(@"hour = %d",hour);
    //    NSLog(@"min = %d",min);
    
    
    // 在这里加代码计算那个sector跨过当前的时刻。
    NSInteger sectorId = hour *2;
    if (min >= 30) {
        sectorId ++;
    }
    return sectorId;
}

//获取跨越当前时刻的period的最后一个sector的id
- (NSInteger)_lastSectorIdOfPeriodSpaningCurrentTime {
    NSInteger sectorIdSpaningCurrentTime = [self _sectorIdSpaningCurrentTime];
    for (MyETodayPeriodData *period in self.todayModel.periods) {
        // 注意时段的结束半点id是下一个时段的开始半点id，
        if (period.stid <= sectorIdSpaningCurrentTime && period.etid-1 >= sectorIdSpaningCurrentTime) {
            return period.etid-1;
        }
    }
    return NUM_SECTOR - 1;

}

#pragma mark -
#pragma mark methods for mode editing view
- (void)_createPeriodEditingViewIfNecessary {
    
    if (!_periodEditingView) {
        //  获取最底层ScheduleView,这里本来应该把此View添加到self.view的，可以保持低耦合，不过这里为了特殊显示效果，才把_periodEditingView添加到底层ScheduleView的
        UIView *baseView = self.view;
        if (self.delegate)
            baseView = self.delegate.view;
        
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
        
        // 把底层ScheduleView上的Today/Weekly切换按钮启用
        if (self.delegate)
        self.delegate.todayWeeklySwitchButton.enabled = YES;
    } else {
        frame.origin.y -= frame.size.height;
        
        //  把底层ScheduleView上的Today/Weekly切换按钮禁用
        if (self.delegate)
            self.delegate.todayWeeklySwitchButton.enabled = NO;
        
        _periodEditingView.periodIndex = self.currentSelectedModeId;
        
        MyETodayPeriodData *period = [self.todayModel.periods objectAtIndex:self.currentSelectedModeId];
        if(period == nil)
            NSLog(@"error in [MyETodayScheduleController _togglePeriodEditingViewWithType]: period is nil! ");
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
        if (self.delegate)
            baseView = self.delegate.view;
        
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
        
        // 把底层ScheduleView上的Today/Weekly切换按钮启用
        if (self.delegate)
            self.delegate.todayWeeklySwitchButton.enabled = YES;
    } else {
        frame.origin.y -= frame.size.height;
        
        //  把底层ScheduleView上的Today/Weekly切换按钮禁用
        if (self.delegate)
            self.delegate.todayWeeklySwitchButton.enabled = NO;
        
        _periodEditingView.periodIndex = self.currentSelectedModeId;

        _holdEditingView.setpoint = self.todayModel.setpoint;
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
        if (self.delegate)
            baseView = self.delegate.view;

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
        
        //  把底层ScheduleView上的Today/Weekly切换按钮启用
        if (self.delegate)
            self.delegate.todayWeeklySwitchButton.enabled = YES;
    } else {
        frame.origin.y -= frame.size.height;
        
        //  把底层ScheduleView上的Today/Weekly切换按钮禁用
        if (self.delegate)
            self.delegate.todayWeeklySwitchButton.enabled = NO;
        
        MyETodayPeriodData *period = [self.todayModel.periods objectAtIndex:self.currentSelectedModeId];
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
        if (self.delegate)
            baseView = self.delegate.view;

        CGRect bounds = [baseView bounds];
        // 为了Retina4屏幕而修改的Doughnut圈高度固定
//        CGRect frame = CGRectMake(CGRectGetMinX(bounds), CGRectGetMinY(bounds), bounds.size.width, bounds.size.height);
        CGRect frame = CGRectMake(CGRectGetMinX(bounds), CGRectGetMinY(bounds), bounds.size.width, 367);
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
        
        //  把底层ScheduleView上的Today/Weekly切换按钮启用
        if (self.delegate){
            self.delegate.todayWeeklySwitchButton.enabled = YES;
            _useWeeklyButton.alpha = 1.0;

            _applyButton.alpha = 1.0;            
        }
    } else {
        [_periodInforDoughnutView setHidden:NO];
        
        //  把底层ScheduleView上的Today/Weekly切换按钮禁用
        if (self.delegate){
            self.delegate.todayWeeklySwitchButton.enabled = NO;
            _applyButton.alpha = 0.66;
            _useWeeklyButton.alpha = 0.66;
        }
        _periodInforDoughnutView.periods = self.todayModel.periods;
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

#pragma mark button action functions
- (void)_applyChange {
    // 上传当前最新数据到服务器
    [self uploadModelToServer];
}
- (void)_useWeekly {
    [self downloadWeeklyModelFromServer];
}

@end
