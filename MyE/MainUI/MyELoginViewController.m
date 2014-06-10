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
#import "MyEHouseAddViewController.h"
#import "MyEDashboardViewController.h"
#import "MyEHouseData.h"
#import "MyETerminalData.h"
#import "MyEUtil.h"
#import "SBJson.h"

#import "ServerViewController.h"
#import "SWRevealViewController.h"

@implementation MyELoginViewController

@synthesize usernameInput = _usernameInput;
@synthesize passwordInput = _passwordInput;
@synthesize loginButton = _loginButton;

@synthesize accountData = _accountData;

-(IBAction) setIp:(UIButton *) sender
{
    ServerViewController *sc = [[ServerViewController alloc] init];
    [self presentViewController:sc animated:YES completion:nil];
}


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

- (void)viewDidLoad
{
    [super viewDidLoad];

    // 下面使用9宫格可缩放图片作为按钮背景
    UIImage *normalImage = [[UIImage imageNamed:@"control-enable-normal"] stretchableImageWithLeftCapWidth:0 topCapHeight:0];
    UIImage *highlightImage = [[UIImage imageNamed:@"control-enable-highlight"] stretchableImageWithLeftCapWidth:0 topCapHeight:0];
    [self.loginButton setBackgroundImage:normalImage forState:UIControlStateNormal];
    [self.loginButton setBackgroundImage:highlightImage forState:UIControlStateHighlighted];
    [self.loginButton setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted];
    [self.scanBtn setBackgroundImage:normalImage forState:UIControlStateNormal];
    [self.scanBtn setBackgroundImage:highlightImage forState:UIControlStateHighlighted];
    [self.scanBtn setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted];
    self.bgView.layer.cornerRadius = 4;
    [self loadSettings];
    
//    if (IS_IPHONE5) {
//        //特别注意，对于iPhone5只有retina屏幕，所以只需要使用@2x的image就可以了
//        [self.loginImage setImage:[UIImage imageNamed:@"login-568h@2x"]];
//    }
    //以下代码为修改placeholder的文字颜色，这种技巧应该多加注意
    [self.usernameInput setValue:[UIColor lightGrayColor] forKeyPath:@"_placeholderLabel.textColor"];
    [self.passwordInput setValue:[UIColor lightGrayColor] forKeyPath:@"_placeholderLabel.textColor"];
}


- (void)viewDidUnload
{
    [self setUsernameInput:nil];
    [self setPasswordInput:nil];
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

#pragma mark - Navigation methods
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    MainDelegate.accountData = self.accountData;
    
    if ([[segue identifier] isEqualToString:@"go_main_menu"])
    {
        MyEHouseData *houseData = [self.accountData validHouseInListAtIndex:0];
        MainDelegate.houseData = houseData;
        
        //在NSDefaults里面记录这次要进入的房屋
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        [prefs setInteger:houseData.houseId forKey:KEY_FOR_HOUSE_ID_LAST_VIEWED];
        
        MyETerminalData *thermostatData = [houseData.terminals objectAtIndex:0];// 用该房子的第一个T
        MainDelegate.terminalData = thermostatData;
        
        [prefs setValue:thermostatData.tId forKey:KEY_FOR_TID_LAST_VIEWED];
        [prefs synchronize];
     }
    if ([[segue identifier] isEqualToString:@"ShowHouseList"])
    {
        MyEHouseListViewController *hlvc = [[segue destinationViewController] childViewControllers][0];
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

#pragma mark - IBAction methods
- (IBAction)login:(id)sender {
    [self _doLogin];
}
- (IBAction)changeSaveSettings:(UIButton *)sender {
    sender.selected = !sender.selected;
}
- (IBAction)scanToRegister:(UIButton *)sender {
    UINavigationController *nav = [[UIStoryboard storyboardWithName:@"Setting" bundle:nil] instantiateViewControllerWithIdentifier:@"scanNav"];
    MyEQRScanViewController *vc = nav.childViewControllers[0];
    vc.delegate = self;
    [self presentViewController:nav animated:YES completion:nil];
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
        if(anAccountData && anAccountData.loginSuccess)
        {
            self.accountData = anAccountData;
            MainDelegate.accountData = self.accountData;
            
            if (anAccountData.houseList.count < 1 ){
                UIAlertView *alert =[[UIAlertView alloc]initWithTitle:@"Information" 
                                                              message:@"This app is for Smart Home control associated with a property. Please tap OK to go on adding a property to your account before using this app, or tap Cancel to exit."
                                                             delegate:self 
                                                    cancelButtonTitle:@"Cancel"
                                                    otherButtonTitles:@"OK",nil];
                alert.tag = 100;
                [alert show];
            }
            else if (anAccountData.houseList.count == 1 &&
                       ([(MyEHouseData *)[anAccountData.houseList objectAtIndex:0] isConnected]))
            {
                MainDelegate.houseData = [anAccountData.houseList objectAtIndex:0];
                //在NSDefaults里面记录这次要进入的房屋
                NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
                
                NSString *tid = [prefs objectForKey:KEY_FOR_TID_LAST_VIEWED];
                for (MyETerminalData *temp in MainDelegate.houseData.terminals)
                {
                    if ([tid isEqualToString:temp.tId])
                    {
                        MainDelegate.terminalData = temp;
                        break;
                    }
                }
                if (MainDelegate.terminalData == nil)
                {
                    MainDelegate.terminalData = [MainDelegate.houseData firstConnectedThermostat];
                }
                // 如果只有一个带硬件的房子，且硬件在线，则不用在House List停留，直接将该房子选中而进入Dashboard。
                MyEHouseData *houseData = [self.accountData validHouseInListAtIndex:0];
                MainDelegate.houseData = houseData;
                
                //在NSDefaults里面记录这次要进入的房屋
                [prefs setInteger:houseData.houseId forKey:KEY_FOR_HOUSE_ID_LAST_VIEWED];
                
                MyETerminalData *thermostatData = [houseData.terminals objectAtIndex:0];// 用该房子的第一个T
                MainDelegate.terminalData = thermostatData;
                
                [prefs setValue:thermostatData.tId forKey:KEY_FOR_TID_LAST_VIEWED];
                [prefs synchronize];
                UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
                SWRevealViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"SlideMenuVC"];
//                [self presentViewController:vc animated:YES completion:nil];
                [MainDelegate.window.rootViewController dismissViewControllerAnimated:NO completion:nil];
                MainDelegate.window.rootViewController = vc;// 用主Navigation VC作为程序的rootViewController
            }
            else if (anAccountData.houseList.count >= 1)
            {
                UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
                MyEHouseListViewController *hlvc = [storyboard instantiateViewControllerWithIdentifier:@"HouseListVC"];
                hlvc.accountData = self.accountData;
                [MainDelegate.window.rootViewController dismissViewControllerAnimated:NO completion:nil];
                MainDelegate.window.rootViewController = hlvc;// 用主Navigation VC作为程序的rootViewController
            }           
        }
        else
        {
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
    if(alertView.tag == 100 && index == 0) {
        UIStoryboard *story = [UIStoryboard storyboardWithName:@"Setting" bundle:nil];
        UINavigationController *nav = [story instantiateViewControllerWithIdentifier:@"addHouse"];
        [self presentViewController:nav animated:YES completion:nil];
    }
}

#pragma mark - MyEQRScanViewControllerDelegate method
-(void)passMID:(NSString *)mid andPIN:(NSString *)pin{
    self.usernameInput.text = mid;
    self.passwordInput.text = pin;
    [self _doLogin];
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
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
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
        HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        HUD.delegate = self;
    } else
        [HUD show:YES];
    
    NSString *urlStr = [NSString stringWithFormat:@"%@?username=%@&password=%@&type=1",GetRequst(URL_FOR_LOGIN), self.usernameInput.text, self.passwordInput.text] ;
    MyEDataLoader *downloader = [[MyEDataLoader alloc] initLoadingWithURLString:urlStr postData:nil delegate:self loaderName:@"LoginDownloader" userDataDictionary:nil];
    NSLog(@"downloader.name is  %@ urlStr =  %@",downloader.name, urlStr);
}
-(void)loadSettings{
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    self.saveBtn.selected = [prefs boolForKey:@"rememberme"];
    if (self.saveBtn.selected) {
        self.usernameInput.text = [prefs objectForKey:@"username"];
        self.passwordInput.text = [prefs objectForKey:@"password"];
    }
}

-(void)saveSettings{
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    if (self.saveBtn.selected) {
        [prefs setObject:self.usernameInput.text forKey:@"username"];
        [prefs setObject:self.passwordInput.text forKey:@"password"];
        [prefs setBool:YES forKey:@"rememberme"];
    }else {
        [prefs setObject:[NSNumber numberWithBool:NO] forKey:@"rememberme"];
    }
    [prefs synchronize];
}
@end
