//
//  MyEDashboardViewController.m
//  MyE
//
//  Created by Ye Yuan on 1/19/12.
//  Copyright (c) 2012 MyEnergy Domain. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import <AudioToolbox/AudioServices.h>
#import "MyEDashboardViewController.h"
#import "MyELoginViewController.h"
#import "MyEDashboardData.h"
#import "MyEHouseListViewController.h"
#import "MyEAccountData.h"
#import "MyETipViewController.h"
#import "MyETipDataModel.h"
#import "MyEUtil.h"
#import "SBJson.h"

#import "KxMenu.h"
#import "UIColor+FlatUI.h"

#import "MyEThermostatData.h"
#import "MyEHouseData.h"
#import "SWRevealViewController.h"


#import "CDCircleOverlayView.h"

#define CIRCLE_ORIGIN_X 30
#define CIRCLE_ORIGIN_Y 40
#define CIRCLE_DIAMETER 260

@interface MyEDashboardViewController ()
- (void)configureView;
- (void)_toggleFanControlToolbarView;
- (void)_toggleSystemControlToolbarView;

// 判定是否服务器相应正常，如果正常返回YES，如果服务器相应为-999/-998，
// 那么函数迫使Navigation View Controller跳转到Houselist view，并返回NO。
// 如果要中断外层函数执行，必须捕捉此函数返回的NO值，并中断外层函数。
- (BOOL)_processHttpRespondForString:(NSString *)respondText;
- (void)_holdRunButtionAction;
- (void)_addHoldRunButtonForType:(NSInteger)type;


#pragma mark 触摸圆环使用的变量
@property (nonatomic, assign) NSInteger totalDegree; // 触摸开始的度数设置为零, 此变量记录了一个触摸周期中累计触摸旋转的度数
@property (nonatomic, assign) NSInteger minVal;
@property (nonatomic, assign) NSInteger maxVal;
@property (nonatomic, assign) NSInteger currentVal;// 用于在某次触摸过程中,  记录最新的值.
@property (nonatomic, retain) CDCircle *circle;

@property (nonatomic, weak) UIButton *holdRunButton;
@property (nonatomic, assign) BOOL inHoldAnimation;// YES: 在动画中, NO: 不在动画中, // for test, 将来用hold信息来控制
@end

@implementation MyEDashboardViewController
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

-(void) go:(UIButton *) sender
{
    [self performSegueWithIdentifier:@"ShowSchedule" sender:self];
}


#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    BOOL isRC = (MainDelegate.thermostatData.remote == 0? NO:YES);
    self.userId = MainDelegate.accountData.userId;
    self.houseId = MainDelegate.houseData.houseId;
    self.houseName = MainDelegate.houseData.houseName;
    self.tId = MainDelegate.thermostatData.tId;
    self.tName = MainDelegate.thermostatData.tName;
    self.isRemoteControl = isRC;

    
    self.fUISwitch.offColor = [UIColor whiteColor];
    self.fUISwitch.onColor = [UIColor whiteColor];
    
    self.fUISwitch.offBackgroundColor = [UIColor grayColor];
    self.fUISwitch.onBackgroundColor = [UIColor grayColor];
    
    self.fUISwitch.onLabel.text = @"";
    self.fUISwitch.offLabel.text = @"";
    
    
    [self.fUIButton setStyleType:ACPButtonOK];
    
    [self.fUIButton setTitleColor:[UIColor cloudsColor] forState:UIControlStateNormal];
    [self.fUIButton setTitleColor:[UIColor cloudsColor] forState:UIControlStateHighlighted];
    [self.fUIButton addTarget:self action:@selector(go:) forControlEvents:UIControlEventTouchUpInside];
    
    if (IS_IPHONE_5)
    {
        self.fUIButton.frame = CGRectMake(20, 400, 278, 44);
    }
    else
    {
        self.fUIButton.frame = CGRectMake(20, 311, 278, 44);
    }
    
    [self.view bringSubviewToFront:self.fanControlToolbarView];
    [self.view bringSubviewToFront:self.systemControlToolbarView];
    
    
    
    [self.controlModeBtn setStyleType:ACPButtonOK];
    [self.controlModeBtn setStyle:[UIColor clearColor] andBottomColor:[UIColor clearColor]];
    [self.fanStatusBtn setStyleType:ACPButtonOK];
    [self.fanStatusBtn setStyle:[UIColor clearColor] andBottomColor:[UIColor clearColor]];
    
    
    
    // 设置面板背景为一个图片模式
    UIColor *bgcolor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bgpattern.png"]];
    [self.view setBackgroundColor:bgcolor];
    
   
    _isSetpointChanged = NO;
    _isSystemControlToolbarViewShowing = NO;
    _isFanControlToolbarViewShowing = NO;
    
    [self.systemControlEmgHeatingButton setBackgroundImage:[UIImage imageNamed:@"Tb_EmgHDisabled.png"] forState:UIControlStateDisabled];
    [self.systemControlEmgHeatingButton setBackgroundImage:[UIImage imageNamed:@"Tb_EmgH01.png"] forState:UIControlStateNormal];
    
    NSArray *tipDataArray = [NSArray arrayWithObjects:
                             [MyETipDataModel tipDataModelWithKey:KEY_FOR_HIDE_TIP_OF_DASHBOARD1 title:@"Tip" message:@"Click on the icons to bring up the system and fan mode menu."],
                             [MyETipDataModel tipDataModelWithKey:KEY_FOR_HIDE_TIP_OF_DASHBOARD2 title:@"Tip" message:@"You can check which thermostat you are currently viewing by double-tapping the navigation bar."],
                             nil];
    _tipViewController = [MyETipViewController tipViewControllerWithTipDataArray:tipDataArray];
    
    
    
    // 下面是触摸圆环Circle
    _minVal = 55;
    _maxVal = 90;
    self.selectedSegment = 80;
    
    self.circle = [[CDCircle alloc] initWithFrame:CGRectMake(CIRCLE_ORIGIN_X , CIRCLE_ORIGIN_Y, CIRCLE_DIAMETER, CIRCLE_DIAMETER) numberOfSegments:(360 / STEP_DEGREE) ringWidth:50.f];
    self.circle.dataSource = self;
    self.circle.delegate = self;
    CDCircleOverlayView *overlay = [[CDCircleOverlayView alloc] initWithCircle:self.circle];
    
    for (CDCircleThumb *thumb in self.circle.thumbs) {
        [thumb.iconView setHighlitedIconColor:[UIColor whiteColor]];
        thumb.separatorColor = [UIColor colorWithRed:0.08 green:0.8 blue:0.8 alpha:1];
        thumb.separatorStyle = CDCircleThumbsSeparatorBasic;
        thumb.gradientFill = NO;
        thumb.arcColor = [UIColor colorWithRed:75.0/255.0 green:180.0/255.0 blue:200.0/255.0 alpha:1.0];
//        thumb.gradientColors = [NSArray arrayWithObjects:(id) [UIColor blackColor].CGColor, (id) [UIColor yellowColor].CGColor, (id) [UIColor blueColor].CGColor, nil];
//        thumb.colorsLocations = [NSMutableArray arrayWithObjects:[NSNumber numberWithFloat:0.00f], [NSNumber numberWithFloat:0.30f], [NSNumber numberWithFloat:1.00f], nil];
        
    }
    
    [self.view addSubview:self.circle];
    [self.view addSubview:overlay];
    
    
    
    [self _addHoldRunButtonForType:0];
    self.inHoldAnimation = NO; // for testing
    
    
    

}

- (void)chooseHouse:(KxMenuItem *) sender
{
    MyEThermostatData *the = [MainDelegate.houseData.thermostats objectAtIndex:sender.tag];
    if (![the.tId isEqualToString:MainDelegate.thermostatData.tId])
    {
        MainDelegate.thermostatData = the;
        if (MainDelegate.isRemember)
        {
            [MainDelegate setValue:the.tId withKey:KEY_FOR_TID_LAST_VIEWED];
        }
        [self refreshAction];
    }
}

-(void) switchThermostat:(UIBarButtonItem *) sender
{
    NSMutableArray *items = [NSMutableArray array];
    for (int i = 0; i < [MainDelegate.houseData.thermostats count]; i++)
    {
        MyEThermostatData *t = [MainDelegate.houseData.thermostats objectAtIndex:i];
        if (t.tName && t.deviceType == 0)
        {
            KxMenuItem *item = [KxMenuItem menuItem:t.tName
                                              image:nil
                                             target:self
                                             action:@selector(chooseHouse:)];
            
            if ([t.tId isEqualToString:MainDelegate.thermostatData.tId])
            {
                item.foreColor = [UIColor redColor];
            }
            else
            {
                item.foreColor = [UIColor whiteColor];
            }
            
            item.tag = i;
            [items addObject:item];
        }
    }
    if (items.count > 0)
    {
        CGRect rect = CGRectMake(233, 4 - 30, 10, 35);
        [KxMenu showMenuInView:self.view
                      fromRect:rect
                     menuItems:items];
    }
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.parentViewController.navigationItem.title = @"Thermostat";
    self.parentViewController.navigationItem.rightBarButtonItems = nil;
    
//    UIBarButtonItem *tButton = [[UIBarButtonItem alloc] initWithTitle:@"T" style:UIBarButtonItemStyleBordered target:self action:@selector(switchThermostat:)];
    UIBarButtonItem *tButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"T-switch.png"] style:UIBarButtonItemStyleBordered target:self action:@selector(switchThermostat:)];
    
    UIBarButtonItem *refreshButton = [[UIBarButtonItem alloc] 
                                  initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh 
                                  target:self 
                                  action:@selector(refreshAction)];
    self.parentViewController.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:refreshButton,tButton, nil];
    
    [self downloadModelFromServer];

    [_tipViewController showTips];
    
    // 显示提示信息,下面函数仅用于测试自定义UIAlertView，这里不再用了
    // [self showAlertWithMessage:@"Click on the icons to bring up the system and fan mode menu.\n\n" messageId:@"dashobard1" ];    
}
// 显示提示信息,下面函数仅用于测试自定义UIAlertView，这里不再用了
- (void)showAlertWithMessage:(NSString *)message messageId:(NSString *)mid {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Tips" 
                                                    message:[NSString stringWithFormat:@"%@\n", message]
                                                   delegate:self 
                                          cancelButtonTitle:@"Close" 
                                          otherButtonTitles: nil];   
    [alert show];
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(220, 10, 40, 40)];
    NSString *path = [[NSString alloc] initWithString:[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"Vacation01.png"]];
    UIImage *bkgImg = [[UIImage alloc] initWithContentsOfFile:path];
    [imageView setImage:bkgImg];
    [alert addSubview:imageView];
    
    CGRect rect = [alert bounds];
    
    CGRect labelRect = CGRectMake(15, rect.size.height - 100, 170, 27);
    UILabel *label = [[UILabel alloc] initWithFrame:labelRect];
    UIFont *myFont=[UIFont  fontWithName:@"Helvetica"  size:11];
    label.font = myFont;//用label来设置字体大小
    label.text = @"I knew. Don't show this one again.";
    label.backgroundColor = [UIColor clearColor];
    [alert addSubview:label];
    
    CGRect switchRect = CGRectMake(rect.size.width  - 90, rect.size.height  - 100, 79, 27);
    UISwitch *switchView = [[UISwitch alloc] initWithFrame:switchRect];
    switchView.on = YES;//设置初始为ON的一边
    [alert addSubview:switchView];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

#pragma mark -
#pragma mark URL Loading System methods

- (void) downloadModelFromServer
{
    if(HUD == nil) {
        HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];

        HUD.delegate = self;
    } else
        [HUD show:YES];
    NSString *urlStr = [NSString stringWithFormat:@"%@?userId=%@&houseId=%i&tId=%@",GetRequst(URL_FOR_DASHBOARD_VIEW), MainDelegate.accountData.userId, MainDelegate.houseData.houseId, MainDelegate.thermostatData.tId];
    MyEDataLoader *downloader = [[MyEDataLoader alloc] initLoadingWithURLString:urlStr postData:nil delegate:self loaderName:@"DashboardDownloader"  userDataDictionary:nil];
    NSLog(@"DashboardDownloader is %@, url is %@",downloader.name, urlStr);
}
- (void)uploadModelToServer {
    if(HUD == nil) {
        HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        HUD.delegate = self;
    } else
        [HUD show:YES];
    NSString *body = [NSString stringWithFormat:@"datamodel=%@", [[self.dashboardData JSONDictionary] JSONRepresentation]];
    NSLog(@"upload dashboar body is \n%@",body);
    
    NSString *urlStr = [NSString stringWithFormat:@"%@?userId=%@&houseId=%i&tId=%@",GetRequst(URL_FOR_DASHBOARD_SAVE), MainDelegate.accountData.userId, MainDelegate.houseData.houseId, MainDelegate.thermostatData.tId];
    MyEDataLoader *loader = [[MyEDataLoader alloc] initLoadingWithURLString:urlStr postData:body delegate:self loaderName:@"DashboardUploader" userDataDictionary:nil];
    NSLog(@"DashboardUploader is %@",[loader description]);
    [loadTimer invalidate];
    loadTimer = nil;
}
- (void) didReceiveString:(NSString *)string loaderName:(NSString *)name userDataDictionary:(NSDictionary *)dict{
    if([name isEqualToString:@"DashboardDownloader"]) {
        [HUD hide:YES];
        NSLog(@"DashboardDownloader string from server is \n %@", string);
        
        // 判定是否服务器相应正常，如果服务器相应为-999/-998，那么_processHttpRespondForString函数会迫使
        // Navigation View Controller跳转到Houselist view。
        // 如果要中断本层函数执行，必须捕捉_processHttpRespondForString函数返回的NO值，并中断本层函数。
        if (![self _processHttpRespondForString:string])
            return;
        
        MyEDashboardData *dashboardData = [[MyEDashboardData alloc] initWithJSONString:string];
        if (dashboardData) {
            [self setDashboardData:dashboardData]; 
            _isSetpointChanged = NO;
        } else {
            UIAlertView *alert =[[UIAlertView alloc]initWithTitle:@"Error" 
                                                          message:@"Communication error. Please try again."
                                                         delegate:self 
                                                cancelButtonTitle:@"Ok"
                                                otherButtonTitles:nil];
            [alert show];
        }
    }
    if([name isEqualToString:@"DashboardUploader"]) {
        NSLog(@"DashboardUploader upload with result: %@", string);
        
        // 判定是否服务器相应正常，如果服务器相应为-999/-998，那么_processHttpRespondForString函数会迫使
        // Navigation View Controller跳转到Houselist view。
        // 如果要中断本层函数执行，必须捕捉_processHttpRespondForString函数返回的NO值，并中断本层函数。
        if (![self _processHttpRespondForString:string])
            return;
        
        // 加3秒延迟后再从服务器下载新数据，否则太快下载，Thermostat好像还没真正改变过来，传来的"realControlMode"字段还是上一个状态
        loadTimer = [NSTimer scheduledTimerWithTimeInterval:3.5f
                                                     target:self 
                                                   selector:@selector(downloadModelFromServer) 
                                                   userInfo:nil 
                                                    repeats:NO]; 

    }
    // 在从服务器获得数据后，如果哪个子面板还在显示，就隐藏它
    if (_isSystemControlToolbarViewShowing) {
        [self _toggleSystemControlToolbarView];
    }
    if (_isFanControlToolbarViewShowing) {
        [self _toggleFanControlToolbarView];
    }
}
- (void) connection:(NSURLConnection *)connection didFailWithError:(NSError *)error loaderName:(NSString *)name{
    UIAlertView *alert =[[UIAlertView alloc]initWithTitle:@"Error" 
                                                  message:@"Communication error. Please try again."
                                                 delegate:self 
                                        cancelButtonTitle:@"Ok"
                                        otherButtonTitles:nil];
    [alert show];
    
    // inform the user
    NSLog(@"Connection of %@ failed! Error - %@ %@",name,
          [error localizedDescription],
          [[error userInfo] objectForKey:NSURLErrorFailingURLStringErrorKey]);
    [HUD hide:YES];
}




#pragma mark -
#pragma mark 设置properties 属性的方法
- (void)setDashboardData:(MyEDashboardData *) newDashboardData
{
    if (_dashboardData != newDashboardData) {
        _dashboardData = newDashboardData;
        
        // Update the view.
        //此语句在第一次从TableView转到DashboardView时不起效，只能在viewDidLoad方法中更新view.
        [self configureView];
    }
}
- (void)setIsRemoteControl:(BOOL) isRemoteControl
{
    _isRemoteControl = isRemoteControl;
    
    // Update the view.
    self.fUISwitch.enabled = isRemoteControl;
    
//    self.setpointPickerView.alpha = isRemoteControl ? 1.0 : 0.77;
    self.controlModeImageView.alpha = isRemoteControl ? 1.0 : 0.77;
    self.fanImageView.alpha = isRemoteControl ? 1.0 : 0.77;
    if(!isRemoteControl) {
        // Create the layer if necessary.
        if(!_maskLayer) {
            _maskLayer = [[CALayer alloc] init];
            
            CGRect bounds = self.view.bounds;
            //create a cglayer and draw the background graphic to it
            CGContextRef context = MyECreateBitmapContext(bounds.size.width, bounds.size.height);
            
            
            
            
            CGContextSaveGState(context);
            CGContextAddRect(context, bounds);
            CGContextEOClip(context);
            
            
            CGGradientRef myGradient;
            CGColorSpaceRef myColorspace;
            size_t num_locations = 2;
            CGFloat locations[2] = { 0.0, 1.0 };
            CGFloat components[8] = { 0.0, 0.0, 0.0, 0.05, // Start color开始颜色位于view矩形中心，
                0.0, 0.0, 0.0, 0.1 }; // End color
            myColorspace = CGColorSpaceCreateDeviceRGB();
            myGradient = CGGradientCreateWithColorComponents (myColorspace, components,
                                                              locations, num_locations);
            CGPoint centerPoint;
            centerPoint.x = bounds.origin.x + bounds.size.width/2;
            centerPoint.y = bounds.origin.y + bounds.size.height/2;
            
            CGContextDrawRadialGradient(context, myGradient, centerPoint, 80, centerPoint, bounds.size.height/2, kCGGradientDrawsAfterEndLocation | kCGGradientDrawsBeforeStartLocation);
            CGGradientRelease(myGradient);
            CGColorSpaceRelease (myColorspace);
            CGContextRestoreGState(context);
            
            
            
            
            
            
            CGImageRef myMaskImg = CGBitmapContextCreateImage(context);
            UIImage *layerContents = [UIImage imageWithCGImage:myMaskImg];
            CGContextRelease(context);
            CGImageRelease(myMaskImg);
            
            CGSize imageSize = layerContents.size;
            
            _maskLayer.bounds = CGRectMake(0, 0, imageSize.width, imageSize.height);
            _maskLayer.contents = (id)layerContents.CGImage;
            
        }
        
        // Add the layer to the view.
        [self.view.layer addSublayer:_maskLayer];
        
        // Center the layer in the view.
        _maskLayer.position = CGPointMake(CGRectGetMidX(self.view.bounds), CGRectGetMidY(self.view.bounds));
        
        self.view.userInteractionEnabled = NO;
    } else {
        self.view.userInteractionEnabled = YES;
        [_maskLayer removeFromSuperlayer];
    }
}

#pragma mark
#pragma mark private methods
- (void)configureView
{
    // Update the user interface for the detail item.
    MyEDashboardData *theDashboardData = self.dashboardData;

    //刷新远程控制的状态。
    self.isRemoteControl = [theDashboardData.locWeb caseInsensitiveCompare:@"enabled"] == NSOrderedSame;
        
    if (theDashboardData) {
        switch (theDashboardData.controlMode) {
            case 1://Heat
                if ([theDashboardData.realControlMode caseInsensitiveCompare:@"Heating"] == NSOrderedSame) {
                    self.controlModeImageView.animationImages = [NSArray arrayWithObjects:    
                                                                 [UIImage imageNamed:@"Ctrl_Heating01.png"],
                                                                 [UIImage imageNamed:@"Ctrl_Heating02.png"], nil];
                    self.controlModeImageView.animationDuration = ANIMATION_DURATION;
                    self.controlModeImageView.animationRepeatCount = 0;
                    [self.controlModeImageView startAnimating];
                    
                } else if ([theDashboardData.realControlMode caseInsensitiveCompare:@"Off"] == NSOrderedSame) {
                    self.controlModeImageView.animationImages = [NSArray arrayWithObjects:    
                                                                 [UIImage imageNamed:@"Ctrl_Heating01.png"], nil];
                    self.controlModeImageView.animationDuration = ANIMATION_DURATION;
                    self.controlModeImageView.animationRepeatCount = 0;
                    [self.controlModeImageView startAnimating];
                }

                break;
            case 2://Cool
                if ([theDashboardData.realControlMode caseInsensitiveCompare:@"Cooling"] == NSOrderedSame) {
                    self.controlModeImageView.animationImages = [NSArray arrayWithObjects:    
                                                                 [UIImage imageNamed:@"Ctrl_Cooling01.png"],
                                                                 [UIImage imageNamed:@"Ctrl_Cooling02.png"], nil];
                    self.controlModeImageView.animationDuration = ANIMATION_DURATION;
                    self.controlModeImageView.animationRepeatCount = 0;
                    [self.controlModeImageView startAnimating];
                } else if ([theDashboardData.realControlMode caseInsensitiveCompare:@"Off"] == NSOrderedSame) {
                    self.controlModeImageView.animationImages = [NSArray arrayWithObjects:    
                                                                 [UIImage imageNamed:@"Ctrl_Cooling01.png"], nil];
                    self.controlModeImageView.animationDuration = ANIMATION_DURATION;
                    self.controlModeImageView.animationRepeatCount = 0;
                    [self.controlModeImageView startAnimating];
                }
                break;
            case 3://Auto
                if (theDashboardData.isheatcool == 1) {//Heat
                    if ([theDashboardData.realControlMode caseInsensitiveCompare:@"Heating"] == NSOrderedSame) {
                        self.controlModeImageView.animationImages = [NSArray arrayWithObjects:    
                                                                     [UIImage imageNamed:@"Ctrl_Auto-Heating01.png"],
                                                                     [UIImage imageNamed:@"Ctrl_Auto-Heating02.png"], nil];
                        self.controlModeImageView.animationDuration = ANIMATION_DURATION;
                        self.controlModeImageView.animationRepeatCount = 0;
                        [self.controlModeImageView startAnimating];
                        
                    } else if ([theDashboardData.realControlMode caseInsensitiveCompare:@"Off"] == NSOrderedSame) {
                        self.controlModeImageView.animationImages = [NSArray arrayWithObjects:    
                                                                     [UIImage imageNamed:@"Ctrl_Auto-Heating01.png"], nil];
                        self.controlModeImageView.animationDuration = ANIMATION_DURATION;
                        self.controlModeImageView.animationRepeatCount = 0;
                        [self.controlModeImageView startAnimating];
                    }
                }else if(theDashboardData.isheatcool == 2){ //Cool
                    if ([theDashboardData.realControlMode caseInsensitiveCompare:@"Cooling"] == NSOrderedSame) {
                        self.controlModeImageView.animationImages = [NSArray arrayWithObjects:    
                                                                     [UIImage imageNamed:@"Ctrl_Auto-Cooling01.png"],
                                                                     [UIImage imageNamed:@"Ctrl_Auto-Cooling02.png"], nil];
                        self.controlModeImageView.animationDuration = ANIMATION_DURATION;
                        self.controlModeImageView.animationRepeatCount = 0;
                        [self.controlModeImageView startAnimating];
                    } else if ([theDashboardData.realControlMode caseInsensitiveCompare:@"Off"] == NSOrderedSame) {
                        self.controlModeImageView.animationImages = [NSArray arrayWithObjects:    
                                                                     [UIImage imageNamed:@"Ctrl_Auto-Cooling01.png"], nil];
                        self.controlModeImageView.animationDuration = ANIMATION_DURATION;
                        self.controlModeImageView.animationRepeatCount = 0;
                        [self.controlModeImageView startAnimating];
                    }

                }
                break;
            case 4:// 此时一定有([theDashboardData.realControlMode caseInsensitiveCompare:@"Emg Heat"] == NSOrderedSame)
                self.controlModeImageView.animationImages = [NSArray arrayWithObjects:    
                                                             [UIImage imageNamed:@"Ctrl_EmgH-01.png"],
                                                             [UIImage imageNamed:@"Ctrl_EmgH-02.png"], nil];
                self.controlModeImageView.animationDuration = ANIMATION_DURATION;
                self.controlModeImageView.animationRepeatCount = 0;
                [self.controlModeImageView startAnimating];
                break;
            case 5:
                //都用动画后，好像这样直接赋值一个静态图片不清作用，还没深入研究why
                //self.controlModeImageView.image = [UIImage imageNamed:@"Ctrl_Off.png"];
                self.controlModeImageView.animationImages = [NSArray arrayWithObjects:    
                                                             [UIImage imageNamed:@"Ctrl_Off.png"], nil];
                self.controlModeImageView.animationDuration = ANIMATION_DURATION;
                self.controlModeImageView.animationRepeatCount = 0;
                [self.controlModeImageView startAnimating];
                break;
            default:
                break;
        }

        
        NSString *levelString;
        if ([theDashboardData.realControlMode caseInsensitiveCompare:@"Off"] == NSOrderedSame) 
        {
            levelString = @"";
        }
        else
        {
            switch (theDashboardData.stageLevel) {
                case 0:
                    levelString = @"";
                    break;
                case 1:
                    levelString = @"stage 1";
                    break;
                case 2:
                    levelString = @"stage 1+2 ";
                    break;
                case 3:
                    levelString = @"stage 1+2 ";
                    break;
                case 4:
                    levelString = @"stage 1";
                    break;
                case 5:
                    levelString = @"stage 1+2 ";
                    break;
                    
                default:
                    break;
            }
        }
        
        if (theDashboardData.aux == 1)
        {
            levelString = [NSString stringWithFormat:@"%@%@",levelString,@"Aux"];
        }
        
        self.stageLevelLabel.text = levelString;
        
        if (theDashboardData.fan_control == 0) {//auto
            if([theDashboardData.fan_status caseInsensitiveCompare:@"on"] == NSOrderedSame) {
                //===========================注意更新下面图片使用带Auto文字的
                self.fanImageView.animationImages = [NSArray arrayWithObjects:    
                                                     [UIImage imageNamed:@"Ctrl_FanAuto-01.png"],
                                                     [UIImage imageNamed:@"Ctrl_FanAuto-02.png"],
                                                     [UIImage imageNamed:@"Ctrl_FanAuto-03.png"], nil];
                self.fanImageView.animationDuration = ANIMATION_DURATION;
                self.fanImageView.animationRepeatCount = 0;
                [self.fanImageView startAnimating];
                
                self.fanStatusLabel.text = @"Auto";
                
            } else if([theDashboardData.fan_status caseInsensitiveCompare:@"off"] == NSOrderedSame) {
                // 展示两种从Bundle中找到图像文件信息装载该图像文件的例子
                //都用动画后，好像下面这样直接赋值一个静态图片不清作用，还没深入研究why
                //            NSString* imagePath = [[NSBundle mainBundle] pathForResource:@"Ctrl_FanOff" ofType:@"png"];
                //            self.fanImageView.image = [[UIImage alloc] initWithContentsOfFile:imagePath];//[UIImage imageNamed:@"Ctrl_FanOff.png"];
                
                //========================注意更新下面图片使用带Auto文字的
                self.fanImageView.animationImages = [NSArray arrayWithObjects:    
                                                     [UIImage imageNamed:@"Ctrl_FanAuto-01"], nil];
                self.fanImageView.animationDuration = ANIMATION_DURATION;
                self.fanImageView.animationRepeatCount = 0;
                [self.fanImageView startAnimating];
                self.fanStatusLabel.text = @"Off";
            }

        }else if (theDashboardData.fan_control == 1) {//on
            self.fanImageView.animationImages = [NSArray arrayWithObjects:    
                                                 [UIImage imageNamed:@"Ctrl_FanOn-01.png"],
                                                 [UIImage imageNamed:@"Ctrl_FanOn-02.png"],
                                                 [UIImage imageNamed:@"Ctrl_FanOn-03.png"], nil];
            self.fanImageView.animationDuration = ANIMATION_DURATION;
            self.fanImageView.animationRepeatCount = 0;
            [self.fanImageView startAnimating];
            self.fanStatusLabel.text = @"On";
        }
        
        // 如果是在关闭状态，setpoint就设置为不可访问
        [self.circle setNeedsLayout];
        self.selectedSegment = theDashboardData.setpoint;
        if (theDashboardData.controlMode ==5)
        {
            self.circle.userInteractionEnabled = NO;

            self.fUISwitch.hidden = YES;
            self.holdRunLabel.hidden = YES;
            self.holdRunButton.userInteractionEnabled = NO;
            
            self.activeProgramLabel.text = @"None";
        }
        else {
            self.circle.userInteractionEnabled = YES;
            [self.holdRunButton setTitle:[NSString stringWithFormat:@"%d\u00B0F", theDashboardData.setpoint] forState:UIControlStateNormal];

            self.fUISwitch.hidden = NO;
            self.holdRunLabel.hidden = NO;
            self.holdRunButton.userInteractionEnabled = YES;
            
            self.activeProgramLabel.text = theDashboardData.currentProgram;
        }
        
        if(theDashboardData.isOvrried == 0)
        {

            [self.fUISwitch setOn:NO animated:YES];
            self.holdRunLabel.text = @"Press to Hold";
        }
        else
        {
            [self.fUISwitch setOn:YES animated:YES];
            self.holdRunLabel.text = @"Press to Run";
        }
        
        
        
        // 这里不需要在每次下载新数据时判定是否Remote NO，否则会产生一种情况：操作中变为Remote No的时候没有提示文字并返回House List，而是直接 disable掉控制面板了. 2012-05-29
        //[self setRemoteControlEnabled:[theDashboardData.locWeb caseInsensitiveCompare:@"enabled"] == NSOrderedSame];

    }
}

- (NSInteger)_getToolbarOffset
{
    NSInteger offset = 200;
    if (IS_IPHONE_5) // for 4 inch screen
    {
        if(IS_IOS6)
            offset = 210;
        else // iOS 7 and above
            offset = 95;
    }
    else // for 3.5 inch screen
    {
        if(IS_IOS6)
            offset = 300;
        else // iOS 7 and above
            offset = 185;
    }

    return offset;
}

- (void)_toggleSystemControlToolbarView{
    if (_isFanControlToolbarViewShowing) {
        [self _toggleFanControlToolbarView];
    }
    if (self.dashboardData.con_hp == 1) {
        self.systemControlEmgHeatingButton.enabled = YES;
    } else {
        [self.view bringSubviewToFront:self.systemControlToolbarView];
        self.systemControlEmgHeatingButton.enabled = NO;
    }
    
    if(_isSystemControlToolbarViewShowing){
        self.systemControlToolbarView.hidden = YES;
    }else {
        self.systemControlToolbarView.hidden = NO;
    }
    
    _isSystemControlToolbarViewShowing = !_isSystemControlToolbarViewShowing;
}
- (void)_toggleFanControlToolbarView{
    if (_isSystemControlToolbarViewShowing) {
        [self _toggleSystemControlToolbarView];
    }
    if (_isFanControlToolbarViewShowing) {
        self.fanControlToolbarView.hidden = YES;
    } else {
        [self.view bringSubviewToFront:self.fanControlToolbarView];
        self.fanControlToolbarView.hidden = NO;
    }
    
    _isFanControlToolbarViewShowing = !_isFanControlToolbarViewShowing;
}
//- (void)_toggleSystemControlToolbarView
//{
//    if (_isFanControlToolbarViewShowing) {
//        [self _toggleFanControlToolbarView];
//    }
//    if (self.dashboardData.con_hp == 1) {
//        self.systemControlEmgHeatingButton.enabled = YES;
//    } else {
//        self.systemControlEmgHeatingButton.enabled = NO;
//    }
//    
//    NSInteger offset = [self _getToolbarOffset];
//    CGRect frame = [self.systemControlToolbarView frame];
//
//    frame.origin.x = 0;//不知为何toolbar被右移了一个点, 这里校正一下
//    if (_isSystemControlToolbarViewShowing) {
//        frame.origin.y = frame.origin.y+offset;
//    } else {
//        frame.origin.y = frame.origin.y-offset;
//    }
//
//    [UIView beginAnimations:nil context:nil];
//    [UIView setAnimationDuration:0.3];
//    [self.systemControlToolbarView setFrame:frame];
//    [UIView commitAnimations];
//    
//    _isSystemControlToolbarViewShowing = !_isSystemControlToolbarViewShowing;
//}
//- (void)_toggleFanControlToolbarView
//{
//    NSInteger offset = [self _getToolbarOffset];
//    if (_isSystemControlToolbarViewShowing) {
//        [self _toggleSystemControlToolbarView];
//    }
//    
//    CGRect frame = [self.fanControlToolbarView frame];
//    NSLog(@"%f  %f  %f  %f",frame.origin.x,frame.origin.y,frame.size.width,frame.size.height);
//
//    frame.origin.x = 0;//不知为何toolbar被右移了一个点, 这里校正一下
//    if (_isFanControlToolbarViewShowing) {
//        frame.origin.y = frame.origin.y+offset;
//    } else {
//        frame.origin.y = frame.origin.y-offset;
//    }
//
//    
//    [UIView beginAnimations:nil context:nil];
//    [UIView setAnimationDuration:0.3];
//    [self.fanControlToolbarView setFrame:frame];
//    [UIView commitAnimations];
//    
//    _isFanControlToolbarViewShowing = !_isFanControlToolbarViewShowing;
//}

// 判定是否服务器相应正常，如果正常返回一些字符串，如果服务器相应为-999/-998，
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
- (void)_holdRunButtionAction
{
    [self _addHoldRunButtonForType:1];
    CALayer *myLayer = self.holdRunButton.layer;
    if(!self.inHoldAnimation){
        CABasicAnimation *theAnimation;
        theAnimation=[CABasicAnimation animationWithKeyPath:@"shadowOpacity"];
        theAnimation.duration=0.5;
        theAnimation.repeatCount=HUGE_VALF;
        theAnimation.autoreverses=YES;
        theAnimation.fromValue=[NSNumber numberWithFloat:1.0];
        theAnimation.toValue=[NSNumber numberWithFloat:0.2];
        [myLayer addAnimation:theAnimation forKey:@"animateOpacity"]; // here key is defined by developer
        self.inHoldAnimation = YES;
    } else{
        [myLayer removeAnimationForKey:@"animateOpacity" ];
        self.inHoldAnimation = NO;
        [self _addHoldRunButtonForType:2];
    }
}

// type: 0 -> red, 1 -> green, 2 -> blue
-(void)_addHoldRunButtonForType:(NSInteger)type
{
    if (self.holdRunButton) {
        [self.holdRunButton removeFromSuperview];
        self.holdRunButton = Nil;
    }
    CGFloat diameter = CIRCLE_DIAMETER - (self.circle.ringWidth + 20.0) * 2.0;
    CGRect bounds = CGRectMake(CIRCLE_ORIGIN_X + (self.circle.ringWidth + 20.0),
                               CIRCLE_ORIGIN_Y + (self.circle.ringWidth + 20.0),
                               diameter,diameter);
    NSLog(@"x=%f, y=%f, w=%f, h=%f", self.circle.bounds.origin.x, self.circle.bounds.origin.y, bounds.size.width, bounds
.size.height);
    self.holdRunButton = [UIButton buttonWithType:UIButtonTypeCustom];
    //    [self.holdRunButton setImage:[UIImage imageNamed:@"Micky.png"] forState:UIControlStateNormal];
    [self.holdRunButton addTarget:self action:@selector(_holdRunButtionAction) forControlEvents:UIControlEventTouchUpInside];
    [self.holdRunButton setTitle:[NSString stringWithFormat:@"%i\u00B0F", self.selectedSegment] forState:UIControlStateNormal];
    self.holdRunButton.frame = bounds;//    CGRectMake(100.0, 160.0, 120.0, 120.0);
    self.holdRunButton.clipsToBounds = YES;
    [self.holdRunButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.holdRunButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
    [self.holdRunButton.titleLabel setFont:[UIFont boldSystemFontOfSize:35]];
    
    self.holdRunButton.layer.cornerRadius = 60;//half of the width
//    self.holdRunButton.layer.borderColor=[UIColor redColor].CGColor;
//    self.holdRunButton.layer.borderWidth=2.0f;
    //    self.holdRunButton.layer.backgroundColor=[UIColor greenColor].CGColor; // 此句会遮住或阻止阴影, 所以注释
    
    if (type == 0){
        self.holdRunButton.layer.shadowColor = [UIColor colorWithRed:60.0/255.0 green:30.0/255.0 blue:15.0/255.0 alpha:0.75].CGColor;
    } else if(type == 1){
        self.holdRunButton.layer.shadowColor = [UIColor colorWithRed:20.0/255.0 green:25.0/255.0 blue:5.0/255.0 alpha:0.75].CGColor;
    }else
        self.holdRunButton.layer.shadowColor = [UIColor colorWithRed:10.0/255.0 green:40.0/255.0 blue:45.0/255.0 alpha:0.75].CGColor;
    //    self.holdRunButton.layer.shadowOffset = CGSizeMake(2.0f, 2.0f);
    self.holdRunButton.layer.shadowRadius = 15.0f;
    self.holdRunButton.layer.shadowOpacity = 0.75f;
    self.holdRunButton.layer.shadowPath = [UIBezierPath bezierPathWithArcCenter:CGPointMake(self.holdRunButton.bounds.origin.x + self.holdRunButton.bounds.size.width/2.0, self.holdRunButton.bounds.origin.y + self.holdRunButton.bounds.size.height/2.0) radius:self.holdRunButton.bounds.size.height/2.0f startAngle:0 endAngle:2*M_PI clockwise:YES].CGPath;
    
    //@see http://stackoverflow.com/questions/10133109/fastest-way-to-do-shadows-on-ios
    self.holdRunButton.layer.shouldRasterize = YES;
    // Don't forget the rasterization scale
    // I spent days trying to figure out why retina display assets weren't working as expected
    self.holdRunButton.layer.rasterizationScale = [UIScreen mainScreen].scale;
    
    
    // 用一个image做Highlighted背景
    UIGraphicsBeginImageContext(self.holdRunButton.bounds.size);
    [self.holdRunButton.layer renderInContext:UIGraphicsGetCurrentContext()];
    [[UIColor yellowColor] setFill];
    UIBezierPath* bPath = [UIBezierPath bezierPathWithArcCenter:CGPointMake(self.holdRunButton.bounds.origin.x + self.holdRunButton.bounds.size.width/2.0, self.holdRunButton.bounds.origin.y + self.holdRunButton.bounds.size.height/2.0) radius:self.holdRunButton.bounds.size.height/2.0f -5 startAngle:0 endAngle:2*M_PI clockwise:YES];
    [bPath fill];
    UIImage *colorImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    [self.holdRunButton setBackgroundImage:colorImage forState:UIControlStateHighlighted];
    
    // 用一个image做Normal背景
    UIGraphicsBeginImageContext(self.holdRunButton.bounds.size);
    [self.holdRunButton.layer renderInContext:UIGraphicsGetCurrentContext()];
    if (type == 0) {
        [[UIColor colorWithRed:230.0/255.0 green:125.0/255.0 blue:30.0/255.0 alpha:1.0] setFill];
    }else if( type == 1) {
        [[UIColor colorWithRed:130.0/255.0 green:190.0/256 blue:60.0/255.0 alpha:1.0] setFill];
    }else if( type == 2) {
        [[UIColor colorWithRed:75.0/255.0 green:190.0/255.0 blue:215.0/255.0 alpha:1.0] setFill];
    }
    
    bPath = [UIBezierPath bezierPathWithArcCenter:CGPointMake(self.holdRunButton.bounds.origin.x + self.holdRunButton.bounds.size.width/2.0, self.holdRunButton.bounds.origin.y + self.holdRunButton.bounds.size.height/2.0) radius:self.holdRunButton.bounds.size.height/2.0f -5 startAngle:0 endAngle:2*M_PI clockwise:YES];
    [bPath fill];
    colorImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    [self.holdRunButton setBackgroundImage:colorImage forState:UIControlStateNormal];
    
    
    [self.view addSubview:self.holdRunButton];
    //    self.holdRunButton.alpha = 0.5;
    
    [self.view bringSubviewToFront:self.holdRunLabel];
}
#pragma mark
#pragma mark 触摸圆环 CDCircleDelegate delegate & data source
-(void) circleToucheBegan: (CDCircle *) circle // 发送一个信号表示触摸开始
{
    _totalDegree = 0;
    NSLog(@"begin代理");
}
-(void) circle:(CDCircle *)circle didMoveToSegment:(NSInteger)segment thumb:(CDCircleThumb *)thumb {
    NSInteger steps = (NSInteger)(_totalDegree/STEP_DEGREE);
    NSLog(@"end代理   累计度数 %d, 累计步: %d", _totalDegree, steps);
    NSInteger newValue = steps+self.selectedSegment;
    if (newValue > _maxVal) {
        newValue = _maxVal;
    }
    if (newValue < _minVal) {
        newValue = _minVal;
    }
    self.selectedSegment = newValue;
    // 旋转结束要进行设置清空
    _totalDegree = 0;
    
    if (self.dashboardData.controlMode == 5) //如果控制模式是off，就不允许使用这个picker，picker也只显示一个off
        return;
    
    if (self.dashboardData.setpoint != self.selectedSegment) {
        self.dashboardData.setpoint = self.selectedSegment;
        if ([loadTimer isValid]) {
            [loadTimer invalidate];
            loadTimer = nil;
        }
        //如果当前这个值是1、2，按钮显示Run，此时如果用户修改了setpoint，此时仍然维持temporary/permanent hold的状态，并上传服务器，override状态保持不变直到用户点击Run取消hold；
        if (self.dashboardData.isOvrried == 0)
            self.dashboardData.isOvrried = 2;
        _isSetpointChanged = YES;
        loadTimer = [NSTimer scheduledTimerWithTimeInterval:LOAD_DELAY
                                                     target:self
                                                   selector:@selector(uploadModelToServer)
                                                   userInfo:nil
                                                    repeats:NO];
    }

}
-(void) circle: (CDCircle *) circle didMoveDegree:(NSInteger) degree {
    _totalDegree += degree;
    NSInteger steps = (NSInteger)(_totalDegree/STEP_DEGREE);
    NSInteger newValue = steps+self.selectedSegment;
    
    NSLog(@"move代理 累计度数 %d, 累计步: %d, 原来块=%d, newValue=%d", _totalDegree, steps, self.selectedSegment, newValue);
    if (newValue > _maxVal) {
        newValue = _maxVal;
    }
    if (newValue < _minVal) {
        newValue = _minVal;
    }
    if(newValue != self.currentVal){
        self.currentVal = newValue;
        SystemSoundID soundID;
        NSString *filePath = [[NSBundle mainBundle] pathForResource:@"iPod Click" ofType:@"aiff"];
        NSURL *fileUrl = [NSURL fileURLWithPath:filePath];
        AudioServicesCreateSystemSoundID((__bridge CFURLRef)fileUrl, &soundID);
        AudioServicesPlaySystemSound(soundID);
    }
    [self.holdRunButton setTitle:[NSString stringWithFormat:@"%i\u00B0F", newValue] forState:UIControlStateNormal];
}
-(UIImage *) circle:(CDCircle *)circle iconForThumbAtRow:(NSInteger)row {
//    NSString *fileString = [[[NSBundle mainBundle] pathsForResourcesOfType:@"png" inDirectory:nil] lastObject];
//    return [UIImage imageWithContentsOfFile:fileString];

    return [UIImage imageNamed:@"icon_arrow_up.png"];
}



#pragma mark -
#pragma mark MBProgressHUDDelegate methods

- (void)hudWasHidden:(MBProgressHUD *)hud {
	// Remove HUD from screen when the HUD was hidded
	[HUD removeFromSuperview];
	HUD = nil;
}

#pragma mark
#pragma mark 插座方法
- (IBAction)changeControlMode:(id)sender {  
    [self _toggleSystemControlToolbarView];
}

- (IBAction)changeFanControl:(id)sender {
    [self _toggleFanControlToolbarView];
}

- (IBAction)changeControlModeToHeatingAction:(id)sender {
    [self _toggleSystemControlToolbarView];    
    if (self.dashboardData.controlMode != 1) {
        self.dashboardData.controlMode = 1;
        [self uploadModelToServer];
    } 
}

- (IBAction)changeControlModeToCoolingAction:(id)sender {
   [self _toggleSystemControlToolbarView];
    if (self.dashboardData.controlMode != 2) {
        self.dashboardData.controlMode = 2;
        [self uploadModelToServer];
    }
}

- (IBAction)changeControlModeToAutoAction:(id)sender {
    [self _toggleSystemControlToolbarView];
    if (self.dashboardData.controlMode != 3) {
        self.dashboardData.controlMode = 3;
        [self uploadModelToServer];
    }
}

- (IBAction)changeControlModeToEmgHeatingAction:(id)sender {
    [self _toggleSystemControlToolbarView];    if (self.dashboardData.controlMode != 4) {
        self.dashboardData.controlMode = 4;
        [self uploadModelToServer];
    }
}

- (IBAction)changeControlModeToOffAction:(id)sender {
    [self _toggleSystemControlToolbarView];    if (self.dashboardData.controlMode != 5) {
        self.dashboardData.controlMode = 5;
        [self uploadModelToServer];  
    }
}

- (IBAction)changeFanControlToAuto:(id)sender {
    [self _toggleFanControlToolbarView];
    if (self.dashboardData.fan_control != 0) {
        self.dashboardData.fan_control = 0;
        [self uploadModelToServer];  
    }
}

- (IBAction)changeFanControlToOn:(id)sender {
    [self _toggleFanControlToolbarView];
    if (self.dashboardData.fan_control != 1) {
        self.dashboardData.fan_control = 1;
        [self uploadModelToServer]; 
    }
}

- (IBAction)hideSystemControlToolbarView:(id)sender {
    [self _toggleSystemControlToolbarView];
}

- (IBAction)hideFanControlToolbarView:(id)sender {
    [self _toggleFanControlToolbarView];
}

- (IBAction)holdAction:(id)sender {
    // hold不按下，setpoint picker 控件如果动了视作Temporary hold， 如果按下Hold，其它几个控件进行的修改都视作Permanent Hold。
    NSLog(@" self.dashboardData.isOvrried = %i",self.dashboardData.isOvrried);
    
    //上面这一点在将来修改成：如果用户在没有修改setpoint的情况下直接按下hold按钮，就设置这个值为1表示permanent hold，发送到服务器。
    if(self.dashboardData.isOvrried == 0 || (self.dashboardData.isOvrried == 2 && _isSetpointChanged)) {
        self.dashboardData.isOvrried = 1;
    } else if(self.dashboardData.isOvrried == 1|| (self.dashboardData.isOvrried == 2 && !_isSetpointChanged)){
        self.dashboardData.isOvrried = 0;
    }
    if ([loadTimer isValid]) {
        [loadTimer invalidate];
        loadTimer = nil;
    }
    loadTimer = [NSTimer scheduledTimerWithTimeInterval:LOAD_DELAY
                                                   target:self 
                                                 selector:@selector(uploadModelToServer) 
                                                 userInfo:nil 
                                                  repeats:NO]; 
}
- (void)refreshAction
{
    [self downloadModelFromServer];
}

#pragma mark -
#pragma mark UIGestureRecognizerDelegate methods
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if (gestureRecognizer == self.systemControlToolbarViewTapRecognizer) {
        // Disallow recognition of tap gestures in the segmented control.
        if ((touch.view == self.systemControlHeatingButton) ||
            (touch.view == self.systemControlCoolingButton) ||
            (touch.view == self.systemControlAutoButton) ||
            (touch.view == self.systemControlEmgHeatingButton) ||
            (touch.view == self.systemControlOffButton) ) {//change it to your condition
            return NO;
        }
    }
    if (gestureRecognizer == self.fanControlToolbarViewTapRecognizer) {
        if ((touch.view == self.fanControlAutoButton) ||
            (touch.view == self.fanControlOnButton) ) {//change it to your condition
            return NO;
        }
    }
    return YES;
}
@end
