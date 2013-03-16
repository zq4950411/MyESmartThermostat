//
//  MyEDashboardViewController.m
//  MyE
//
//  Created by Ye Yuan on 1/19/12.
//  Copyright (c) 2012 MyEnergy Domain. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "MyEDashboardViewController.h"
#import "MyELoginViewController.h"
#import "MyEDashboardData.h"
#import "MyEHouseListViewController.h"
#import "MyEAccountData.h"
#import "MyETipViewController.h"
#import "MyETipDataModel.h"
#import "MyEUtil.h"
#import "SBJson.h"


@interface MyEDashboardViewController ()
- (void)configureView;
- (void)_toggleFanControlToolbarView;
- (void)_toggleSystemControlToolbarView;

// 判定是否服务器相应正常，如果正常返回YES，如果服务器相应为-999/-998，
// 那么函数迫使Navigation View Controller跳转到Houselist view，并返回NO。
// 如果要中断外层函数执行，必须捕捉此函数返回的NO值，并中断外层函数。
- (BOOL)_processHttpRespondForString:(NSString *)respondText;
@end

@implementation MyEDashboardViewController
//下面两个变量用于在 UIPickerView 中对选定行进行加亮颜色
@synthesize oldLabelView = _oldLabelView, selectedLabelView = _selectedLabelView;

@synthesize weatherImageView = _weatherImageView;
@synthesize weatherTemperatureLabel = _weatherTemperatureLabel;
@synthesize weatherTemperatureRangeLabel = _weatherTemperatureRangeLabel;
@synthesize humidityLabel = _humidityLabel;
@synthesize indoorTemperatureLabel = _indoorTemperatureLabel;
@synthesize controlModeImageView = _controlModeImageView;
@synthesize fanImageView = _fanImageView;
@synthesize activeProgramLabel = _activeProgramLabel;
@synthesize stageLevelLabel = _stageLevelLabel;
@synthesize systemControlToolbarView = _systemControlToolbarView;
@synthesize fanControlToolbarView = _fanControlToolbarView;
@synthesize setpointPickerView = _setpointPickerView;
@synthesize holdButton = _holdButton;
@synthesize systemControlToolbarViewTapRecognizer = _systemControlToolbarViewTapRecognizer;
@synthesize systemControlHeatingButton = _systemControlHeatingButton;
@synthesize systemControlCoolingButton = _systemControlCoolingButton;
@synthesize systemControlAutoButton = _systemControlAutoButton;
@synthesize systemControlEmgHeatingButton = _systemControlEmgHeatingButton;
@synthesize systemControlOffButton = _systemControlOffButton;
@synthesize fanControlToolbarViewTapRecognizer = _fanControlToolbarViewTapRecognizer;
@synthesize fanControlAutoButton = _fanControlAutoButton;
@synthesize fanControlOnButton = _fanControlOnButton;

@synthesize userId = _userId;
@synthesize houseId = _houseId;
@synthesize houseName = _houseName;
@synthesize tId = _tId;
@synthesize isRemoteControl = _isRemoteControl;





@synthesize dashboardData = _dashboardData;

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
    //这里设置了就可以自定义高度了，一般默认是无法修改其216像素的高度
    //There are 3 valid heights for UIDatePicker (and UIPickerView) 162.0, 180.0, and 216.0. 
    //If you set a UIPickerView height to anything else you will see the following in the console when debugging on an iOS device.
    // -[UIPickerView setFrame:]: invalid height value ... pinned to 162.0 
    self.setpointPickerView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;     self.setpointPickerView.frame = CGRectMake(170, 110, 120, 162);
    
    // 设置面板背景为一个图片模式
    UIColor *bgcolor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bgpattern.png"]];
    [self.view setBackgroundColor:bgcolor];
    
    // 下面使用9宫格可缩放图片作为按钮背景
    UIImage *buttonBackImage = [UIImage imageNamed:@"buttonbg.png" ];
    buttonBackImage = [buttonBackImage stretchableImageWithLeftCapWidth:10 topCapHeight:10];
    [self.holdButton setBackgroundImage:buttonBackImage forState:UIControlStateNormal];
    UIImage *buttonDisabledBackImage = [UIImage imageNamed:@"buttonbgdisabled.png" ];
    buttonDisabledBackImage = [buttonDisabledBackImage stretchableImageWithLeftCapWidth:10 topCapHeight:10];
    [self.holdButton setBackgroundImage:buttonDisabledBackImage forState:UIControlStateDisabled];
    [self.holdButton setTitleColor:[UIColor colorWithWhite:0.77 alpha:1.0] forState:UIControlStateDisabled];
    
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
}

- (void)viewDidUnload
{
    [self setWeatherImageView:nil];
    [self setActiveProgramLabel:nil];
    [self setWeatherTemperatureLabel:nil];
    [self setWeatherTemperatureRangeLabel:nil];
    [self setIndoorTemperatureLabel:nil];
    [self setStageLevelLabel:nil];
    [self setControlModeImageView:nil];
    [self setFanImageView:nil];
    [self setSystemControlToolbarView:nil];

    
    [self setFanImageView:nil];
    [self setSetpointPickerView:nil];
    
    [self setSelectedLabelView:nil];
    [self setOldLabelView:nil];
    
        
    [self setHoldButton:nil];
    [self setHumidityLabel:nil];
    [self setSystemControlToolbarView:nil];
    [self setFanControlToolbarView:nil];
    [self setSystemControlToolbarViewTapRecognizer:nil];
    [self setFanControlToolbarViewTapRecognizer:nil];
    [self setSystemControlHeatingButton:nil];
    [self setSystemControlCoolingButton:nil];
    [self setSystemControlAutoButton:nil];
    [self setSystemControlEmgHeatingButton:nil];
    [self setSystemControlOffButton:nil];
    [self setFanControlAutoButton:nil];
    [self setFanControlOnButton:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.parentViewController.navigationItem.rightBarButtonItems = nil;
    UIBarButtonItem *refreshButton = [[UIBarButtonItem alloc] 
                                  initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh 
                                  target:self 
                                  action:@selector(refreshAction)];
    self.parentViewController.navigationItem.rightBarButtonItem = refreshButton;
    
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
    NSString *urlStr = [NSString stringWithFormat:@"%@?userId=%@&houseId=%i&tId=%@",URL_FOR_DASHBOARD_VIEW, self.userId, self.houseId, self.tId];
    MyEDataLoader *downloader = [[MyEDataLoader alloc] initLoadingWithURLString:urlStr postData:nil delegate:self loaderName:@"DashboardDownloader"  userDataDictionary:nil];
    NSLog(@"DashboardDownloader is %@, url is %@",downloader.name, urlStr);
}
- (void)uploadModelToServer {
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
    NSString *body = [NSString stringWithFormat:@"datamodel=%@", [[self.dashboardData JSONDictionary] JSONRepresentation]];
    NSLog(@"upload dashboar body is \n%@",body);
    
    NSString *urlStr = [NSString stringWithFormat:@"%@?userId=%@&houseId=%i&tId=%@",URL_FOR_DASHBOARD_SAVE, self.userId, self.houseId, self.tId];
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
#pragma mark Picker Data Source Methodes 数据源方法

//选取器如果有多个滚轮，就返回滚轮的数量，我们这里有两个，就返回2
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
	return 1;
}
//返回给定的组件有多少行数据
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if(self.dashboardData.controlMode == 5)//如果控制模式是off，就不允许使用这个picker，picker也只显示一个off
        return 1;
    else
        return 36;
}

#pragma mark -
#pragma mark Picker Delegate Methods 委托方法

//官方的意思是，指定组件中的指定数据，就是每一行所对应的显示字符是什么。
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
	if (self.dashboardData.controlMode == 5) {//如果控制模式是off，就不允许使用这个picker，picker也只显示一个off
        return @"    Off";
    }
	else 
        return [NSString stringWithFormat:@"    %i", row+55];
}

//当选取器的行发生改变的时候调用这个方法
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    if (self.dashboardData.controlMode == 5) //如果控制模式是off，就不允许使用这个picker，picker也只显示一个off
        return;

    if (self.dashboardData.setpoint != row + 55) {
        self.dashboardData.setpoint = row + 55;
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
    
    /*
    //更改在 UIPickerView 中的选定行的颜色
    if (self.oldLabelView != nil)
        self.oldLabelView.backgroundColor = [UIColor clearColor];
    
    self.selectedLabelView = (UILabel *)[self.setpointPickerView viewForRow:row forComponent:0];
    self.selectedLabelView.backgroundColor = [UIColor yellowColor];
    [self.selectedLabelView setNeedsDisplay];
    self.oldLabelView = self.selectedLabelView;
    //*/
    
}

// returns width of column and height of row for each component. 
- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component {
    return 90;
}
- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component{
    return 50;
}

/* 用于为选中的行添加加亮黄色，但问题是黄色label没能对齐，也没办法在一开始时就能显示，所以暂时注释了
- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view{
    
    UILabel *label = (UILabel*) view;
    if (label == nil)
    {
        label = [[UILabel alloc] init];
    }
    
    if (self.dashboardData.controlMode == 5) {
        [label setText:@"Off"];
    }
	else 
        [label setText:[NSString stringWithFormat:@"%i", row+55]];
    
    UIFont *myFont=[UIFont  fontWithName:@"Helvetica-Bold"  size:24];
    label.font = myFont;//用label来设置字体大小

    label.textAlignment = UITextAlignmentCenter;
    
    // This part just colorizes everything
    [label setTextColor:[UIColor blackColor]];
    [label setBackgroundColor:[UIColor clearColor]];
    [label setTextAlignment:UITextAlignmentCenter];
    
    CGSize rowSize = [pickerView rowSizeForComponent:component];
    CGRect labelRect = CGRectMake (0, 0, rowSize.width, rowSize.height);
    [label setFrame:labelRect];
    
    
        
    return label;
}
*/




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
    self.holdButton.enabled = isRemoteControl;
    self.setpointPickerView.alpha = isRemoteControl ? 1.0 : 0.77;
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
        NSString *imgFileName = [NSString stringWithFormat:@"%@.png",theDashboardData.weather];
        UIImage *image = [UIImage imageNamed: imgFileName];
        self.weatherImageView.image = image;
        
        self.weatherTemperatureLabel.text = [NSString stringWithFormat:@"%.0f", theDashboardData.weatherTemp];
        self.weatherTemperatureRangeLabel.text = [NSString stringWithFormat:@"%.0f~%.0f", theDashboardData.lowTemp, theDashboardData.highTemp];
        self.humidityLabel.text = [NSString stringWithFormat:@"Humidity %i%%",theDashboardData.humidity];
        self.indoorTemperatureLabel.text = [NSString stringWithFormat:@"%.0f", theDashboardData.temperature];
        
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
        } else {
            switch (theDashboardData.stageLevel) {
                case 0:
                    levelString = @"";
                    break;
                case 1:
                    levelString = @"stage 1";
                    break;
                case 2:
                    levelString = @"stage 1+2";
                    break;
                case 3:
                    if([theDashboardData.realControlMode caseInsensitiveCompare:@"Heating"] == NSOrderedSame)       
                        levelString = @"stage 1+2 AUX";
                    else
                        levelString = @"";
                    break;
                    
                default:
                    break;
            }
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

        }else if (theDashboardData.fan_control == 1) {//on
            self.fanImageView.animationImages = [NSArray arrayWithObjects:    
                                                 [UIImage imageNamed:@"Ctrl_FanOn-01.png"],
                                                 [UIImage imageNamed:@"Ctrl_FanOn-02.png"],
                                                 [UIImage imageNamed:@"Ctrl_FanOn-03.png"], nil];
            self.fanImageView.animationDuration = ANIMATION_DURATION;
            self.fanImageView.animationRepeatCount = 0;
            [self.fanImageView startAnimating];
        }
        
        // 如果是在关闭状态，setpoint就设置为不可访问
        [self.setpointPickerView setNeedsLayout];
        if (theDashboardData.controlMode ==5)
        {
            self.setpointPickerView.userInteractionEnabled = NO;
            self.holdButton.hidden = YES;
            self.activeProgramLabel.text = @"None";
        }
        else {
            self.setpointPickerView.userInteractionEnabled = YES;
            [self.setpointPickerView selectRow:theDashboardData.setpoint-55 inComponent:0 animated:YES];
            self.holdButton.hidden = NO;
            self.activeProgramLabel.text = theDashboardData.currentProgram;
        }

        /*
        //更改在 UIPickerView 中的选定行的颜色
        if (self.oldLabelView != nil)
            self.oldLabelView.backgroundColor = [UIColor clearColor];
        
        self.selectedLabelView = (UILabel *)[self.setpointPickerView viewForRow:(theDashboardData.setpoint-55) forComponent:0];

        self.selectedLabelView.backgroundColor = [UIColor yellowColor];
        [self.selectedLabelView setNeedsDisplay];
        self.oldLabelView = self.selectedLabelView;
        //*/
        
        if(theDashboardData.isOvrried == 0) {
            [self.holdButton setTitle:@"Hold" forState:UIControlStateNormal];
        } else {
            [self.holdButton setTitle:@"Run" forState:UIControlStateNormal];
        }
        
        
        
        // 这里不需要在每次下载新数据时判定是否Remote NO，否则会产生一种情况：操作中变为Remote No的时候没有提示文字并返回House List，而是直接 disable掉控制面板了. 2012-05-29
        //[self setRemoteControlEnabled:[theDashboardData.locWeb caseInsensitiveCompare:@"enabled"] == NSOrderedSame];

    }
}

- (void)_toggleSystemControlToolbarView
{
    if (self.dashboardData.con_hp == 1) {
        self.systemControlEmgHeatingButton.enabled = YES;
    } else {
        self.systemControlEmgHeatingButton.enabled = NO;
    }
    
    
    
    CGRect frame = [self.systemControlToolbarView frame]; 
    if (_isSystemControlToolbarViewShowing) {
        frame.origin.y += frame.size.height;
    } else {
        frame.origin.y -= frame.size.height;
    }
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.3];
    [self.systemControlToolbarView setFrame:frame];
    [UIView commitAnimations];
    
    _isSystemControlToolbarViewShowing = !_isSystemControlToolbarViewShowing;
}
- (void)_toggleFanControlToolbarView
{
    CGRect frame = [self.fanControlToolbarView frame]; 
    if (_isFanControlToolbarViewShowing) {
        frame.origin.y += frame.size.height;
    } else {
        frame.origin.y -= frame.size.height;
    }
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.3];
    [self.fanControlToolbarView setFrame:frame];
    [UIView commitAnimations];
    
    _isFanControlToolbarViewShowing = !_isFanControlToolbarViewShowing;
}

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
