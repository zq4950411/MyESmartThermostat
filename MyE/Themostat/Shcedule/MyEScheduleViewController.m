//
//  MyEScheduleViewController.m
//  MyE
//
//  Created by Ye Yuan on 1/19/12.
//  Copyright (c) 2012 MyEnergy Domain. All rights reserved.
//
#import <QuartzCore/QuartzCore.h>
#import "MyEWeeklyScheduleSubviewController.h"
#import "MyETodayScheduleController.h"
#import "MyENext24HrsScheduleSubviewController.h"
#import "MyEScheduleViewController.h"
#import "MyEMainTabBarController.h"
#import "MyEVacationMasterViewController.h"

#import "MyETipViewController.h"
#import "MyETipDataModel.h"
#import "MyEAccountData.h"
#import "MyESectorView.h"
#import "MyEUtil.h"
#import "SBJson.h"

#import "MyEThermostatData.h"
#import "MyEHouseData.h"

@interface MyEScheduleViewController (PrivateMethods) 
- (void) _createTodayViewControllerIfNescessary;
- (void) _createWeeklyViewControllerIfNescessary;
- (void) _createNext24HrsViewControllerIfNescessary;
@end

@implementation MyEScheduleViewController
@synthesize currentPanelType = _currentPanelType;
@synthesize baseView = _baseView;
@synthesize todayWeeklySwitchButton = _todayWeeklySwitchButton;

@synthesize todayBaseViewController = _todayBaseViewController, weeklyBaseViewController = _weeklyBaseViewController, next24HrsBaseViewController = _next24HrsBaseViewController;
@synthesize vacationViewController = _vacationViewController;

@synthesize userId = _userId;
@synthesize houseId = _houseId;
@synthesize houseName = _houseName;
@synthesize tId = _tId;
@synthesize isRemoteControl = _isRemoteControl;

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    self.parentViewController.navigationItem.rightBarButtonItem.target = self;
    self.parentViewController.navigationItem.rightBarButtonItem.action = @selector(refreshAction);
//    self.parentViewController.title = @"Schedule";
    
    
    [self _createNext24HrsViewControllerIfNescessary];
    self.next24HrsBaseViewController.view.hidden = false;

    UIColor *bgcolor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bgpattern.png"]];
    [self.view setBackgroundColor:bgcolor];

    _currentPanelType = SCHEDULE_TYPE_NEXT24HRS;
        
    NSArray *tipDataArrayToday = [NSArray arrayWithObjects:
                                  [MyETipDataModel tipDataModelWithKey:KEY_FOR_HIDE_TIP_OF_SCHEDULE_TODAY1 title:@"Tip" message:@"Swipe along the circle to adjust the time setting. Double click on the colored block to view/edit the temperature setpoint. However, you cannot change any setpoint that has been or is being executed."], 
                                  [MyETipDataModel tipDataModelWithKey:KEY_FOR_HIDE_TIP_OF_SCHEDULE_TODAY2 title:@"Tip" message:@"When the setpoint is held from Dashboard, the corresponding time block will turn gray. Double tap to view the setpoint."],
                                  nil];
    _tipViewControllerForTodayPanel = [MyETipViewController tipViewControllerWithTipDataArray:tipDataArrayToday];
    
    NSArray *tipDataArrayNext24Hrs = [NSArray arrayWithObjects:
                                      [MyETipDataModel tipDataModelWithKey:KEY_FOR_HIDE_TIP_OF_SCHEDULE_NEXT24HRS1 title:@"Tip" message:@"Swipe along the circle to adjust the time setting. Double click on the colored block to view/edit the temperature setpoint. However, you cannot change any setpoint that has been or is being executed."],
                                      [MyETipDataModel tipDataModelWithKey:KEY_FOR_HIDE_TIP_OF_SCHEDULE_NEXT24HRS2 title:@"Tip" message:@"When the setpoint is held from Dashboard, the corresponding time block will turn gray. Double tap to view the setpoint."],
                                      nil];
    _tipViewControllerForNext24HrsPanel = [MyETipViewController tipViewControllerWithTipDataArray:tipDataArrayNext24Hrs];

    
    NSArray *tipDataArrayWeekly = [NSArray arrayWithObjects:
                                  [MyETipDataModel tipDataModelWithKey:KEY_FOR_HIDE_TIP_OF_SCHEDULE_WEEKLY title:@"Tip" message:@"Swipe along the circle to adjust the time setting. Double click on the colored block to view/edit the temperature setpoint. However, you cannot change any setpoint that has been or is being executed."],
                                  nil];
    _tipViewControllerForWeeklyPanel = [MyETipViewController tipViewControllerWithTipDataArray:tipDataArrayWeekly];
    
    self.title = @"Next24Hrs";
}

- (void)viewDidUnload
{
    
    [self setBaseView:nil];
    [self.todayBaseViewController viewDidUnload];
    [self.next24HrsBaseViewController viewDidUnload];
    [self.weeklyBaseViewController viewDidUnload];
    [self setTodayWeeklySwitchButton:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
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
    
    if (_currentPanelType == SCHEDULE_TYPE_TODAY) {
        [self.todayBaseViewController downloadModelFromServer];
        [_tipViewControllerForTodayPanel showTips];
    } else if (_currentPanelType == SCHEDULE_TYPE_NEXT24HRS){
        [self.next24HrsBaseViewController downloadModelFromServer];
        [_tipViewControllerForNext24HrsPanel showTips];
    } else if (_currentPanelType == SCHEDULE_TYPE_WEEKLY){
        [self.weeklyBaseViewController downloadModelFromServer];
        [_tipViewControllerForWeeklyPanel showTips];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
    NSLog(@"```````````MyEScheduleViewController viewWillDisappear````````````");
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
    NSLog(@"```````````MyEScheduleViewController viewDidDisappear````````````");
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

-(IBAction) toolBarClick:(UIBarButtonItem *) sender
{
    int tag = sender.tag;
    
    if (tag == 0)
    {
        UIToolbar *toolBar = (UIToolbar *)[self.view viewWithTag:10];
        for (UIBarButtonItem *temp in toolBar.items)
        {
            temp.tintColor = nil;
        }
        
        if (sender.tag != 2)
        {
            sender.tintColor = [UIColor blueColor];
        }
        
        [self _createNext24HrsViewControllerIfNescessary];
        [UIView transitionWithView:self.baseView
                          duration:1.0
                           options:UIViewAnimationOptionTransitionFlipFromLeft
                        animations:^{
                            self.todayBaseViewController.view.hidden = YES;
                            self.weeklyBaseViewController.view.hidden = YES;
                            self.next24HrsBaseViewController.view.hidden = NO;
                        }
                        completion:^(BOOL finished){
                            // Save the old data and then swap the views.
                            NSLog(@"switch to Next24Hrs panel");
                            [_tipViewControllerForNext24HrsPanel showTips];
                        }];
        
        [self.next24HrsBaseViewController downloadModelFromServer];
        _currentPanelType = SCHEDULE_TYPE_NEXT24HRS;
        self.title = @"Next24Hrs";
    }
    else if (tag == 1)
    {
        UIToolbar *toolBar = (UIToolbar *)[self.view viewWithTag:10];
        for (UIBarButtonItem *temp in toolBar.items)
        {
            temp.tintColor = nil;
        }
        
        if (sender.tag != 2)
        {
            sender.tintColor = [UIColor blueColor];
        }
        
        [self _createWeeklyViewControllerIfNescessary ];
        [UIView transitionWithView:self.baseView
                          duration:1.0
                           options:UIViewAnimationOptionTransitionFlipFromLeft
                        animations:^{
                            self.todayBaseViewController.view.hidden = YES;
                            self.weeklyBaseViewController.view.hidden = NO;
                            self.next24HrsBaseViewController.view.hidden = YES;
                        }
                        completion:^(BOOL finished){
                            // Save the old data and then swap the views.
                            NSLog(@"switch to Weekly panel");
                            [_tipViewControllerForWeeklyPanel showTips];
                        }];
        
        [self.weeklyBaseViewController downloadModelFromServer];
        _currentPanelType = SCHEDULE_TYPE_WEEKLY;
        self.title = @"Weekly";
    }
    else if (tag == 2)
    {
        [self performSegueWithIdentifier:@"ShowVacation" sender:self];
    }
}

- (IBAction)switchSubPanel:(id)sender
{
    UISegmentedControl *sc = sender;
    if ([sc selectedSegmentIndex] == 0)
    {
        [self _createNext24HrsViewControllerIfNescessary];
        [UIView transitionWithView:self.baseView
                          duration:1.0
                           options:UIViewAnimationOptionTransitionFlipFromLeft
                        animations:^{
                            self.todayBaseViewController.view.hidden = YES;
                            self.weeklyBaseViewController.view.hidden = YES;
                            self.next24HrsBaseViewController.view.hidden = NO;
                        }
                        completion:^(BOOL finished){
                            // Save the old data and then swap the views.
                            NSLog(@"switch to Next24Hrs panel"); 
                            [_tipViewControllerForNext24HrsPanel showTips];
                        }];
        
        [self.next24HrsBaseViewController downloadModelFromServer];
        _currentPanelType = SCHEDULE_TYPE_NEXT24HRS;
    }
    else if ([sc selectedSegmentIndex] == 1)
    {
        [self _createWeeklyViewControllerIfNescessary ];
        [UIView transitionWithView:self.baseView
                          duration:1.0
                           options:UIViewAnimationOptionTransitionFlipFromLeft
                        animations:^{
                            self.todayBaseViewController.view.hidden = YES;
                            self.weeklyBaseViewController.view.hidden = NO;
                            self.next24HrsBaseViewController.view.hidden = YES;
                        }
                        completion:^(BOOL finished){
                            // Save the old data and then swap the views.
                            NSLog(@"switch to Weekly panel"); 
                            [_tipViewControllerForWeeklyPanel showTips];
                        }];
        
        [self.weeklyBaseViewController downloadModelFromServer];
        _currentPanelType = SCHEDULE_TYPE_WEEKLY;
    }
    else if ([sc selectedSegmentIndex] == 2)
    {
        [self performSegueWithIdentifier:@"ShowVacation" sender:self];
    }
}

- (void)refreshAction
{
    if (self.todayBaseViewController.view.hidden == NO)
        [self.todayBaseViewController downloadModelFromServer];
    if (self.weeklyBaseViewController.view.hidden == NO)
        [self.weeklyBaseViewController downloadModelFromServer];
    if (self.next24HrsBaseViewController.view.hidden == NO)
        [self.next24HrsBaseViewController downloadModelFromServer];
    NSLog(@"ScheduleView refresh button is taped");
}


#pragma mark -
#pragma mark private methods
- (void) _createWeeklyViewControllerIfNescessary {
    if(!self.weeklyBaseViewController)
    {
        MyEWeeklyScheduleSubviewController *weeklyScheduleController = [[MyEWeeklyScheduleSubviewController alloc] initWithNibName:@"MyEWeekLyScheduleView" bundle:[NSBundle mainBundle] viewController:self parentController:self];
        weeklyScheduleController.userId = MainDelegate.accountData.userId;
        weeklyScheduleController.houseId = MainDelegate.houseData.houseId;
        weeklyScheduleController.tId = MainDelegate.thermostatData.tId;
        weeklyScheduleController.tName = MainDelegate.thermostatData.tName;
        weeklyScheduleController.isRemoteControl = MainDelegate.thermostatData.remote;
        weeklyScheduleController.navigationController = self.navigationController;
        weeklyScheduleController.delegate = self;
        
        [self.baseView insertSubview:weeklyScheduleController.view atIndex:0];
        self.weeklyBaseViewController = weeklyScheduleController;
        weeklyScheduleController.view.hidden = YES;
    }
}
- (void) _createNext24HrsViewControllerIfNescessary{
    if(!self.next24HrsBaseViewController)
    {
        self.next24HrsBaseViewController = [[MyENext24HrsScheduleSubviewController alloc] initWithNibName:@"MyENext24HrsScheduleView" bundle:[NSBundle mainBundle] viewController:self parentController:self];
        self.next24HrsBaseViewController.userId = MainDelegate.accountData.userId;
        self.next24HrsBaseViewController.houseId = MainDelegate.houseData.houseId;
        self.next24HrsBaseViewController.tId = MainDelegate.thermostatData.tId;
        self.next24HrsBaseViewController.tName = MainDelegate.thermostatData.tName;
        self.next24HrsBaseViewController.isRemoteControl = MainDelegate.thermostatData.remote;
        self.next24HrsBaseViewController.navigationController = self.navigationController;
        self.next24HrsBaseViewController.delegate = self;
        
        [self.baseView insertSubview:self.next24HrsBaseViewController.view atIndex:0];
        self.next24HrsBaseViewController.view.hidden = YES;
    }
}

- (void) _createTodayViewControllerIfNescessary
{
    if(!self.todayBaseViewController)
    {
        self.todayBaseViewController = [[MyETodayScheduleController alloc] init];
        self.todayBaseViewController.userId = MainDelegate.accountData.userId;
        self.todayBaseViewController.houseId = MainDelegate.houseData.houseId;
        self.todayBaseViewController.tId = MainDelegate.thermostatData.tId;
        self.todayBaseViewController.tName = MainDelegate.thermostatData.tName;
        self.todayBaseViewController.isRemoteControl = self.isRemoteControl;
        self.todayBaseViewController.navigationController = self.navigationController;
        self.todayBaseViewController.delegate = self;
        
        //在设置上面两个参数之前，不要在MyETodayScheduleController的init里面调用它的downloadModelFromServer方法
        [self.baseView insertSubview:self.todayBaseViewController.view atIndex:0];
        self.todayBaseViewController.view.hidden = YES;
    }
}

- (void) _createVactionyViewControllerIfNescessary
{
    if(!self.todayBaseViewController)
    {
        self.vacationViewController = [[MyEVacationMasterViewController alloc] initWithNibName:@"MyVacationMasterViewController" bundle:nil];
        
        _vacationViewController.userId = MainDelegate.accountData.userId;
        _vacationViewController.houseId = MainDelegate.houseData.houseId;
        
        _vacationViewController.houseName = MainDelegate.thermostatData.tName;
        _vacationViewController.tId = MainDelegate.thermostatData.tId;
        
        _vacationViewController.tName = MainDelegate.thermostatData.tName;
        _vacationViewController.isRemoteControl = MainDelegate.thermostatData.remote;
        
        //在设置上面两个参数之前，不要在MyETodayScheduleController的init里面调用它的downloadModelFromServer方法
        [self.view insertSubview:self.vacationViewController.view atIndex:0];
        self.todayBaseViewController.view.hidden = YES;
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    
}


@end
