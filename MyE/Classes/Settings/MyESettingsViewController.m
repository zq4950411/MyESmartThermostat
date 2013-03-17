//
//  MyESettingsViewController.m
//  MyE
//
//  Created by Ye Yuan on 3/28/12.
//  Copyright (c) 2012 MyEnergy Domain. All rights reserved.
//

#import "MyESettingsViewController.h"
#import "MyEPasswordResetViewController.h"
#import "MyEAccountData.h"
#import "MyEHouseData.h"
#import "MyEThermostatData.h"
#import "MyEHouseListViewController.h"
#import "MyESettingsThermostatCell.h"
#import "MyETipViewController.h"
#import "MyETipDataModel.h"
#import "MyEUtil.h"
#import "SBJson.h"
#import <QuartzCore/QuartzCore.h>

@interface MyESettingsViewController ()
- (void) configueView;

// 判定是否服务器相应正常，如果正常返回YES，如果服务器相应为-999/-998，
// 那么函数迫使Navigation View Controller跳转到Houselist view，并返回NO。
// 如果要中断外层函数执行，必须捕捉此函数返回的NO值，并中断外层函数。
- (BOOL)_processHttpRespondForString:(NSString *)respondText;
@end

@implementation MyESettingsViewController
@synthesize usernameLabel;
@synthesize keypadCell;
@synthesize mediatorLabel;
@synthesize houseData = _houseData;
@synthesize userId = _userId;
@synthesize userName = _userName;
@synthesize houseId = _houseId;
@synthesize houseName = _houseName;
//@synthesize isRemoteControl = _isRemoteControl;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    _houseData = [[MyEHouseData alloc] init];
    [self configueView];
    
    NSArray *tipDataArray = [NSArray arrayWithObjects:
                             [MyETipDataModel tipDataModelWithKey:KEY_FOR_HIDE_TIP_OF_SETTINGS title:@"Tip" message:@"Reset “Tip Popups” to reactivate all closed tips."],
                             nil];
    _tipViewController = [MyETipViewController tipViewControllerWithTipDataArray:tipDataArray];
    
}

- (void)viewDidUnload
{
    [self setUsernameLabel:nil];
    [self setMediatorLabel:nil];
    [self setKeypadCell:nil];
    [self setTableView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // 设置Table cell的背景、边框为空
    [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]].backgroundView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:3]].backgroundView = [[UIView alloc] initWithFrame:CGRectZero];
    
    //可以用下面语句生成一个新Edit button，并替换掉父容器TabBarController的navigationItem的右边按钮
    self.parentViewController.navigationItem.rightBarButtonItems = nil;
    UIBarButtonItem *refreshButton = [[UIBarButtonItem alloc] 
                                      initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh 
                                      target:self 
                                      action:@selector(downloadModelFromServer)];
    self.parentViewController.navigationItem.rightBarButtonItem = refreshButton;
    
    [self downloadModelFromServer];
    [_tipViewController showTips];
}

- (void)setHouseData:(MyEHouseData *)houseData {
    if (_houseData != houseData)
        _houseData = houseData;
    [self configueView];
}
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"ShowPasswordResetView"]) {
        MyEPasswordResetViewController *vc = [segue destinationViewController];
        vc.userId = self.userId;
        vc.houseId = self.houseId;
    }
}

/*
- (void)setIsRemoteControl:(BOOL)isRemoteControl {
    _isRemoteControl = isRemoteControl;
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
            CGFloat components[8] = { 0.0, 0.0, 0.0, 0.05, // Start color
                0.0, 0.0, 0.0, 0.2 }; // End color
            myColorspace = CGColorSpaceCreateDeviceRGB();
            myGradient = CGGradientCreateWithColorComponents (myColorspace, components,
                                                              locations, num_locations);    
            CGPoint centerPoint;
            centerPoint.x = bounds.origin.x + bounds.size.width/2;
            centerPoint.y = bounds.origin.y + bounds.size.height/2;
            
            CGContextDrawRadialGradient(context, myGradient, centerPoint, 0, centerPoint, bounds.size.height/2, kCGGradientDrawsAfterEndLocation);
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
*/

#pragma mark
#pragma mark private method
- (void)configueView {
    //刷新远程控制的状态。
//    self.isRemoteControl = [self.settingsData.locWeb caseInsensitiveCompare:@"enabled"] == NSOrderedSame;
    
    self.usernameLabel.text = self.userName;
    self.mediatorLabel.text = self.houseData.mId;
    [self.tableView reloadData];

}
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
            message = [NSString stringWithFormat:@"The thermostat of hosue %@ was disconnected now.", currentHouseName];
        } else if (respondInt == -998) {
            message = [NSString stringWithFormat:@"The thermostat of hosue %@ was set to Remote Control Disabled.", currentHouseName];
        }
        
        [hlvc showAutoDisappearAlertWithTile:@"Alert" message:message delay:10.0f];
        return NO;
    } 
    return YES;
    
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

    NSString *urlStr = [NSString stringWithFormat:@"%@?userId=%@&houseId=%i",URL_FOR_SETTINGS_VIEW, self.userId, self.houseId];
    MyEDataLoader *loader = [[MyEDataLoader alloc] initLoadingWithURLString:urlStr postData:nil delegate:self loaderName:@"SettingsDownloader"  userDataDictionary:nil];
    NSLog(@"SettingsDownloader is %@",loader.name);
}
- (void)uploadModelToServerWithTId:(NSString *)tId keypad:(NSInteger)keypad {
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

//    NSString *urlStr = [NSString stringWithFormat:@"%@&currentPassowrd=null&newPassword=null&keyPad=%i",URL_FOR_SETTINGS_SAVE, keypad];
    NSString *urlStr = [NSString stringWithFormat:@"%@?userId=%@&houseId=%i&tId=%@&currentPassowrd=null&newPassword=null&keyPad=%i",URL_FOR_SETTINGS_SAVE, self.userId, self.houseId, tId, keypad];
    
    // 记录下这次修改的t的id
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                          tId, @"tId",
                          keypad, @"keypad",
                          nil ];
    MyEDataLoader *loader = [[MyEDataLoader alloc] initLoadingWithURLString:urlStr postData:@"" delegate:self loaderName:@"SettingsKeypadUploader" userDataDictionary:dict];
    NSLog(@"SettingsUploader is %@",loader.name);
}


- (void) didReceiveString:(NSString *)string loaderName:(NSString *)name userDataDictionary:(NSDictionary *)dict{
    [HUD hide:YES];
    if([name isEqualToString:@"SettingsDownloader"]) {
        // 判定是否服务器相应正常，如果服务器相应为-999/-998，那么_processHttpRespondForString函数会迫使
        // Navigation View Controller跳转到Houselist view。
        // 如果要中断本层函数执行，必须捕捉_processHttpRespondForString函数返回的NO值，并中断本层函数。
        if (![self _processHttpRespondForString:string])
            return;
        
        NSLog(@"View Settings JSON String from server is \n%@",string);
        
        // for  test
        string = @"{\"mId\":\"05-00-00-00-00-00-02-0E\",\"connection\":0,\"houseName\":\"House5604\",\"thermostats\":[{\"thermostat\":0,\"tName\":\"T-50\",\"deviceType\":0,\"tId\":\"00-00-00-00-00-00-02-50\",\"keypad\":0,\"remote\":1},{\"thermostat\":0,\"tName\":\"T-74\",\"deviceType\":0,\"tId\":\"00-00-00-00-00-00-01-74\",\"keypad\":0,\"remote\":1}],\"houseId\":3374}";
        MyEHouseData *houseData = [[MyEHouseData alloc] initWithJSONString:string];
        if (houseData) {
            NSLog(@"settings data is \n %@", [[houseData JSONDictionary] JSONRepresentation]);
            [self setHouseData:houseData];
        }else {
            UIAlertView *alert =[[UIAlertView alloc]initWithTitle:@"Error" 
                                                          message:@"Communication error. Please try again."
                                                         delegate:self 
                                                cancelButtonTitle:@"Ok"
                                                otherButtonTitles:nil];
            [alert show];
        }
    }
    if([name isEqualToString:@"SettingsKeypadUploader"]) {
        // 判定是否服务器相应正常，如果服务器相应为-999/-998，那么_processHttpRespondForString函数会迫使
        // Navigation View Controller跳转到Houselist view。
        // 如果要中断本层函数执行，必须捕捉_processHttpRespondForString函数返回的NO值，并中断本层函数。
        if (![self _processHttpRespondForString:string])
            return;
        
        NSLog(@"Keypad upload with result: %@", string);
        NSInteger tIndex=0;
        for (tIndex=0; tIndex<[self.houseData.thermostats count]; tIndex++) {
            if(((MyEThermostatData *)[self.houseData.thermostats objectAtIndex:tIndex]).tId == [dict objectForKey:@"tId"]){
                break;
            }
        }
        if ([string isEqualToString:@"OK"]) {//TODO
            // 如果服务器修改成功了，这里才真正地修改keyPad的值
            ((MyEThermostatData *)[self.houseData.thermostats objectAtIndex:tIndex]).keypad = (NSInteger)[dict valueForKey:@"keypad"];
        } else {
            // 如果修改失败，把switch的开关转会原来状态
            
            
            NSIndexPath *ip = [NSIndexPath indexPathForItem:tIndex inSection:2];
            ((MyESettingsThermostatCell *)[self.tableView cellForRowAtIndexPath:ip]).keypadLockSwitch.on = ((MyEThermostatData *)[self.houseData.thermostats objectAtIndex:tIndex]).keypad == 1;
            UIAlertView *alert =[[UIAlertView alloc]initWithTitle:@"Error"
                                                          message:string  //@"Cannot change keypad lock."
                                                         delegate:self 
                                                cancelButtonTitle:@"Ok"
                                                otherButtonTitles:nil];
            [alert show];
        }
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
#pragma mark MBProgressHUDDelegate methods

- (void)hudWasHidden:(MBProgressHUD *)hud {
	// Remove HUD from screen when the HUD was hidded
	[HUD removeFromSuperview];
	HUD = nil;
}

#pragma mark -
#pragma mark auto disapear alert methods
- (void) dimissAlert:(UIAlertView *)alert
{
    if(alert)
    {
        [alert dismissWithClickedButtonIndex:[alert cancelButtonIndex] animated:YES];
    }
}

// the unit of delay is second
- (void)showAutoDisappearAlertWithTile:(NSString *)title message:(NSString *)message delay:(NSInteger)delay{            
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil 
                                          cancelButtonTitle:@"Ok" otherButtonTitles:nil];
    
    [alert show];
    [self performSelector:@selector(dimissAlert:) withObject:alert afterDelay:delay];
}



#pragma mark
#pragma mark 插座方法
- (IBAction)resetTipPopups:(id)sender {
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    [prefs setBool:NO forKey:KEY_FOR_HIDE_TIP_OF_DASHBOARD1];
    [prefs setBool:NO forKey:KEY_FOR_HIDE_TIP_OF_DASHBOARD2];
    [prefs setBool:NO forKey:KEY_FOR_HIDE_TIP_OF_SCHEDULE_TODAY1];
    [prefs setBool:NO forKey:KEY_FOR_HIDE_TIP_OF_SCHEDULE_TODAY2];
    [prefs setBool:NO forKey:KEY_FOR_HIDE_TIP_OF_SCHEDULE_NEXT24HRS1];
    [prefs setBool:NO forKey:KEY_FOR_HIDE_TIP_OF_SCHEDULE_NEXT24HRS2];
    [prefs setBool:NO forKey:KEY_FOR_HIDE_TIP_OF_SCHEDULE_WEEKLY];
    [prefs setBool:NO forKey:KEY_FOR_HIDE_TIP_OF_VACATION];
    [prefs setBool:NO forKey:KEY_FOR_HIDE_TIP_OF_SETTINGS];
    [prefs setBool:NO forKey:KEY_FOR_APP_HAS_LAUNCHED_ONCE];// App是否已经加载过
    [prefs synchronize];
    
    [self showAutoDisappearAlertWithTile:@"Information" message:@"All tip popups have been reset to show automatically." delay:5.0f];
}



#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    // Return the number of rows in the section.
    return [self.houseData.thermostats count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Configure the cell...
    MyEThermostatData *thermostat = [self.houseData.thermostats objectAtIndex:indexPath.row];

        
    MyESettingsThermostatCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SettingsThermostatCell"];
    if (cell == nil) {
        cell = [[MyESettingsThermostatCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"SettingsThermostatCell"];
    }
    [[cell thermostatLabel] setText:thermostat.tId];
    [[cell nameLabel] setText:thermostat.tName];
    cell.delegate = self;
        
    return cell;       
}


#pragma mark delegat methods for MyESettingsThermostatCellDelegate
-(void) didKeypadSwitchChanged:(MyESettingsThermostatCell *)theCell
{
    NSString *tId = theCell.thermostatLabel.text;
    NSInteger keypad = theCell.keypadLockSwitch.on?1:0;
    [self uploadModelToServerWithTId:tId keypad:keypad];
}
@end
