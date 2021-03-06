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
#import "MyEUtil.h"
#import "SBJson.h"

#import "KxMenu.h"
#import "UIColor+FlatUI.h"

#import "MyETerminalData.h"
#import "MyEHouseData.h"
#import "SWRevealViewController.h"
#import "KxMenu.h"


#import "CDCircleOverlayView.h"

// 定义圆环view外接矩形的左上角远点左边
#define CIRCLE_ORIGIN_X 40
#define CIRCLE_ORIGIN_Y 65
#define CIRCLE_DIAMETER 240

@interface MyEDashboardViewController ()
- (void)configureView;
- (void)_showFanControlToolbarView;
- (void)_showSystemControlToolbarView;

// 判定是否服务器相应正常，如果正常返回YES，如果服务器相应为-999/-998，
// 那么函数迫使Navigation View Controller跳转到Houselist view，并返回NO。
// 如果要中断外层函数执行，必须捕捉此函数返回的NO值，并中断外层函数。
- (BOOL)_processHttpRespondForString:(NSString *)respondText;
- (void)_holdRunButtionAction;
- (void)_redrawHoldRunButton;


#pragma mark 触摸圆环使用的变量
@property (nonatomic, assign) NSInteger totalDegree; // 触摸开始的度数设置为零, 此变量记录了一个触摸周期中累计触摸旋转的度数
@property (nonatomic, assign) NSInteger minVal;
@property (nonatomic, assign) NSInteger maxVal;
@property (nonatomic, assign) NSInteger currentVal;// 用于在某次触摸过程中,  记录最新的值.
@property (nonatomic, retain) CDCircle *circle;

@property (nonatomic, weak) UIButton *holdRunButton;
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
    
    BOOL isRC = (MainDelegate.terminalData.remote == 0? NO:YES);
    self.userId = MainDelegate.accountData.userId;
    self.houseId = MainDelegate.houseData.houseId;
    self.houseName = MainDelegate.houseData.houseName;
    self.tId = MainDelegate.terminalData.tId;
    self.tName = MainDelegate.terminalData.tName;
   
    [self.view bringSubviewToFront:self.fanControlToolbarOverlayView];
    [self.view bringSubviewToFront:self.systemControlToolbarOverlayView];
    
    
    
    [self.controlModeBtn setStyleType:ACPButtonOK];
    [self.controlModeBtn setStyle:[UIColor clearColor] andBottomColor:[UIColor clearColor]];
    [self.fanStatusBtn setStyleType:ACPButtonOK];
    [self.fanStatusBtn setStyle:[UIColor clearColor] andBottomColor:[UIColor clearColor]];
    
    
    
    // 设置面板背景为一个图片模式
//    UIColor *bgcolor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bgpattern.png"]];
    // 设置面板背景为一个纯色
    UIColor *bgcolor = [UIColor colorWithWhite:248.0/255.0 alpha:1.0];
    [self.view setBackgroundColor:bgcolor];
    
   
    _isSetpointChanged = NO;
    
    [self.systemControlEmgHeatingButton setBackgroundImage:[UIImage imageNamed:@"Tb_EmgHDisabled.png"] forState:UIControlStateDisabled];
    [self.systemControlEmgHeatingButton setBackgroundImage:[UIImage imageNamed:@"Tb_EmgH01.png"] forState:UIControlStateNormal];

    
    // 下面是触摸圆环Circle
    _minVal = 55;
    _maxVal = 90;
    self.selectedSegment = 80;
    
    self.circle = [[CDCircle alloc] initWithFrame:CGRectMake(CIRCLE_ORIGIN_X , CIRCLE_ORIGIN_Y, CIRCLE_DIAMETER, CIRCLE_DIAMETER) numberOfSegments:(360 / STEP_DEGREE) ringWidth:40.f];
    self.circle.dataSource = self;
    self.circle.delegate = self;
    CDCircleOverlayView *overlay = [[CDCircleOverlayView alloc] initWithCircle:self.circle];
    
    // 根据Circle位置,重新定义hold 标签的位置
    CGRect frame = CGRectMake(CIRCLE_ORIGIN_X + (self.circle.ringWidth + 20.0),
                               CIRCLE_ORIGIN_Y + (self.circle.ringWidth + 45.0),
                               self.holdRunLabel.frame.size.width,self.holdRunLabel.frame.size.height);
    self.holdRunLabel.frame = frame;
    
    UIColor *arcColor = [UIColor colorWithRed:75.0/255.0 green:220.0/255.0 blue:250.0/255.0 alpha:1.0];
    for (CDCircleThumb *thumb in self.circle.thumbs) {
        [thumb.iconView setHighlitedIconColor:[UIColor whiteColor]];
        thumb.separatorColor = arcColor;// 使分割线和扇形块颜色一样， 就可以形成一个完全纯色的圆环， 看不到扇形块
        thumb.separatorStyle = CDCircleThumbsSeparatorBasic;// CDCircleThumbsSeparatorNone 会显示一个默认的灰色的分割线。
        thumb.gradientFill = NO;
        thumb.arcColor = arcColor;
//        thumb.gradientColors = [NSArray arrayWithObjects:(id) [UIColor blackColor].CGColor, (id) [UIColor yellowColor].CGColor, (id) [UIColor blueColor].CGColor, nil];
//        thumb.colorsLocations = [NSMutableArray arrayWithObjects:[NSNumber numberWithFloat:0.00f], [NSNumber numberWithFloat:0.30f], [NSNumber numberWithFloat:1.00f], nil];
        
    }
    
    [self.view addSubview:self.circle];
    [self.view addSubview:overlay];
    
    // make sure setIsRemoteControl is executed after initialize the self.circle widget, in case that remoteControl is disabled, we need to add a Over layer
    self.isRemoteControl = isRC;
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.parentViewController.navigationItem.rightBarButtonItems = nil;
    
    UIBarButtonItem *refreshButton = [[UIBarButtonItem alloc]
                                  initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh 
                                  target:self 
                                  action:@selector(refreshAction)];
    self.parentViewController.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:refreshButton, nil];
    
    [self downloadModelFromServer];
    
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
        HUD.opacity = 0.2f;
        HUD.delegate = self;
    } else
        [HUD show:YES];
    NSString *urlStr = [NSString stringWithFormat:@"%@?userId=%@&houseId=%i&tId=%@",GetRequst(URL_FOR_DASHBOARD_VIEW), MainDelegate.accountData.userId, MainDelegate.houseData.houseId, MainDelegate.terminalData.tId];
    MyEDataLoader *downloader = [[MyEDataLoader alloc] initLoadingWithURLString:urlStr postData:nil delegate:self loaderName:@"DashboardDownloader"  userDataDictionary:nil];
    NSLog(@"DashboardDownloader is %@, url is %@",downloader.name, urlStr);
}

// 准备3秒后请求刷新新数据， 连续刷新3次
- (void)downloadModelFromServerLater{
    [NSTimer scheduledTimerWithTimeInterval:1.0f
                                     target:self
                                   selector:@selector(downloadModelFromServer)
                                   userInfo:nil
                                    repeats:NO];
    [NSTimer scheduledTimerWithTimeInterval:2.5f
                                     target:self
                                   selector:@selector(downloadModelFromServer)
                                   userInfo:nil
                                    repeats:NO];
    [NSTimer scheduledTimerWithTimeInterval:4.0f
                                     target:self
                                   selector:@selector(downloadModelFromServer)
                                   userInfo:nil
                                    repeats:NO];
}
- (void)uploadModelToServer {
    if(HUD == nil) {
        HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        HUD.opacity = 0.2f;
        HUD.delegate = self;
    } else
        [HUD show:YES];
    NSString *body = [NSString stringWithFormat:@"datamodel=%@", [[self.dashboardData JSONDictionary] JSONRepresentation]];
    NSLog(@"upload dashboar body is \n%@",body);
    
    NSString *urlStr = [NSString stringWithFormat:@"%@?userId=%@&houseId=%i&tId=%@",GetRequst(URL_FOR_DASHBOARD_SAVE), MainDelegate.accountData.userId, MainDelegate.houseData.houseId, MainDelegate.terminalData.tId];
    MyEDataLoader *loader = [[MyEDataLoader alloc] initLoadingWithURLString:urlStr postData:body delegate:self loaderName:@"DashboardUploader" userDataDictionary:nil];
    NSLog(@"DashboardUploader is %@",[loader description]);
    [loadTimer invalidate];
    loadTimer = nil;
}
- (void) didReceiveString:(NSString *)string loaderName:(NSString *)name userDataDictionary:(NSDictionary *)dict{
    [HUD hide:YES];
    if([name isEqualToString:@"DashboardDownloader"]) {
        NSLog(@"DashboardDownloader string from server is \n %@", string);
        MyEDashboardData *dashboardData = [[MyEDashboardData alloc] initWithJSONString:string];
        if (dashboardData) {
            [self setDashboardData:dashboardData]; 
            _isSetpointChanged = NO;
        } else {
            UIAlertView *alert =[[UIAlertView alloc]initWithTitle:@"Error" 
                                                          message:@"Communication error! Please try again."
                                                         delegate:nil
                                                cancelButtonTitle:@"Ok"
                                                otherButtonTitles:nil];
            [alert show];
        }
    }
    if([name isEqualToString:@"DashboardUploader"]) {
        NSLog(@"DashboardUploader upload with result: %@", string);
        
        // 判定是否服务器相应正常，如果服务器相应为-999/-998，那么_processHttpRespondForString函数会设置isRemoteControl 变量。
        // 如果要中断本层函数执行，必须捕捉_processHttpRespondForString函数返回的NO值，并中断本层函数。
        if (![self _processHttpRespondForString:string])
            return;
        
        // 加6秒延迟后再从服务器下载新数据，否则太快下载，Thermostat好像还没真正改变过来，传来的"realControlMode"字段还是上一个状态
        loadTimer = [NSTimer scheduledTimerWithTimeInterval:2.0f
                                                     target:self 
                                                   selector:@selector(downloadModelFromServerLater)
                                                   userInfo:nil 
                                                    repeats:NO]; 

    }
    // 在从服务器获得数据后，如果哪个子面板还在显示，就隐藏它
    self.systemControlToolbarOverlayView.hidden = YES;
    self.fanControlToolbarOverlayView.hidden = YES;
}
- (void) connection:(NSURLConnection *)connection didFailWithError:(NSError *)error loaderName:(NSString *)name{
    UIAlertView *alert =[[UIAlertView alloc]initWithTitle:@"Error" 
                                                  message:@"Communication error. Please try again."
                                                 delegate:nil
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
    self.holdRunButton.enabled = isRemoteControl;
    
    self.controlModeImageView.alpha = isRemoteControl ? 1.0 : 0.77;
    self.fanImageView.alpha = isRemoteControl ? 1.0 : 0.77;
    if(!isRemoteControl) {
        // Create the layer if necessary.
        if(!_maskLayer) {
            _maskLayer = [[UIView alloc] initWithFrame:self.view.bounds];
            
            _singleFingerTap =
            [[UITapGestureRecognizer alloc] initWithTarget:self
                                                    action:@selector(handleSingleTap:)];
            [_maskLayer addGestureRecognizer:_singleFingerTap];
        }
        
        [self.view addSubview:_maskLayer];
        
        [self.view bringSubviewToFront:_maskLayer];

        [MyEUtil showMessageOn:self.view withMessage:@"The remote controls from internet has been disabled."];
    } else {
        if(_maskLayer)
            [_maskLayer removeFromSuperview];
        
//        [MyEUtil showMessageOn:self.view withMessage:@"The remote control of thermostat is enabled."];
        if(_singleFingerTap)
            [_maskLayer removeGestureRecognizer:_singleFingerTap];
    }
}

#pragma mark
#pragma mark private methods
//The event handling method
- (void)handleSingleTap:(UITapGestureRecognizer *)recognizer {
//    CGPoint location = [recognizer locationInView:[recognizer.view superview]];
    
    //Do stuff here...
    [MyEUtil showMessageOn:self.view withMessage:@"The remote controls from internet has been disabled."];
    
}
- (void)configureView
{
    // Update the user interface for the detail item.
    MyEDashboardData *theDashboardData = self.dashboardData;


    self.indoorTemperatureLabel.text = [NSString stringWithFormat:@"%.0f\u00B0F", theDashboardData.temperature];
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
        
        /*// 下面是风扇图片显示的逻辑
         If (fan_control == 0)//auto
         {
         if(fan_status == “On”)
         使用左上角带Auto文字的风扇转动的图片
         if(fan_status == “Off”)
         使用左上角带Auto文字的风扇静止的图片
         } else (fan_control == 1)//on，此时不管 fan_status，其实它一定是on
         {
         使用左上角带On文字的风扇转动的图片
         }
         */
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
            }
            self.fanStatusLabel.text = @"Auto";
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
        //	System mode为OFF时，圆环中间的按钮不能再接受点击事件，同时，圆形按钮上的文字更改为OFF（不再显示setpoint）
        if (theDashboardData.controlMode ==5)
        {
            self.circle.userInteractionEnabled = NO;
            self.holdRunLabel.hidden = YES;
        }
        else {
            self.circle.userInteractionEnabled = YES;
            self.holdRunLabel.hidden = NO;
        }
        
        //hold(isOvrried)分别对应0(Run), 1(Permanent Hold), 2(Temporary Hold)。
        if(theDashboardData.isOvrried == 0)
        {
            self.holdRunLabel.text = @"Press to Hold";
        }
        else
        {
            self.holdRunLabel.text = @"Press to Run";
        }
        [self _redrawHoldRunButton];
        
        // 这里不需要在每次下载新数据时判定是否Remote NO，否则会产生一种情况：操作中变为Remote No的时候没有提示文字并返回House List，而是直接 disable掉控制面板了. 2012-05-29
        //[self setRemoteControlEnabled:[theDashboardData.locWeb caseInsensitiveCompare:@"enabled"] == NSOrderedSame];

        //刷新远程控制的状态。需要确保这句在最后一次执行， 以保证Overlayer可以覆盖在holdrunbutton之上
        self.isRemoteControl = [theDashboardData.locWeb caseInsensitiveCompare:@"enabled"] == NSOrderedSame;
    }
}

- (void)_showSystemControlToolbarView{

//    con_hp	控制紧急加热, 取值范围: 0或1,从服务器传来的只读属性,如果是1.可以控制紧急加热图标, 0.不可控制,
//    现在修改成取0时不显示该按钮， 取1时显示该按钮
    if (self.dashboardData.con_hp == 1) {
//        self.systemControlEmgHeatingButton.enabled = YES;
        self.systemControlEmgHeatingButton.hidden = NO;
        CGFloat x = 30;
        CGFloat y = self.systemControlHeatingButton.frame.origin.y;
        CGFloat w = self.systemControlHeatingButton.frame.size.width;
        CGFloat h = self.systemControlHeatingButton.frame.size.height;

        self.systemControlHeatingButton.frame = CGRectMake(x, y, w, h);
        self.systemControlCoolingButton.frame = CGRectMake(x + 55, y, w, h);
        self.systemControlAutoButton.frame = CGRectMake(x + 55 * 2, y, w, h);
        self.systemControlEmgHeatingButton.frame = CGRectMake(x + 55 * 3, y, w, h);
        self.systemControlOffButton.frame = CGRectMake(x + 55 * 4, y, w, h);
    } else {
        [self.view bringSubviewToFront:self.systemControlToolbarOverlayView];
//        self.systemControlEmgHeatingButton.enabled = NO;
        self.systemControlEmgHeatingButton.hidden = YES;
        CGFloat x = 57.5;
        CGFloat y = self.systemControlHeatingButton.frame.origin.y;
        CGFloat w = self.systemControlHeatingButton.frame.size.width;
        CGFloat h = self.systemControlHeatingButton.frame.size.height;
        
        self.systemControlHeatingButton.frame = CGRectMake(x, y, w, h);
        self.systemControlCoolingButton.frame = CGRectMake(x + 55, y, w, h);
        self.systemControlAutoButton.frame = CGRectMake(x + 55 * 2, y, w, h);
        self.systemControlOffButton.frame = CGRectMake(x + 55 * 3, y, w, h);
    }
    

    self.systemControlToolbarOverlayView.hidden = NO;

    [self.view bringSubviewToFront:self.systemControlToolbarOverlayView];

}
- (void)_showFanControlToolbarView{
    [self.view bringSubviewToFront:self.fanControlToolbarOverlayView];
    self.fanControlToolbarOverlayView.hidden = NO;

    [self.view bringSubviewToFront:self.fanControlToolbarOverlayView];

}

// 判定是否服务器相应正常，如果正常返回一些字符串，如果服务器相应为-999/-998，
// 那么函数迫使Navigation View Controller跳转到Houselist view，并返回NO。
// 如果要中断外层函数执行，必须捕捉此函数返回的NO值，并中断外层函数。
- (BOOL)_processHttpRespondForString:(NSString *)respondText {
    NSInteger respondInt = [respondText intValue];// 从字符串开始寻找整数，如果碰到字母就结束，如果字符串不能转换成整数，那么此转换结果就是0
    if (respondInt == -998) {
        self.isRemoteControl = NO;
        return NO;
    } 
    return YES;

}
- (void)_holdRunButtionAction
{
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

// 0: 不显示是否节能blue  1:不节能(显示红色)red  2:节能(显示绿色叶子)green
-(void)_redrawHoldRunButton
{
    NSInteger type= self.dashboardData.energyLeaver;
    HoldType hold = (HoldType)self.dashboardData.isOvrried;
    NSInteger controlMode = self.dashboardData.controlMode;
    
    if (self.holdRunButton) {
        [self.holdRunButton removeFromSuperview];
        self.holdRunButton = Nil;
    }
    CGFloat margin = 15.0f;// 此中心HoldRunButton外圆到触摸圆环内环直接的空余距离
    CGFloat diameter = CIRCLE_DIAMETER - (self.circle.ringWidth + margin) * 2.0;
    CGRect bounds = CGRectMake(CIRCLE_ORIGIN_X + (self.circle.ringWidth + margin),
                               CIRCLE_ORIGIN_Y + (self.circle.ringWidth + margin),
                               diameter,diameter);
//    NSLog(@"x=%f, y=%f, w=%f, h=%f", self.circle.bounds.origin.x, self.circle.bounds.origin.y, bounds.size.width, bounds.size.height);
    self.holdRunButton = [UIButton buttonWithType:UIButtonTypeCustom];
    //    [self.holdRunButton setImage:[UIImage imageNamed:@"Micky.png"] forState:UIControlStateNormal];
    [self.holdRunButton addTarget:self action:@selector(_holdRunButtionAction) forControlEvents:UIControlEventTouchUpInside];
    //	System mode为OFF时，圆环中间的按钮不能再接受点击事件，同时，圆形按钮上的文字更改为OFF（不再显示setpoint）
    if (controlMode ==5)
    {
        self.holdRunButton.userInteractionEnabled = NO;
        self.holdRunButton.enabled = NO;
        [self.holdRunButton setTitle:@"Off" forState:UIControlStateNormal];
        [self.holdRunButton setTitle:@"Off" forState:UIControlStateDisabled];
        [self.holdRunButton setTitle:@"Off" forState:UIControlStateHighlighted];
        
    }
    else {
        [self.holdRunButton setTitle:[NSString stringWithFormat:@"%i\u00B0F", self.selectedSegment] forState:UIControlStateNormal];
        [self.holdRunButton setTitle:[NSString stringWithFormat:@"%i\u00B0F", self.selectedSegment] forState:UIControlStateDisabled];
        [self.holdRunButton setTitle:[NSString stringWithFormat:@"%i\u00B0F", self.selectedSegment] forState:UIControlStateHighlighted];
        self.holdRunButton.enabled = YES;
        self.holdRunButton.userInteractionEnabled = YES;
    }

    self.holdRunButton.frame = bounds;//    CGRectMake(100.0, 160.0, 120.0, 120.0);
    self.holdRunButton.clipsToBounds = YES;
    [self.holdRunButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.holdRunButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
    [self.holdRunButton.titleLabel setFont:[UIFont boldSystemFontOfSize:30]];
    
    self.holdRunButton.layer.cornerRadius = 60;//half of the width
//    self.holdRunButton.layer.borderColor=[UIColor redColor].CGColor;
//    self.holdRunButton.layer.borderWidth=2.0f;
    //    self.holdRunButton.layer.backgroundColor=[UIColor greenColor].CGColor; // 此句会遮住或阻止阴影, 所以注释
    if (hold ==HOLD_TYPE_PERMANENT || hold == HOLD_TYPE_TEMPORARY) {
        if (type == 1){
            self.holdRunButton.layer.shadowColor = [UIColor colorWithRed:60.0/255.0 green:30.0/255.0 blue:15.0/255.0 alpha:0.75].CGColor;
        } else if(type == 2){
            self.holdRunButton.layer.shadowColor = [UIColor colorWithRed:20.0/255.0 green:25.0/255.0 blue:5.0/255.0 alpha:0.75].CGColor;
        }else
            self.holdRunButton.layer.shadowColor = [UIColor colorWithRed:10.0/255.0 green:40.0/255.0 blue:45.0/255.0 alpha:0.75].CGColor;
        self.holdRunButton.layer.shadowOffset = CGSizeZero;//CGSizeMake(2.0f, 2.0f);
        self.holdRunButton.layer.shadowRadius = 5.0f;
        self.holdRunButton.layer.shadowOpacity = 0.75f;
        self.holdRunButton.layer.masksToBounds = NO;
        self.holdRunButton.layer.shadowPath = [UIBezierPath bezierPathWithArcCenter:CGPointMake(self.holdRunButton.bounds.origin.x + self.holdRunButton.bounds.size.width/2.0, self.holdRunButton.bounds.origin.y + self.holdRunButton.bounds.size.height/2.0) radius:self.holdRunButton.bounds.size.height/2.0f startAngle:0 endAngle:2*M_PI clockwise:YES].CGPath;
        
        if (hold == HOLD_TYPE_TEMPORARY){
            CABasicAnimation *theAnimation;
            theAnimation=[CABasicAnimation animationWithKeyPath:@"shadowOpacity"];
            theAnimation.duration=0.5;
            theAnimation.repeatCount=HUGE_VALF;
            theAnimation.autoreverses=YES;
            theAnimation.fromValue=[NSNumber numberWithFloat:1.0];
            theAnimation.toValue=[NSNumber numberWithFloat:0.2];
            [self.holdRunButton.layer addAnimation:theAnimation forKey:@"animateOpacity"]; // here key is defined by developer
        }
    }
    
    //@see http://stackoverflow.com/questions/10133109/fastest-way-to-do-shadows-on-ios
    self.holdRunButton.layer.shouldRasterize = YES;
    // Don't forget the rasterization scale
    // I spent days trying to figure out why retina display assets weren't working as expected
    self.holdRunButton.layer.rasterizationScale = [UIScreen mainScreen].scale;
    
    
    // 用一个image做Highlighted背景
    UIGraphicsBeginImageContext(self.holdRunButton.bounds.size);
    if (type == 1) {
        [[UIColor colorWithRed:230.0/255.0 green:125.0/255.0 blue:30.0/255.0 alpha:.50] setFill];
    }else if( type == 2) {
        [[UIColor colorWithRed:130.0/255.0 green:190.0/256 blue:60.0/255.0 alpha:0.5] setFill];
    }else if( type == 0) {
        [[UIColor colorWithRed:75.0/255.0 green:190.0/255.0 blue:215.0/255.0 alpha:0.5] setFill];
    }
    UIBezierPath* bPath = [UIBezierPath bezierPathWithArcCenter:CGPointMake(self.holdRunButton.bounds.origin.x + self.holdRunButton.bounds.size.width/2.0, self.holdRunButton.bounds.origin.y + self.holdRunButton.bounds.size.height/2.0) radius:self.holdRunButton.bounds.size.height/2.0f -5 startAngle:0 endAngle:2*M_PI clockwise:YES];
    [bPath fill];
    UIImage *colorImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    [self.holdRunButton setBackgroundImage:colorImage forState:UIControlStateHighlighted];
    
    // 用一个image做Normal背景
    UIGraphicsBeginImageContext(self.holdRunButton.bounds.size);
    if (type == 1) {
        [[UIColor colorWithRed:230.0/255.0 green:125.0/255.0 blue:30.0/255.0 alpha:1.0] setFill];
    }else if( type == 2) {
        [[UIColor colorWithRed:130.0/255.0 green:190.0/256 blue:60.0/255.0 alpha:1.0] setFill];
    }else if( type == 0) {
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
    if ([loadTimer isValid]) {
        [loadTimer invalidate];
        loadTimer = nil;
    }
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
    
//    NSLog(@"move代理 累计度数 %d, 累计步: %d, 原来块=%d, newValue=%d", _totalDegree, steps, self.selectedSegment, newValue);
    if (newValue > _maxVal) {
        newValue = _maxVal;
        [MyEUtil showErrorOn:self.view withMessage:@"Reached the Maximum Setpoint"];
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
        AudioServicesPlaySystemSound(1057);
    }
    if (newValue < _minVal) {
        newValue = _minVal;
        [MyEUtil showErrorOn:self.view withMessage:@"Reached the Minimum Setpoint"];
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
        AudioServicesPlaySystemSound(1057);
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
    [self.holdRunButton setTitle:[NSString stringWithFormat:@"%i\u00B0F", newValue] forState:UIControlStateDisabled];
    [self.holdRunButton setTitle:[NSString stringWithFormat:@"%i\u00B0F", newValue] forState:UIControlStateHighlighted];
}
-(UIImage *) circle:(CDCircle *)circle iconForThumbAtRow:(NSInteger)row {
//    NSString *fileString = [[[NSBundle mainBundle] pathsForResourcesOfType:@"png" inDirectory:nil] lastObject];
//    return [UIImage imageWithContentsOfFile:fileString];

//    return [UIImage imageNamed:@"icon_arrow_up.png"];
    return Nil;
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
    [self _showSystemControlToolbarView];
}
- (IBAction)changeFanControl:(id)sender {
    [self _showFanControlToolbarView];
}

- (IBAction)changeControlModeToHeatingAction:(id)sender {
    self.systemControlToolbarOverlayView.hidden = YES;
    if (self.dashboardData.controlMode != 1) {
        self.dashboardData.controlMode = 1;
        [self uploadModelToServer];
    } 
}

- (IBAction)changeControlModeToCoolingAction:(id)sender {
   self.systemControlToolbarOverlayView.hidden = YES;
    if (self.dashboardData.controlMode != 2) {
        self.dashboardData.controlMode = 2;
        [self uploadModelToServer];
    }
}

- (IBAction)changeControlModeToAutoAction:(id)sender {
    self.systemControlToolbarOverlayView.hidden = YES;
    if (self.dashboardData.controlMode != 3) {
        self.dashboardData.controlMode = 3;
        [self uploadModelToServer];
    }
}

- (IBAction)changeControlModeToEmgHeatingAction:(id)sender {
    self.systemControlToolbarOverlayView.hidden = YES;
    if (self.dashboardData.controlMode != 4) {
        self.dashboardData.controlMode = 4;
        [self uploadModelToServer];
    }
}

- (IBAction)changeControlModeToOffAction:(id)sender {
    self.systemControlToolbarOverlayView.hidden = YES;
    if (self.dashboardData.controlMode != 5) {
        self.dashboardData.controlMode = 5;
        [self uploadModelToServer];  
    }
}

- (IBAction)changeFanControlToAuto:(id)sender {
    self.fanControlToolbarOverlayView.hidden = YES;
    if (self.dashboardData.fan_control != 0) {
        self.dashboardData.fan_control = 0;
        [self uploadModelToServer];  
    }
}

- (IBAction)changeFanControlToOn:(id)sender {
    self.fanControlToolbarOverlayView.hidden = YES;
    if (self.dashboardData.fan_control != 1) {
        self.dashboardData.fan_control = 1;
        [self uploadModelToServer]; 
    }
}

- (IBAction)hideSystemControlToolbarView:(id)sender {
    self.systemControlToolbarOverlayView.hidden = YES;
}

- (IBAction)hideFanControlToolbarView:(id)sender {
    self.fanControlToolbarOverlayView.hidden = YES;
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
