//
//  MyEPasswordResetViewController.m
//  MyE
//
//  Created by Ye Yuan on 3/29/12.
//  Copyright (c) 2012 MyEnergy Domain. All rights reserved.
//

#import "MyEPasswordResetViewController.h"
#import "MyEUtil.h"
#import "MyEAccountData.h"
#import "MyEHouseListViewController.h"

@interface MyEPasswordResetViewController ()
// 判定是否服务器相应正常，如果正常返回YES，如果服务器相应为-999/-998，
// 那么函数迫使Navigation View Controller跳转到Houselist view，并返回NO。
// 如果要中断外层函数执行，必须捕捉此函数返回的NO值，并中断外层函数。
- (BOOL)_processHttpRespondForString:(NSString *)respondText;
@end

@implementation MyEPasswordResetViewController
@synthesize currentPasswordTextField;
@synthesize npaswdTextField0;
@synthesize npaswdTextField1;
@synthesize userId = _userId;
@synthesize houseId = _houseId;

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
    
    self.navigationItem.rightBarButtonItem = nil;
    
    self.currentPasswordTextField.delegate = self;
    self.npaswdTextField0.delegate = self;
    self.npaswdTextField1.delegate = self;
}

- (void)viewDidUnload
{
    [self setCurrentPasswordTextField:nil];
    [self setNpaswdTextField0:nil];
    [self setNpaswdTextField1:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
#pragma mark -
#pragma mark URL Loading System methods
- (void)uploadModelToServerWithCurrentPassword:(NSString *)currentPassword newPassword:(NSString *)newPassword {
    if(HUD == nil) {
        HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        HUD.dimBackground = YES;//容易产生灰条
        HUD.delegate = self;
    } else
        [HUD show:YES];

//    NSString *urlStr = [NSString stringWithFormat:@"%@&currentPassword=%@&newPassword=%@&keyPad=null",URL_FOR_SETTINGS_SAVE, currentPassword, newPassword];
    NSString *urlStr = [NSString stringWithFormat:@"%@?userId=%@&houseId=%i&currentPassword=%@&newPassword=%@&keyPad=null",GetRequst(URL_FOR_SETTINGS_SAVE), self.userId, self.houseId, currentPassword, newPassword];
    MyEDataLoader *loader = [[MyEDataLoader alloc] initLoadingWithURLString:urlStr postData:@"" delegate:self loaderName:@"SettingsPasswordUploader" userDataDictionary:nil];
    NSLog(@"SettingsUploader is %@",loader.name);
}

- (void) didReceiveString:(NSString *)string loaderName:(NSString *)name userDataDictionary:(NSDictionary *)dict{
    [HUD hide:YES];
    if([name isEqualToString:@"SettingsPasswordUploader"]) {
        NSLog(@"Password upload with result: %@", string);
        // 判定是否服务器相应正常，如果服务器相应为-999/-998，那么_processHttpRespondForString函数会迫使
        // Navigation View Controller跳转到Houselist view。
        // 如果要中断本层函数执行，必须捕捉_processHttpRespondForString函数返回的NO值，并中断本层函数。
        if (![self _processHttpRespondForString:string])
            return;
        
        if ([string isEqualToString:@"OK"]) {
            [[self navigationController] popViewControllerAnimated:YES];
        } else {
            UIAlertView *alert =[[UIAlertView alloc]initWithTitle:@"Error" 
                                                          message:string //@"Cannot reset password."
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



- (IBAction)cancelAction:(id)sender {
    [[self navigationController] popViewControllerAnimated:YES];
}

- (IBAction)okAction:(id)sender {

    [self _doResetPassword];
}

#pragma mark
#pragma mark UITextFieldDelegate methods

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    if( textField == currentPasswordTextField){
        [npaswdTextField0 becomeFirstResponder];
    }
    if( textField == npaswdTextField0){
        [npaswdTextField1 becomeFirstResponder];
    }
    if( textField == npaswdTextField1){
        [self _doResetPassword];
    }
    return YES;
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

-(void)_doResetPassword {
    [self.currentPasswordTextField resignFirstResponder];
    [self.npaswdTextField0 resignFirstResponder];
    [self.npaswdTextField1 resignFirstResponder];
    
    if (![self.npaswdTextField0.text isEqualToString:self.npaswdTextField1.text]) {
        UIAlertView *alert =[[UIAlertView alloc]initWithTitle:@"Warning" 
                                                      message:@"New password doesn't match."
                                                     delegate:self 
                                            cancelButtonTitle:@"Ok"
                                            otherButtonTitles:nil];
        [alert show];
    } else if([self.npaswdTextField0.text length]<6) {
        UIAlertView *alert =[[UIAlertView alloc]initWithTitle:@"Warning" 
                                                      message:@"The password must have at least 6 characters."
                                                     delegate:self 
                                            cancelButtonTitle:@"Ok"
                                            otherButtonTitles:nil];
        [alert show];
    }
    else{
        [self uploadModelToServerWithCurrentPassword:self.currentPasswordTextField.text newPassword:self.npaswdTextField0.text];
    }
}
@end
