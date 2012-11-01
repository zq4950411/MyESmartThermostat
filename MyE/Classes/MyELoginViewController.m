//
//  MyELoginViewController.m
//  MyE
//
//  Created by Ye Yuan on 1/19/12.
//  Copyright (c) 2012 MyEnergy Domain. All rights reserved.
//

#import "MyELoginViewController.h"
#import "MyEAccountData.h"
#import "MyEHouseListViewController.h"
#import "MyEMainTabBarController.h"
#import "MyEDashboardViewController.h"
#import "MyEScheduleViewController.h"
#import "MyEVacationMasterViewController.h"
#import "MyESettingsViewController.h"
#import "MyEHouseData.h"
#import "MyEUtil.h"
#import "SBJson.h"


@implementation MyELoginViewController

@synthesize usernameInput = _usernameInput;
@synthesize passwordInput = _passwordInput;
@synthesize rememberMeInput = _rememberMeInput;
@synthesize loginButton = _loginButton;

@synthesize accountData = _accountData;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];

    // 下面使用9宫格可缩放图片作为按钮背景
    UIImage *buttonBackImage = [UIImage imageNamed:@"buttonbg.png" ];
    buttonBackImage = [buttonBackImage stretchableImageWithLeftCapWidth:10 topCapHeight:10];
    [self.loginButton setBackgroundImage:buttonBackImage forState:UIControlStateNormal];
    
    [self loadSettings];
    
    // Observe keyboard hide and show notifications to resize the text view appropriately.
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(hideKeyboardBeforeResignActive:)
                                                 name:UIApplicationWillResignActiveNotification
                                               object:nil];
}


- (void)viewDidUnload
{
    [self setUsernameInput:nil];
    [self setPasswordInput:nil];
    [self setRememberMeInput:nil];
    [self setLoginButton:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    //    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillEnterForegroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillResignActiveNotification object:nil];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

//*
 // Implement prepareForSegue to do additional configuration, such as assigning data before transition to another view.
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([[segue identifier] isEqualToString:@"ShowMainTabViewDirectly"]) {
        MyEMainTabBarController *tabBarController = [segue destinationViewController];
        //在这里为每个tab view设置houseId和userId, 同时要为每个tab viewController中定义这两个变量，并实现一个统一的签名方法，以保存这个变量。
        MyEHouseData *houseData = [self.accountData objectInHouseListAtIndex:0];       
        
        //在NSDefaults里面记录这次要进入的房屋
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        [prefs setInteger:houseData.houseId forKey:KEY_FOR_HOUSE_ID_LAST_VIEWED];
        [prefs synchronize];
        
        //        [tabBarController setTitle:@"Dashboard"];
        [tabBarController setTitle:houseData.houseName];
        tabBarController.userId = self.accountData.userId;
        tabBarController.houseId = houseData.houseId;
        tabBarController.houseName = houseData.houseName;

        MyEDashboardViewController *dashboardViewController = [[tabBarController childViewControllers] objectAtIndex:0];
        dashboardViewController.userId = self.accountData.userId;
        dashboardViewController.houseId = houseData.houseId;
        dashboardViewController.houseName = houseData.houseName;
        dashboardViewController.isRemoteControl = houseData.remote == 0? NO:YES;
        
        
        MyEScheduleViewController *scheduleViewController = [[tabBarController childViewControllers] objectAtIndex:1];
        scheduleViewController.userId = self.accountData.userId;
        scheduleViewController.houseId = houseData.houseId;
        scheduleViewController.houseName = houseData.houseName;
        scheduleViewController.isRemoteControl = houseData.remote == 0? NO:YES;
        
        MyEVacationMasterViewController *vacationViewController = [[tabBarController childViewControllers] objectAtIndex:2];
        vacationViewController.userId = self.accountData.userId;
        vacationViewController.houseId = houseData.houseId;
        vacationViewController.houseName = houseData.houseName;
        vacationViewController.isRemoteControl = houseData.remote == 0? NO:YES;
        
        MyESettingsViewController *settingsViewController = [[tabBarController childViewControllers] objectAtIndex:3];
        settingsViewController.userId = self.accountData.userId;
        settingsViewController.houseId = houseData.houseId;
        settingsViewController.houseName = houseData.houseName;
        settingsViewController.isRemoteControl = houseData.remote == 0? NO:YES;

    }
    if ([[segue identifier] isEqualToString:@"ShowHouseList"]) {
        MyEHouseListViewController *hlvc = [segue destinationViewController];
        hlvc.accountData = self.accountData;
    }
}
 //*/

#pragma mark
#pragma mark private methods
- (void)keyboardWillShow:(NSNotification *)notification {
    
    /*
     Reduce the size of the text view so that it's not obscured by the keyboard.
     Animate the resize so that it's in sync with the appearance of the keyboard.
     */
    
    NSDictionary *userInfo = [notification userInfo];
    
    // Get the origin of the keyboard when it's displayed.
    //    NSValue* aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    
    // Get the top of the keyboard as the y coordinate of its origin in self's view's coordinate system. The bottom of the text view's frame should align with the top of the keyboard's final position.
    //    CGRect keyboardRect = [aValue CGRectValue];
    //    keyboardRect = [self.view convertRect:keyboardRect fromView:nil];
    
    //    CGFloat keyboardTop = keyboardRect.origin.y;
    CGRect newTextViewFrame = self.view.bounds;
    //newTextViewFrame.size.height = keyboardTop - self.view.bounds.origin.y;
    //newTextViewFrame.origin.y = 220 - keyboardTop;
    
    // move the main view frame upward by half of the gap
    // between the navigation bar title (MyE) and the Username input text box
    newTextViewFrame.origin.y = self.view.bounds.origin.y -
    self.usernameInput.frame.origin.y / 2.0;
    
    // Get the duration of the animation.
    NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationDuration;
    [animationDurationValue getValue:&animationDuration];
    
    // Animate the resize of the text view's frame in sync with the keyboard's appearance.
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:animationDuration];
    
    self.view.frame = newTextViewFrame;
    
    [UIView commitAnimations];
}


- (void)keyboardWillHide:(NSNotification *)notification {
    
    NSDictionary* userInfo = [notification userInfo];
    
    /*
     Restore the size of the text view (fill self's view).
     Animate the resize so that it's in sync with the disappearance of the keyboard.
     */
    NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationDuration;
    [animationDurationValue getValue:&animationDuration];
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:animationDuration];
    
    self.view.frame = self.view.bounds;
    
    [UIView commitAnimations];
}

-(void)loadSettings{
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    self.rememberMeInput.on = [prefs boolForKey:@"rememberme"];
    if (self.rememberMeInput.isOn) {
        self.usernameInput.text = [prefs objectForKey:@"username"];
        self.passwordInput.text = [prefs objectForKey:@"password"];
    }
}

-(void)saveSettings{   
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    if (self.rememberMeInput.isOn) {
        [prefs setObject:self.usernameInput.text forKey:@"username"];
        [prefs setObject:self.passwordInput.text forKey:@"password"];
        [prefs setBool:YES forKey:@"rememberme"];  
    }else {
        [prefs setObject:[NSNumber numberWithBool:NO] forKey:@"rememberme"]; 
    }
    [prefs synchronize];
}

- (IBAction)login:(id)sender {
    [self _doLogin];
}



- (void)hideKeyboardBeforeResignActive:(NSNotification *)notification{
    [self.usernameInput resignFirstResponder];
    [self.passwordInput resignFirstResponder];
}




#pragma mark -
#pragma mark URL Loading System methods

- (void) didReceiveString:(NSString *)string loaderName:(NSString *)name userDataDictionary:(NSDictionary *)dict{
    NSLog(@"Login account JSON String from server is \n%@",string);
    if([name isEqualToString:@"LoginDownloader"]) {
        MyEAccountData *anAccountData = [[MyEAccountData alloc] initWithJSONString:string];
        if(anAccountData && anAccountData.loginSuccess) {
            self.accountData = anAccountData;
            if (anAccountData.houseList.count < 1 ){
                UIAlertView *alert =[[UIAlertView alloc]initWithTitle:@"Information" 
                                                              message:@"This application must work with MyE Smart Thermostat. If you have already purchased one, please register it through the website first."
                                                             delegate:self 
                                                    cancelButtonTitle:@"Ok"
                                                    otherButtonTitles:@"Cancel",nil];
                [alert show];
            } else if (anAccountData.houseList.count == 1 && ((MyEHouseData *)[anAccountData.houseList objectAtIndex:0]).thermostat == 0){
                // 如果只有一个带硬件的房子，且硬件在线，则不用在House List停留，直接将该房子选中而进入Dashboard。
                [self performSegueWithIdentifier:@"ShowMainTabViewDirectly" sender:self];
            } else if (anAccountData.houseList.count >= 1) {
                [self performSegueWithIdentifier:@"ShowHouseList" sender:self];
                /* 原来在这里直接对后面转入的VC设置变量，但发现我们需要在HouseList VC里面的viewDidLoad里面就需要执行读取用户默认houseId的工作，但此时需要accountData数据，此数据在下面才能传入，所以导致读取用户默认houseId的工作出错
                UINavigationController *navigationController = (UINavigationController *)self.navigationController;
                MyEHouseListViewController *hlvc = (MyEHouseListViewController *)[[navigationController viewControllers] objectAtIndex:1];
                
                hlvc.accountData = anAccountData;
                 */
            }           
        } else {
            UIAlertView *alert =[[UIAlertView alloc]initWithTitle:@"Login error" 
                                                          message:@"Please check your user name and password and try again."
                                                         delegate:nil 
                                                cancelButtonTitle:@"Ok"
                                                otherButtonTitles:nil];
            [alert show];
        }
    }
    [HUD hide:YES];
}



- (void) connection:(NSURLConnection *)connection didFailWithError:(NSError *)error loaderName:(NSString *)name{
    
    // inform the user
    UIAlertView *alert =[[UIAlertView alloc]initWithTitle:@"Error" 
                                                  message:@"Communication error. Please try again."
                                                 delegate:nil 
                                        cancelButtonTitle:@"Ok"
                                        otherButtonTitles:nil];
    [alert show];
    NSLog(@"In delegate Connection failed! Error - %@ %@",
          [error localizedDescription],
          [[error userInfo] objectForKey:NSURLErrorFailingURLStringErrorKey]);
    [HUD hide:YES];
}

#pragma mark -
#pragma mark UIAlertViewDelegate methods
-(void)alertView:(UIAlertView *)alertView  clickedButtonAtIndex:(int)index
{
    if([alertView.title isEqualToString:@"Information"] && index == 0) {
        NSString *urlString = @"http://www.myenergydomain.com";
        NSURL *url = [NSURL URLWithString:urlString];
        [[UIApplication sharedApplication] openURL:url];
    }
}

#pragma mark -
#pragma mark MBProgressHUDDelegate methods
- (void)hudWasHidden:(MBProgressHUD *)hud {
	// Remove HUD from screen when the HUD was hidded
	[HUD removeFromSuperview];
	HUD = nil;
}


#pragma mark -
#pragma mark UITextField Delegate Methods 委托方法 
// 添加每个textfield的键盘的return按钮的后续动作
- (BOOL) textFieldShouldReturn:(UITextField *)textField {
    if (textField == self.usernameInput) {
        [textField resignFirstResponder];
        [self.passwordInput becomeFirstResponder];
    }
    if (textField == self.passwordInput) {
        [textField resignFirstResponder];
        [self _doLogin];
    }
    return  YES;
}

#pragma mark -
#pragma mark private methods
-(void)_doLogin {
    // 如果用户名和密码的输入不足长度，提示后退出
    if([self.usernameInput.text  length] < 4 || [self.passwordInput.text length] < 6) {
        UIAlertView *alert =[[UIAlertView alloc]initWithTitle:@"Alert" 
                                                      message:@"Username or password is not correct."
                                                     delegate:nil 
                                            cancelButtonTitle:@"Ok"
                                            otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    
    
    [self saveSettings];
    
    /* 这段语句用于根据标示符，从Storyboard生成一个新的标示符为
     “MainTabViewController”的TabBarController,
     并present它。必须在Storyboard里面为这个TabBarController输入了标示符。
     这些语句和最后面的语句功能相同。
     UIStoryboard *story = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
     UITabBarController *rootViewController = [story     instantiateViewControllerWithIdentifier:@"MainTabViewController"];
     [self presentViewController:rootViewController animated:YES completion: nil];
     */
    
    
    ///////////////////////////////////////////////////////////////////////
    // Demo 用户登录
    if ( [self.usernameInput.text caseInsensitiveCompare:@"demo"] == NSOrderedSame) {
        MyEAccountData *anAccountData = [[MyEAccountData alloc] init];
        
        self.accountData = anAccountData;
        
        [self performSegueWithIdentifier:@"ShowMainTabViewDirectly" sender:self];
        
        return;
    }
    ///////////////////////////////////////////////////////////////////////
    
    // 1.判断是否联网：
    if (![MyEDataLoader isConnectedToInternet]) {
        UIAlertView *alert =[[UIAlertView alloc]initWithTitle:@"Alert" 
                                                      message:@"No Internet connection."
                                                     delegate:nil 
                                            cancelButtonTitle:@"Ok"
                                            otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    if(HUD == nil) {
        HUD = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
        //        HUD.dimBackground = YES; //容易产生灰条
        HUD.delegate = self;
    } else
        [HUD show:YES];
    
    NSString *urlStr = [NSString stringWithFormat:@"%@?username=%@&password=%@&type=1", URL_FOR_LOGIN, self.usernameInput.text, self.passwordInput.text] ;
    MyEDataLoader *downloader = [[MyEDataLoader alloc] initLoadingWithURLString:urlStr postData:nil delegate:self loaderName:@"LoginDownloader" userDataDictionary:nil];
    NSLog(@"downloader.name is  %@ urlStr =  %@",downloader.name, urlStr);
}
@end
