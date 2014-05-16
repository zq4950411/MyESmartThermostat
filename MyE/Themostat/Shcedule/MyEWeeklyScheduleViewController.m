//
//  MyEWeeklyScheduleViewController.m
//  MyE
//
//  Created by Ye Yuan on 5/12/14.
//  Copyright (c) 2014 MyEnergy Domain. All rights reserved.
//

#import "MyEWeeklyScheduleViewController.h"
#import "MyEScheduleWeeklyData.h"
#import "MyEScheduleModeData.h"
#import "MyEWeeklyPeriodData.h"
#import "MyEWeekDayItemData.h"
#import "MyEHouseListViewController.h"

#import "MyESectorView.h"
#import "MyEUtil.h"
#import "SBJson.h"

#import "MyEAccountData.h"
#import "MyEHouseData.h"
#import "MyEThermostatData.h"

#define TOOBAR_ANIMATION_DURATION 0.5f

@interface MyEWeeklyScheduleViewController ()
- (void)_restoreToLastUnchanged;
- (void)_createModeEditingViewIfNecessary;
- (void)_toggleModeEditingViewWithType:(ModeEditingViewType)typeOfEditing;

- (void)_createApplyToDaysSelectionViewIfNecessary;
- (void)_toggleApplyToDaysSelectionView;

- (void)_createPeriodInforDoughnutViewIfNecessary;
- (void)_togglePeriodInforDoughnutView;

// 判定是否服务器相应正常，如果正常返回YES，如果服务器相应为-999/-998，
// 那么函数迫使Navigation View Controller跳转到Houselist view，并返回NO。
// 如果要中断外层函数执行，必须捕捉此函数返回的NO值，并中断外层函数。
- (BOOL)_processHttpRespondForString:(NSString *)respondText;
@end

@implementation MyEWeeklyScheduleViewController

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
    _applyToDaysSelectionViewShowing = NO;
    _modeEditingViewShowing = NO;
    _periodInforDoughnutViewShowing = NO;
    _hasLoadFromServer = NO;
    
    
    _modePickerView = [[MyEModePickerView alloc]
                       initWithFrame:CGRectMake((self.view.bounds.size.width - MODE_PICKER_VIEW_WIDTH)*.5,
                                                315,//self.view.bounds.size.height - MODE_PICKER_VIEW_HEIGHT,
                                                MODE_PICKER_VIEW_WIDTH,
                                                MODE_PICKER_VIEW_HEIGHT)
                       delegate:self];
    [self.view addSubview:_modePickerView];
    
    
    CGRect bounds = self.centerContainerView.bounds;
    
    
    
    
    float doughnutViewX = bounds.origin.x + (bounds.size.width - WEEKLY_DOUGHNUT_VIEW_SIZE)/2;
    float doughnutViewY = 0;//最后减去19是为了底下露出一些距离margin
    
    _doughnutView = [[MyEDoughnutView alloc] initWithFrame:CGRectMake(doughnutViewX, doughnutViewY, WEEKLY_DOUGHNUT_VIEW_SIZE, WEEKLY_DOUGHNUT_VIEW_SIZE) delegate:self];
    
    // 在下载之前，先用样例数据进行初始化
    self.weeklyModel = [[MyEScheduleWeeklyData alloc] initWithJSONString:@"{\"currentTime\":\"4/22/2012 19:35\",\"dayItems\":[{\"dayId\":6,\"periods\":[{\"etid\":12,\"modeid\":7183,\"stid\":0},{\"etid\":16,\"modeid\":7180,\"stid\":12},{\"etid\":42,\"modeid\":7181,\"stid\":16},{\"etid\":48,\"modeid\":7183,\"stid\":42}]},{\"dayId\":0,\"periods\":[{\"etid\":12,\"modeid\":7183,\"stid\":0},{\"etid\":16,\"modeid\":7180,\"stid\":12},{\"etid\":34,\"modeid\":7182,\"stid\":16},{\"etid\":42,\"modeid\":7181,\"stid\":34},{\"etid\":48,\"modeid\":7183,\"stid\":42}]},{\"dayId\":1,\"periods\":[{\"etid\":12,\"modeid\":7183,\"stid\":0},{\"etid\":16,\"modeid\":7180,\"stid\":12},{\"etid\":34,\"modeid\":7182,\"stid\":16},{\"etid\":42,\"modeid\":7181,\"stid\":34},{\"etid\":48,\"modeid\":7183,\"stid\":42}]},{\"dayId\":2,\"periods\":[{\"etid\":12,\"modeid\":7183,\"stid\":0},{\"etid\":16,\"modeid\":7180,\"stid\":12},{\"etid\":34,\"modeid\":7182,\"stid\":16},{\"etid\":42,\"modeid\":7181,\"stid\":34},{\"etid\":48,\"modeid\":7183,\"stid\":42}]},{\"dayId\":3,\"periods\":[{\"etid\":12,\"modeid\":7183,\"stid\":0},{\"etid\":16,\"modeid\":7180,\"stid\":12},{\"etid\":34,\"modeid\":7182,\"stid\":16},{\"etid\":42,\"modeid\":7181,\"stid\":34},{\"etid\":48,\"modeid\":7183,\"stid\":42}]},{\"dayId\":4,\"periods\":[{\"etid\":12,\"modeid\":7183,\"stid\":0},{\"etid\":16,\"modeid\":7180,\"stid\":12},{\"etid\":34,\"modeid\":7182,\"stid\":16},{\"etid\":42,\"modeid\":7181,\"stid\":34},{\"etid\":48,\"modeid\":7183,\"stid\":42}]},{\"dayId\":5,\"periods\":[{\"etid\":12,\"modeid\":7183,\"stid\":0},{\"etid\":16,\"modeid\":7180,\"stid\":12},{\"etid\":42,\"modeid\":7181,\"stid\":16},{\"etid\":48,\"modeid\":7183,\"stid\":42}]}],\"houseId\":419,\"modes\":[{\"color\":\"0xffcc66\",\"cooling\":74,\"heating\":70,\"modeName\":\"Rise\",\"modeid\":\"7180\"},{\"color\":\"0x9999ff\",\"cooling\":74,\"heating\":70,\"modeName\":\"Home\",\"modeid\":\"7181\"},{\"color\":\"0xcccccc\",\"cooling\":80,\"heating\":64,\"modeName\":\"Work\",\"modeid\":\"7182\"},{\"color\":\"0x006699\",\"cooling\":78,\"heating\":66,\"modeName\":\"Sleep\",\"modeid\":\"7183\"}],\"userId\":\"1000100000000000317\",\"locWeb\":\"enabled\"}"];
    self.weeklyModelCache = [self.weeklyModel copy];
    
    /* 注意，在服务器传递的数据中，dayItem的dayId对应的关系是：0-Mon, 1-Tue, ..., 5-Sat, 6-Sun, 这个在本程序里面没有用到，
     * 但是服务器程序把dayItem的顺序调整成[{6-Sun}, {0-Mon}, {1-Tue}, {2-Wed}, {3-Thu}, {4-Fri}, {5-Sat}]。
     * 对每个Weekday的Schedule的任何改变，直接写到对应的dayItems的元素中，所以在我们应用里面不要考虑dayItem自带的dayId属性。
     * 为了区分在服务器传递的数据中dayItem的dayId属性和我们这里的自己的weekday排序，这里我们都用变量weekdayId做weekday的id
     * 我们在这里保存的dayItems中的weekdayId和weekday对应关系以及dayItem顺序是: 0-Sun, 1-Mon, 2-Tue, 3-Wed, 4-Thu, 5-Fri, 6-Sat。
     */
    NSMutableArray * modeIdArray = [self.weeklyModel modeIdArrayForWeekdayId:0];
    
    //调用这个函数前，如果是Today面板，应该准备好sectorHoldArray，sectorIdSpaningCurrentTime
    //对于today和weekly两种面板，都要准备好并传入模式数组modeIdArray，才能正确绘制。
    [_doughnutView createViewsWithModeArray:modeIdArray scheduleType:SCHEDULE_TYPE_WEEKLY];
    self.currentSelectedModeId = -1;
    [_modePickerView createOrUpdateThumbScrollViewIfNecessary ];
    
    _scheduleChangedByUserTouch = NO;
    
    [self.applyButton setImage:[UIImage imageNamed:@"apply.png"] forState:UIControlStateNormal];
    //self.applyButton.enabled = NO;
    
    [self.resetButton setImage:[UIImage imageNamed:@"reset_halfcircle.png"] forState:UIControlStateNormal];
    [self.resetButton setImage:[UIImage imageNamed:@"reset_halfcircle_disabled.png"] forState:UIControlStateDisabled];
    self.resetButton.enabled = NO;
    
    NSDate *aDate = [NSDate date];
	NSCalendar *gregorian = [NSCalendar currentCalendar];
	NSDateComponents *weekDayComponents = [gregorian components:NSWeekdayCalendarUnit fromDate:aDate];
	NSInteger week = [weekDayComponents weekday];//此函数取值1-sun, 2-mon, ..., 7-sat
    self.currentWeekdayId = week-1;//设置我们这里所用的今天的星期数，0-sun， 1-mon, ..., 6-sat
    
    [self.centerContainerView insertSubview:_doughnutView atIndex:0];
    [self setIsRemoteControl:MainDelegate.thermostatData.remote];// 重新调用一次，因为有可能在外部第一次设置isRemoteControl]的时候，调用下面的setIsRemoteControl:函数，但那时候View组件还没加载生成完成，那么就可能不能正确设置subviews的可见性。

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
        self.applyButton.hidden = YES;
        self.addNewModeButton.hidden = YES;
        self.editModeButton.hidden = YES;
    }else {
        self.applyButton.hidden = NO;
        self.addNewModeButton.hidden = NO;
        self.editModeButton.hidden = NO;
    }
}

// 更新week day选择
- (void)setCurrentWeekdayId:(NSUInteger)currentWeekdayId {
    _currentWeekdayId = currentWeekdayId;
    NSMutableArray * modeIdArray = [self.weeklyModel modeIdArrayForWeekdayId:currentWeekdayId];
    [self->_doughnutView updateWithModeIdArray:modeIdArray];
    
    // 设置segmentedController toolbar上的相应按钮被选中
    // weekdayId顺序是:               0-sun, 1-mon, 2-Tue, ..., 6-Sat
    // 调整顺序，segmentedControl顺序是:       0-Mon, 1-Tue, ..., 5-Sat, 6-Sun
    NSInteger selectedSegmentIndex = currentWeekdayId-1;
    if (selectedSegmentIndex < 0) {
        selectedSegmentIndex = 6;
    }
    [self.weekdaySegmentedControl setSelectedSegmentIndex:selectedSegmentIndex];
    
}

#pragma mark -
#pragma mark URL Loading System methods

- (void) downloadModelFromServer
{
    if(HUD == nil) {
        HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        //        HUD.dimBackground = YES;//容易产生灰条
        HUD.delegate = self;
    } else
        [HUD show:YES];
    
    NSString *urlStr = [NSString stringWithFormat:@"%@?userId=%@&houseId=%i&tId=%@",GetRequst(URL_FOR_WEEKLY_SCHEDULE_VIEW), MainDelegate.accountData.userId, MainDelegate.houseData.houseId, MainDelegate.thermostatData.tId];
    MyEDataLoader *downloader = [[MyEDataLoader alloc] initLoadingWithURLString:urlStr postData:nil delegate:self loaderName:@"WeeklyScheduleDownloader" userDataDictionary:nil];
    NSLog(@"%@",downloader.name);
}
- (void)uploadModelToServer {
    if(HUD == nil) {
        HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        HUD.delegate = self;
    } else
        [HUD show:YES];
    NSDictionary *dict = [self.weeklyModel JSONDictionary];
    NSMutableString *body = [NSMutableString stringWithFormat:@"schedule=%@", [dict JSONRepresentation]];
    NSLog(@"WeeklyScheduleUploader body is \n%@", body);
    [body replaceOccurrencesOfString:@"\\" withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0,[body length])];
    
    NSString *urlStr = [NSString stringWithFormat:@"%@?userId=%@&houseId=%i&tId=%@&action=saveschedule",GetRequst(URL_FOR_WEEKLY_SCHEDULE_SAVE), MainDelegate.accountData.userId, MainDelegate.houseData.houseId, MainDelegate.thermostatData.tId];
    
    MyEDataLoader *loader = [[MyEDataLoader alloc] initLoadingWithURLString:urlStr postData:body delegate:self loaderName:@"WeeklyScheduleUploader" userDataDictionary:nil];
    NSLog(@"WeeklyScheduleUploader is %@",[loader description]);
}
- (void)uploadToServerEditingMode:(MyEScheduleModeData *)mode {
    if(HUD == nil) {
        HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        HUD.delegate = self;
    } else
        [HUD show:YES];
    
    NSMutableString *body = [NSMutableString stringWithFormat:@"schedule={\"modes\":%@}", [[mode JSONDictionary] JSONRepresentation]];
    NSLog(@"WeeklyScheduleEditingModeUploader body is \n%@", body);
    [body replaceOccurrencesOfString:@"\\" withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0,[body length])];
    
    NSString *urlStr = [NSString stringWithFormat:@"%@?userId=%@&houseId=%i&tId=%@&action=editmode",GetRequst(URL_FOR_WEEKLY_SCHEDULE_SAVE), MainDelegate.accountData.userId, MainDelegate.houseData.houseId, MainDelegate.thermostatData.tId];
    
    MyEDataLoader *loader = [[MyEDataLoader alloc] initLoadingWithURLString:urlStr postData:body delegate:self loaderName:@"WeeklyScheduleEditingModeUploader" userDataDictionary:nil];
    NSLog(@"WeeklyScheduleEditingModeUploader is %@",[loader description]);
}

- (void)uploadToServerDeletingMode:(MyEScheduleModeData *)mode {
    if(HUD == nil) {
        HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        //        HUD.dimBackground = YES;//容易产生灰条
        HUD.delegate = self;
    } else
        [HUD show:YES];
    
    NSMutableString *body = [NSMutableString stringWithFormat:@"schedule={\"modes\":%@}", [[mode JSONDictionary] JSONRepresentation]];
    NSLog(@"WeeklyScheduleDeletingModeUploader body is \n%@", body);
    [body replaceOccurrencesOfString:@"\\" withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0,[body length])];
    
    NSString *urlStr = [NSString stringWithFormat:@"%@?userId=%@&houseId=%i&tId=%@&action=deletemode",GetRequst(URL_FOR_WEEKLY_SCHEDULE_SAVE), MainDelegate.accountData.userId, MainDelegate.houseData.houseId, MainDelegate.thermostatData.tId];
    
    MyEDataLoader *loader = [[MyEDataLoader alloc] initLoadingWithURLString:urlStr postData:body delegate:self loaderName:@"WeeklyScheduleDeletingModeUploader" userDataDictionary:nil];
    NSLog(@"WeeklyScheduleEditingModeUploader is %@",[loader description]);
}

- (void)uploadToServerNewMode:(MyEScheduleModeData *)mode {
    if(HUD == nil) {
        HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        //        HUD.dimBackground = YES;//容易产生灰条
        HUD.delegate = self;
    } else
        [HUD show:YES];
    
    NSMutableString *body = [NSMutableString stringWithFormat:@"schedule={\"modes\":%@}", [[mode JSONDictionary] JSONRepresentation]];
    NSLog(@"WeeklyScheduleNewModeUploader body is \n%@", body);
    [body replaceOccurrencesOfString:@"\\" withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0,[body length])];
    
    NSString *urlStr = [NSString stringWithFormat:@"%@?userId=%@&houseId=%i&tId=%@&action=newmode",GetRequst(URL_FOR_WEEKLY_SCHEDULE_SAVE), MainDelegate.accountData.userId, MainDelegate.houseData.houseId, MainDelegate.thermostatData.tId];
    
    MyEDataLoader *loader = [[MyEDataLoader alloc] initLoadingWithURLString:urlStr postData:body delegate:self loaderName:@"WeeklyScheduleNewModeUploader" userDataDictionary:nil];
    NSLog(@"WeeklyScheduleNewModeUploader is %@",[loader description]);
}

- (void) didReceiveString:(NSString *)string loaderName:(NSString *)name userDataDictionary:(NSDictionary *)dict{
    NSLog(@"Weekly schedule JSON String from server is \n%@",string);
    if([name isEqualToString:@"WeeklyScheduleDownloader"]) {
        // 判定是否服务器相应正常，如果服务器相应为-999/-998，那么_processHttpRespondForString函数会迫使
        // Navigation View Controller跳转到Houselist view。
        // 如果要中断本层函数执行，必须捕捉_processHttpRespondForString函数返回的NO值，并中断本层函数。
        if (![self _processHttpRespondForString:string])
            return;
        
        MyEScheduleWeeklyData *weeklyModel = [[MyEScheduleWeeklyData alloc] initWithJSONString:string];
        if (weeklyModel) {
            self.weeklyModel = weeklyModel;
            self.weeklyModelCache = [self.weeklyModel copy];//更新缓冲数据模型为最新的数据模型
            
            //如果是第一次获取数据，那么_currentWeekdayId就重新计算为当天的星期几，并把view的初始显示设置这个星期几，否则就不计算，下载新数据后view的显示仍然是用户选择的星期几。在本类初始化时会用设备当前时间初始化这个值，但服务器时间和设备时间可能不同，所以需要用服务器时间来在第一次初始化这个值。
            //if (!_hasLoadFromServer) {//现在每次下载新数据都重新显示今天的Week day，故注释此语句;若要记住上次的选择的week day，就取消此注释
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"MM/dd/yyyy HH:mm"];
            
            NSDate *aDate = [dateFormatter dateFromString:self.weeklyModel.currentTime];
            
            NSCalendar *gregorian = [NSCalendar currentCalendar];
            NSDateComponents *weekDayComponents = [gregorian components:NSWeekdayCalendarUnit fromDate:aDate];
            NSInteger week = [weekDayComponents weekday];//此函数取值1-sun, 2-mon, ..., 7-sat
            self.currentWeekdayId = week-1;//设置我们这里所用的今天的星期数，0-sun， 1-mon, ..., 6-sat
            
            //_hasLoadFromServer = YES;//现在每次下载新数据都重新显示今天的Week day，故注释此语句;若要记住上次的选择的week day，就取消此注释
            //}//现在每次下载新数据都重新显示今天的Week day，故注释此语句;若要记住上次的选择的week day，就取消此注释
            
            NSMutableArray * modeIdArray = [self.weeklyModel modeIdArrayForWeekdayId:self.currentWeekdayId];
            [_doughnutView updateWithModeIdArray:modeIdArray];
            
            [_modePickerView createOrUpdateThumbScrollViewIfNecessary ];
            
            _scheduleChangedByUserTouch = NO;
            //self.applyButton.enabled = NO;
            self.resetButton.enabled = NO;
            
            //刷新远程控制的状态。
            [self setIsRemoteControl:[weeklyModel.locWeb caseInsensitiveCompare:@"enabled"] == NSOrderedSame];
        } else {
            UIAlertView *alert =[[UIAlertView alloc]initWithTitle:@"Error"
                                                          message:@"Communication error. Please try again."
                                                         delegate:self
                                                cancelButtonTitle:@"Ok"
                                                otherButtonTitles:nil];
            [alert show];
        }
        
    } else if([name isEqualToString:@"WeeklyScheduleUploader"]) {
        // 判定是否服务器相应正常，如果服务器相应为-999/-998，那么_processHttpRespondForString函数会迫使
        // Navigation View Controller跳转到Houselist view。
        // 如果要中断本层函数执行，必须捕捉_processHttpRespondForString函数返回的NO值，并中断本层函数。
        if (![self _processHttpRespondForString:string])
            return;
        
        if ([string isEqualToString:@"OK"]) {
            _scheduleChangedByUserTouch = NO;
            //self.applyButton.enabled = NO;
            self.resetButton.enabled = NO;
            self.weeklyModelCache = [self.weeklyModel copy];//更新缓冲数据模型为最新的数据模型
        }  else {
            UIAlertView *alert =[[UIAlertView alloc]initWithTitle:@"Error"
                                                          message:string
                                                         delegate:self
                                                cancelButtonTitle:@"Ok"
                                                otherButtonTitles:nil];
            [alert show];
        }
        NSLog(@"WeeklyScheduleUploader result: %@", string);
    } else if([name isEqualToString:@"WeeklyScheduleEditingModeUploader"]) {
        // 判定是否服务器相应正常，如果服务器相应为-999/-998，那么_processHttpRespondForString函数会迫使
        // Navigation View Controller跳转到Houselist view。
        // 如果要中断本层函数执行，必须捕捉_processHttpRespondForString函数返回的NO值，并中断本层函数。
        if (![self _processHttpRespondForString:string])
            return;
        
        // 这些代码只更新界面上的mode和doughnut view，而不发送到服务器，只能等用户点击Apply按钮才能把dayItems和modes一起发送到服务器
        if ([string isEqualToString:@"OK"]) {
            if(_editingPendingMode) {
                MyEScheduleModeData *mode;
                // 首先在mode array里搜寻当前正在编辑的那个mode条目
                for (MyEScheduleModeData *m in self.weeklyModel.metaModeArray) {
                    if (m.modeId == _editingPendingMode.modeId) {
                        mode = m;
                        break;
                    }
                }
                // 然后修改当前正在编辑的那个mode条目到最新的数据，_editingPendingMode里面保存的是刚才编辑待决的最新mode数据
                mode.modeName = _editingPendingMode.modeName;
                mode.modeId = _editingPendingMode.modeId;
                mode.color =  _editingPendingMode.color;
                mode.heating = _editingPendingMode.heating;
                mode.cooling = _editingPendingMode.cooling;
                
                [_doughnutView updateWithModeIdArray:[self.weeklyModel modeIdArrayForWeekdayId:self.currentWeekdayId]];
                [_modePickerView createOrUpdateThumbScrollViewIfNecessary];
                
                _editingPendingMode = nil;
            }
            
            self.currentSelectedModeId = -1;//设置当前默认没有选中任何模式。
            //下面代码会使得mode picker里面的mode都没加亮选中
            if(_modePickerView.currentSelectedThumbModeView != nil)
                _modePickerView.currentSelectedThumbModeView = nil;
        }else {
            UIAlertView *alert =[[UIAlertView alloc]initWithTitle:@"Error"
                                                          message:string
                                                         delegate:self
                                                cancelButtonTitle:@"Ok"
                                                otherButtonTitles:nil];
            [alert show];
        }
    }else if([name isEqualToString:@"WeeklyScheduleNewModeUploader"]) {
        // 判定是否服务器相应正常，如果服务器相应为-999/-998，那么_processHttpRespondForString函数会迫使
        // Navigation View Controller跳转到Houselist view。
        // 如果要中断本层函数执行，必须捕捉_processHttpRespondForString函数返回的NO值，并中断本层函数。
        if (![self _processHttpRespondForString:string])
            return;
        
        NSInteger resultNumber = [string intValue];
        if (resultNumber > 0) { // 表示添加新mode成功，返回的结果resultNumber就是这个mode的真正的modeId
            if(_editingPendingMode) {
                _editingPendingMode.modeId = resultNumber;//更新新的modeId为resultNumber
                [self.weeklyModel.metaModeArray addObject:_editingPendingMode];
                [_doughnutView updateWithModeIdArray:[self.weeklyModel modeIdArrayForWeekdayId:self.currentWeekdayId]];
                [_modePickerView createOrUpdateThumbScrollViewIfNecessary];
                
                _editingPendingMode = nil;
            }
            //这里是编辑模式，不牵涉Schedule的修改，所以不应该由下面两个和Schedule相关标志位的变化，因此注释掉。 2012-06-27.
            //_scheduleChangedByUserTouch = NO;
            //self.applyButton.enabled = NO;
        }else {
            NSString *msg;
            if (resultNumber == -1) {
                msg = @"Sorry, the mode name is taken.";
            } else if (resultNumber == -2) {
                msg = @"CSorry, the mode color is taken.";
            } else{ // if (resultNumber == 0 or other int value)
                msg = @"Communication error. Please try again.";
            }
            UIAlertView *alert =[[UIAlertView alloc]initWithTitle:@"Error"
                                                          message:msg
                                                         delegate:self
                                                cancelButtonTitle:@"Ok"
                                                otherButtonTitles:nil];
            [alert show];
        }
    } else if([name isEqualToString:@"WeeklyScheduleDeletingModeUploader"]) {
        // 判定是否服务器相应正常，如果服务器相应为-999/-998，那么_processHttpRespondForString函数会迫使
        // Navigation View Controller跳转到Houselist view。
        // 如果要中断本层函数执行，必须捕捉_processHttpRespondForString函数返回的NO值，并中断本层函数。
        if (![self _processHttpRespondForString:string])
            return;
        
        if ([string isEqualToString:@"OK"]) {
            if(_editingPendingMode) {
                MyEScheduleModeData *mode;
                // 首先在mode array里搜寻当前正要删除的那个mode条目
                for (MyEScheduleModeData *m in self.weeklyModel.metaModeArray) {
                    if (m.modeId == _editingPendingMode.modeId) {
                        mode = m;
                        break;
                    }
                }
                // 然后删除这个mode
                [self.weeklyModel.metaModeArray removeObject:mode];
                
                [_doughnutView updateWithModeIdArray:[self.weeklyModel modeIdArrayForWeekdayId:self.currentWeekdayId]];
                [_modePickerView createOrUpdateThumbScrollViewIfNecessary];
                
                _editingPendingMode = nil;
            }
            //这里是编辑模式，不牵涉Schedule的修改，所以不应该由下面两个和Schedule相关标志位的变化，因此注释掉。 2012-06-27.
            //_scheduleChangedByUserTouch = NO;
            //self.applyButton.enabled = NO;
        }
        else {
            UIAlertView *alert =[[UIAlertView alloc]initWithTitle:@"Error"
                                                          message:string
                                                         delegate:self
                                                cancelButtonTitle:@"Ok"
                                                otherButtonTitles:nil];
            [alert show];
        }
    }
    
    [HUD hide:YES];
    
    // 在从服务器获得数据后，如果哪个子面板还在显示，就隐藏它
    if (_modeEditingViewShowing) {
        [self _toggleModeEditingViewWithType:ModeEditingViewTypeNew];
    }
    if (_applyToDaysSelectionViewShowing) {
        [self _toggleApplyToDaysSelectionView];
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
#pragma mark MyEDoughnutViewDelegate methods
/** 每当用户手指触摸修改了若干sector的模式，用户手指抬起来后，就向delegate发送这个消息。
 * 如果用户真正修改了schedule，那么传来的参数modeIdArray里面就是最新的schedule数据，
 * 如果用户仅仅是触摸了一下，并没修改schedule，那么传来的参数modeIdArray就是nil，此时，
 * 此函数需要做的就是:self.currentSelectedModeId = -1, 把设置当前默认没有选中任何模式。
 * 下面这个函数就根据用户改变的48个sector的modeId，重构一个时段数组，构成当天的dayItem
 */
- (void)didSchecduleChangeWithModeIdArray:(NSArray *)modeIdArray {
    if (modeIdArray != nil) {
        _scheduleChangedByUserTouch = YES;
        
        //self.applyButton.enabled = YES;
        self.resetButton.enabled = YES;
        
        MyEWeekDayItemData *dayItem = [self.weeklyModel.dayItems objectAtIndex:self.currentWeekdayId];
        [dayItem.periods removeAllObjects] ;
        
        MyEWeeklyPeriodData *period = [[MyEWeeklyPeriodData alloc] init];
        period.stid = 0;
        period.modeId = [[modeIdArray objectAtIndex:0]intValue];
        for (int i = 1; i <=NUM_SECTOR; i++) {
            if (i < NUM_SECTOR) {
                if(period.modeId !=[[modeIdArray objectAtIndex:i]intValue]) {
                    period.etid = i;
                    [dayItem.periods addObject:period];
                    period = [[MyEWeeklyPeriodData alloc] init];
                    period.stid = i;
                    period.modeId = [[modeIdArray objectAtIndex:i]intValue];
                }
            } else {
                period.etid = NUM_SECTOR;
                [dayItem.periods addObject:period];
            }
        }
        NSLog(@"didSchecduleChangeWithModeIdArray");
    }
    self.currentSelectedModeId = -1;//设置当前默认没有选中任何模式。
    //下面代码会使得mode picker里面的mode都没加亮选中
    _modePickerView.currentSelectedThumbModeView = nil;
    
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
    NSLog(@"............in Weekly panel, didDoubleTapSectorIndex");
    NSMutableArray * modeIdArray = [self.weeklyModel modeIdArrayForWeekdayId:self.currentWeekdayId];
    
    self.currentSelectedModeId = [[modeIdArray objectAtIndex:sectorInedx] intValue];
    [self _toggleModeEditingViewWithType:ModeEditingViewTypeEditing];
}

#pragma mark
#pragma mark MyEDoughnutViewDelegate 些方法。
// 返回当前选定的mode的颜色
- (UIColor *)currentModeColor
{
    // 防御性编程，防止当前没有选择模式时取模式颜色
    if( self.currentSelectedModeId == -1)
        return nil;
    
    MyEScheduleModeData *mode;
    // 首先在mode array里搜寻当前选中的mode条目
    for (MyEScheduleModeData *m in self.weeklyModel.metaModeArray) {
        if (m.modeId == _currentSelectedModeId) {
            mode = m;
            break;
        }
    }
    
    return [mode color];
}
// 给定modeId，获取它对应的颜色
- (UIColor *)colorForModeId:(NSInteger)modeId
{
    MyEScheduleModeData *mode;
    // 首先在mode array里搜寻modeId匹配的mode条目
    for (MyEScheduleModeData *m in self.weeklyModel.metaModeArray) {
        if (m.modeId == modeId) {
            mode = m;
            break;
        }
    }
    
    return [mode color];
}

#pragma mark
#pragma mark MyEModeEditingSubviewDelegate methods
- (void) didFinishModeEditingType:(ModeEditingViewType)editingType modeId:(NSInteger)modeId  modeName:(NSString *)modeName color:(UIColor *)color cooling:(float)cooling heating:(float)heating
{
    [self _toggleModeEditingViewWithType:editingType];
    
    if (editingType == ModeEditingViewTypeEditing) {
        
        // 下面代码直接把修改后的新mode发送到服务器，但不发送dayItems，等服务器认证模式编辑成功后，再重写从服务器请求全部数据更新界面
        MyEScheduleModeData *mode = [[MyEScheduleModeData alloc] init];
        mode.modeId = modeId;
        mode.color = color;
        mode.heating = heating;
        mode.cooling = cooling;
        mode.modeName = modeName;
        // 记录下这个操作待决的mode
        _editingPendingMode = mode;
        [self uploadToServerEditingMode:mode];
        
    }else if(editingType == ModeEditingViewTypeNew) {
        
        MyEScheduleModeData *mode = [[MyEScheduleModeData alloc] init];
        mode.modeId = 0;
        mode.color = color;
        mode.heating = heating;
        mode.cooling = cooling;
        mode.modeName = modeName;
        // 记录下这个操作待决的mode
        _editingPendingMode = mode;
        [self uploadToServerNewMode:mode];
        
    } else if(editingType == ModeEditingViewTypeCancel) {
        // do nothing
    }
}
- (void) didFinishDeletingModeId:(NSInteger)modeId {
    [self _toggleModeEditingViewWithType:ModeEditingViewTypeEditing];
    MyEScheduleModeData *mode = [[MyEScheduleModeData alloc] init];
    mode.modeId = modeId;
    mode.color = [UIColor redColor];
    mode.heating = 66;
    mode.cooling = 77;
    mode.modeName = @"somemode";
    
    // 记录下这个操作待决的mode
    _editingPendingMode = mode;
    [self uploadToServerDeletingMode:mode];
    
    self.currentSelectedModeId = -1;//设置当前默认没有选中任何模式。
    //下面代码会使得mode picker里面的mode都没加亮选中
    _modePickerView.currentSelectedThumbModeView = nil;
}
- (BOOL) isModeNameInUse:(NSString *)name exceptCurrentModeId:(NSInteger)modeId{
    return [self.weeklyModel isModeNameInUse:name exceptCurrentModeId:modeId];
}
- (BOOL) isModeColorInUse:(UIColor *)color  exceptCurrentModeId:(NSInteger)modeId{
    return [self.weeklyModel isModeColorInUse:color exceptCurrentModeId:modeId];
}


#pragma mark
#pragma mark MyEApplyToDaysSelectionViewDelegate methods
- (void) didFinishSelectApplyToDays:(NSArray *)days{
    NSLog(@"MyEApplyToDaysSelectionViewDelegate methods : didFinishSelectApplyToDays:(NSArray *)days  is called");
    // 如过days == nil，表示用户点击了‘Cancel’，则先不用上传。
    if(days){
        MyEWeekDayItemData *currentDayItem = [self.weeklyModel.dayItems objectAtIndex:self.currentWeekdayId];
        for (NSNumber *dayId in days) {
            MyEWeekDayItemData *dayItem = [self.weeklyModel.dayItems objectAtIndex:[dayId intValue]];
            [dayItem updatePeriodWithAnother:currentDayItem];
            NSLog(@"%i", [dayId intValue]);
        }
        // 传来days，这里添加代码，修改self.weeklyModel数据，把当前编辑的day的数据应用到所选择的days之中
        [self uploadModelToServer];
    }
    [self _toggleApplyToDaysSelectionView];
}


#pragma mark
#pragma mark MyEMyEModePickerViewDelegate methods
- (void)modePickerView:(MyEModePickerView *)modePickerView didSelectModeId:(NSInteger)modeId {
    self.currentSelectedModeId = modeId;
}
- (void)modePickerView:(MyEModePickerView *)modePickerView didDoubleTapModeId:(NSInteger)modeId {
    self.currentSelectedModeId = modeId;
    [self _toggleModeEditingViewWithType:ModeEditingViewTypeEditing];
}


#pragma mark
#pragma mark MyETodayPeriodInforViewDelegate methods
- (void) didFinishPeriodInforDoughnutView {
    [self _togglePeriodInforDoughnutView];
}

#pragma mark
#pragma mark action methods
- (IBAction)editSelectedMode:(id)sender {
    [self _toggleModeEditingViewWithType:ModeEditingViewTypeEditing];
}

- (IBAction)addNewMode:(id)sender {
    // 添加代码处理新增加mode的功能
    [self _toggleModeEditingViewWithType:ModeEditingViewTypeNew];
}

- (IBAction)applyNewSchedule:(id)sender {
    [self _toggleApplyToDaysSelectionView];
    
}

- (IBAction)resetSchedule:(id)sender {
    [self _restoreToLastUnchanged];
}

- (IBAction)weekdaySegmentedControlValueDidChange:(id)sender {
    //在本App中，weekdayId顺序是:         0-sun, 1-mon, 2-Tue, ..., 6-Sat
    // 调整顺序，因为segmentedControl顺序是       0-Mon, 1-Tue, ..., 5-Sat, 6-Sun
    NSInteger weekdayId = ((UISegmentedControl *)sender).selectedSegmentIndex+1;
    if (weekdayId >6) {
        weekdayId = 0;
    }
    NSLog(@"selected weekdayId = %i", weekdayId);
    self.currentWeekdayId = weekdayId;//星期数，0-sun， 1-mon, ..., 6-sat
}

#pragma mark
#pragma mark privates methods
- (void)_restoreToLastUnchanged{
    //self.weeklyModel = [self.weeklyModelCache copy];//将主数据模型整体恢复为缓冲数据模型里面保持的老的数据，这里不需要恢复Modes部分，所以注释了
    self.weeklyModel.dayItems = [[NSMutableArray alloc] initWithArray:self.weeklyModelCache.dayItems copyItems:YES];//将主数据模型的Schedule(DayItems部分)恢复为缓冲数据模型里面保持的老的数据
    
    NSMutableArray * modeIdArray = [self.weeklyModel modeIdArrayForWeekdayId:self.currentWeekdayId];
    [_doughnutView updateWithModeIdArray:modeIdArray];
    
    _scheduleChangedByUserTouch = NO;
    //self.applyButton.enabled = NO;
    self.resetButton.enabled = NO;
}
- (void)refreshAction
{
    [self downloadModelFromServer];
}

#pragma mark -
#pragma mark methods for mode editing view
- (void)_createModeEditingViewIfNecessary {
    if (!_modeEditingView) {
       
        CGRect bounds = [self.view bounds];
        CGRect frame = CGRectMake(CGRectGetMinX(bounds), CGRectGetMaxY(bounds), bounds.size.width, bounds.size.height);
        _modeEditingView = [[MyEWeeklyModeEditingView alloc] initWithFrame:frame];
        [_modeEditingView setDelegate:self];
        [self.view addSubview:_modeEditingView];
    }
}

- (void)_toggleModeEditingViewWithType:(ModeEditingViewType)typeOfEditing
{
    if (typeOfEditing == ModeEditingViewTypeEditing && self.currentSelectedModeId == -1){
        NSLog(@"\n\nError: 不应该进入这里，不应该在没有选择mode时进入mode编辑模式，请重写检查程序逻辑。\n\n\n");
        return;
    }
    
    [self _createModeEditingViewIfNecessary]; // no-op if slideUpView has already been created
    _modeEditingView.typeOfEditing = typeOfEditing;
    
    // 有可能在编辑mode name的时候，键盘弹出，但这时候再次点击了编辑按钮，就需要把编辑面板隐藏，但键盘不隐藏，就需要调用下面语句隐藏键盘，
    [_modeEditingView.nameTextField resignFirstResponder];
    CGRect frame = [_modeEditingView frame];
    if (_modeEditingViewShowing) {//假如正在显示，则隐藏
        frame.origin.y += frame.size.height;

    } else {//假如正在隐藏，则显示
        //首先设置是否允许远程控制操作
        [_modeEditingView setRemoteControlEnabled:MainDelegate.thermostatData.remote];
        
        frame.origin.y -= frame.size.height;

        
        if(typeOfEditing == ModeEditingViewTypeEditing) { //显示编辑现存模式的面板
            BOOL isSystemMode = NO;// 标记是否是系统默认属性，metaModeArray里面的前四个始终是系统默认属性，不允许删除，但可以修改。
            MyEScheduleModeData *mode;
            // 首先在mode array里搜寻当前选中的mode条目
            for (int i = 0; i < [self.weeklyModel.metaModeArray count]; i++) {
                mode = [self.weeklyModel.metaModeArray objectAtIndex:i];
                if (mode.modeId == self.currentSelectedModeId) {
                    if (i < 4) {
                        isSystemMode = YES;
                    }
                    break;
                }
            }
            
            if(mode == nil)
                NSLog(@"error in [MyEWeeklyScheduleSubviewController _toggleModeEditingView]: mode is nil! ");
            
            if (isSystemMode) {
                _modeEditingView.delButton.hidden = YES;
            } else {
                _modeEditingView.delButton.hidden = NO;
            }
            _modeEditingView.modeId = self.currentSelectedModeId;
            _modeEditingView.modeColor = [self currentModeColor];
            //注意必须先设置heating，再设置cooling，因为heating的picker允许范围不依赖其它，而cooling的picker允许范围要依赖于heating
            _modeEditingView.heating = mode.heating;
            _modeEditingView.cooling = mode.cooling;
            _modeEditingView.modeName = mode.modeName;
            
        } else {
            _modeEditingView.modeId = 0;
            _modeEditingView.modeName = @"newmode";
            _modeEditingView.modeColor = [self currentModeColor];
            //注意必须先设置heating，再设置cooling，因为heating的picker允许范围不依赖其它，而cooling的picker允许范围要依赖于heating
            _modeEditingView.heating = 70;
            _modeEditingView.cooling = 74;
        }
    }
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.3];
    [_modeEditingView setFrame:frame];
    [UIView commitAnimations];
    
    _modeEditingViewShowing = !_modeEditingViewShowing;
}
#pragma mark -
#pragma mark methods for Apply To days selection view
- (void)_createApplyToDaysSelectionViewIfNecessary {
    if (!_weeklyDaySelectionView) {
        CGRect bounds = [self.view bounds];
        CGRect frame = CGRectMake(CGRectGetMinX(bounds), CGRectGetMaxY(bounds), bounds.size.width, bounds.size.height);
        _weeklyDaySelectionView = [[MyEWeeklyDaySelectionView alloc] initWithFrame:frame];
        [_weeklyDaySelectionView setDelegate:self];
        [self.view addSubview:_weeklyDaySelectionView];
    }
}
- (void)_toggleApplyToDaysSelectionView
{
    [self _createApplyToDaysSelectionViewIfNecessary]; // no-op if slideUpView has already been created
    
    
    CGRect frame = [_weeklyDaySelectionView frame];
    if (_applyToDaysSelectionViewShowing) {//假如正在显示，则隐藏
        frame.origin.y += frame.size.height;
    } else {//假如正在隐藏，则显示
        frame.origin.y -= frame.size.height;
        [_weeklyDaySelectionView setCurrentWeekdayIndex:self.currentWeekdayId];
    }
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.3];
    [_weeklyDaySelectionView setFrame:frame];
    [UIView commitAnimations];
    
    _applyToDaysSelectionViewShowing = !_applyToDaysSelectionViewShowing;
}


- (void)_createPeriodInforDoughnutViewIfNecessary {
    if (!_periodInforDoughnutView) {
        
        CGRect bounds = [self.view bounds];
        
        // 为了Retina4屏幕而修改的Doughnut圈高度固定
        //CGRect frame = CGRectMake(CGRectGetMinX(bounds), CGRectGetMinY(bounds), bounds.size.width, bounds.size.height);
        //        CGRect frame = CGRectMake(CGRectGetMinX(bounds), CGRectGetMinY(bounds), bounds.size.width, 367);
        CGRect frame = CGRectMake(CGRectGetMinX(bounds), CGRectGetMinY(bounds), bounds.size.width, 327);
        
        _periodInforDoughnutView = [[MyEPeriodInforDoughnutView alloc] initWithFrame:frame];
        _periodInforDoughnutView.doughnutViewRadius = WEEKLY_DOUGHNUT_VIEW_SIZE / 2;
        _periodInforDoughnutView.doughnutCenterOffsetY = 12;
        [_periodInforDoughnutView setDelegate:self];
        [self.view addSubview:_periodInforDoughnutView];
    }
}
- (void)_togglePeriodInforDoughnutView{
    [self _createPeriodInforDoughnutViewIfNecessary]; // no-op if slideUpView has already been created
    
    if (_periodInforDoughnutViewShowing) {
        [_periodInforDoughnutView setHidden:YES];
        
        //  把底层ScheduleView上的Today/Weekly切换按钮启用

            _resetButton.alpha = 1;
            _applyButton.alpha = 1;
            _modePickerView.alpha = 1.0f;
            _weeklyDaySelectionView.alpha = 1.0f;
            _addNewModeButton.alpha = 1.0f;
            _editModeButton.alpha = 1.0f;

    } else {
        [_periodInforDoughnutView setHidden:NO];
        
        //  把底层ScheduleView上的Today/Weekly切换按钮禁用

            _resetButton.alpha = 0.66;
            _applyButton.alpha = 0.66;
            _modePickerView.alpha = 0.66f;
            _weeklyDaySelectionView.alpha = 0.66f;
            _addNewModeButton.alpha = 0.66f;
            _editModeButton.alpha = 0.66f;
        
        _periodInforDoughnutView.periods = [self.weeklyModel periodsForWeekdayId:self.currentWeekdayId];
    }
    
    
    
    _periodInforDoughnutViewShowing = !_periodInforDoughnutViewShowing;
}


#pragma mark -
#pragma mark private methods
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
        NSString *currentHouseName = [hlvc.accountData getHouseNameByHouseId:MainDelegate.houseData.houseId];
        NSString *message;
        
        if (respondInt == -999) {
            message = [NSString stringWithFormat:@"The thermostat of hosue %@ was disconnected now.", currentHouseName];
        } else if (respondInt == -998) {
            message = [NSString stringWithFormat:@"The thermostat of hosue %@ was set to Remote Control Disabled.", currentHouseName];
        }
        
        [hlvc showAutoDisappearAlertWithTile:@"Alert" message:message delay:10.0f];
        return NO;
    }
    return YES;
    
}

@end