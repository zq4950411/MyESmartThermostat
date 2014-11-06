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

//#import "ServerViewController.h"
#import "SWRevealViewController.h"

@implementation MyELoginViewController

@synthesize usernameInput = _usernameInput;
@synthesize passwordInput = _passwordInput;
@synthesize loginButton = _loginButton;

@synthesize accountData = _accountData;

//-(IBAction) setIp:(UIButton *) sender
//{
//    ServerViewController *sc = [[ServerViewController alloc] init];
//    [self presentViewController:sc animated:YES completion:nil];
//}

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
    UIImage *normalImage = [[UIImage imageNamed:@"login-normal"] stretchableImageWithLeftCapWidth:0 topCapHeight:0];
    UIImage *highlightImage = [[UIImage imageNamed:@"login-highlight"] stretchableImageWithLeftCapWidth:0 topCapHeight:0];
    [self.loginButton setBackgroundImage:normalImage forState:UIControlStateNormal];
    [self.loginButton setBackgroundImage:highlightImage forState:UIControlStateHighlighted];
    [self.loginButton setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted];
    [self.scanBtn setBackgroundImage:normalImage forState:UIControlStateNormal];
    [self.scanBtn setBackgroundImage:highlightImage forState:UIControlStateHighlighted];
    [self.scanBtn setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted];
    self.bgView.layer.cornerRadius = 4;
    [self loadSettings];
    if ([[self getUsersFromPlist] count] <= 1) {  //只有当登录的用户至少为两个时，才允许用户切换账户
        self.showBtn.hidden = YES;
    }else
        [self reloadUsersTableViewContents];

//    if (IS_IPHONE5) {
//        //特别注意，对于iPhone5只有retina屏幕，所以只需要使用@2x的image就可以了
//        [self.loginImage setImage:[UIImage imageNamed:@"login-568h@2x"]];
//    }
    self.usernameInput.delegate = self;
    self.passwordInput.delegate = self;
    //以下代码为修改placeholder的文字颜色，这种技巧应该多加注意
    [self.usernameInput setValue:[UIColor lightGrayColor] forKeyPath:@"_placeholderLabel.textColor"];
    [self.passwordInput setValue:[UIColor lightGrayColor] forKeyPath:@"_placeholderLabel.textColor"];
    self.versionLbl.text = [NSString stringWithFormat:@"Version %@",[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"]];
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
/*
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{

}
*/

#pragma mark
#pragma mark private methods
-(NSMutableArray *)getUsersFromPlist{
    NSMutableArray *array = nil;
    NSString *filePath = [self dataFilePath];
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        array = [[NSMutableArray alloc] initWithContentsOfFile:filePath];
    }else
        array = [NSMutableArray array];
    return array;
}
-(void)reloadUsersTableViewContents{
    NSMutableArray *users = [self getUsersFromPlist];
    [_usersTableView reloadData];
    [_usersTableView initTableViewDataSourceAndDelegate:^(UITableView *tableView,NSUInteger section){
        return [users count];
        
    } setCellForIndexPathBlock:^(UITableView *tableView,NSIndexPath *indexPath){
        static NSString *cellIdetifier = @"cell";
        UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:cellIdetifier];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdetifier];
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 35)];
            label.font = [UIFont systemFontOfSize:15];
            label.tag = 998;
            label.textAlignment = NSTextAlignmentCenter;
            [cell.contentView addSubview:label];
        }
        UILabel *label = (UILabel *)[cell.contentView viewWithTag:998];
        label.text = [users[indexPath.row] objectForKey:@"username"];
        return cell;
    } setDidSelectRowBlock:^(UITableView *tableView,NSIndexPath *indexPath){
        UITableViewCell *cell=(UITableViewCell*)[tableView cellForRowAtIndexPath:indexPath];
        UILabel *label = (UILabel *)[cell.contentView viewWithTag:998];
        self.usernameInput.text = label.text;
        for (NSDictionary *d in users) {
            if ([d[@"username"] isEqualToString:label.text]) {
                self.passwordInput.text = d[@"password"];
            }
        }
        
        [_showBtn sendActionsForControlEvents:UIControlEventTouchUpInside];   //这句代码的意思就是说让按钮的方法运行一遍，这个想法不错
    } beginEditingStyleForRowAtIndexPath :^(UITableView* tableView, UITableViewCellEditingStyle editingStyle, NSIndexPath* indexPath){
        [users removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        [users writeToFile:[self dataFilePath] atomically:YES];
    }];
    _usersTableView.tableFooterView = [[UIView alloc] init];
    [_usersTableView.layer setBorderColor:[UIColor lightGrayColor].CGColor];
    [_usersTableView.layer setBorderWidth:1];
}
- (IBAction)saveUserInfo:(UIButton *)sender {
    sender.selected = !sender.selected;
}
-(NSString *)dataFilePath{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = paths[0];
    return [documentsDirectory stringByAppendingPathComponent:@"users.plist"];
}
-(void)writeUserInfoInPlist{
    NSMutableArray *array = [self getUsersFromPlist];
    BOOL canWrite = YES;
    if ([array count]) {
        for (NSDictionary *d in [NSArray arrayWithArray:array]) {     //只有不存在的情况下才可以添加
            if ([d[@"username"] isEqualToString:self.usernameInput.text] &&
                [d[@"password"] isEqualToString:self.passwordInput.text]) {
                canWrite = NO;
                break;
            }else if ([d[@"username"] isEqualToString:self.usernameInput.text] &&
                      ![d[@"password"] isEqualToString:self.passwordInput.text]){
                [d setValue:self.passwordInput.text forKey:@"password"];
                [array writeToFile:[self dataFilePath] atomically:YES];
                return;
            }
        }
    }
    if (canWrite) {
        [array addObject:@{@"username": self.usernameInput.text,
                           @"password": self.passwordInput.text}];
        [array writeToFile:[self dataFilePath] atomically:YES];
    }
}
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
- (IBAction)showUsers:(UIButton *)sender {
    if ([sender isSelected]) {   //isSelected 就是selected
        [UIView animateWithDuration:0.3 animations:^{
            CGRect frame=_usersTableView.frame;
            frame.size.height=0;
            [_usersTableView setFrame:frame];
        } completion:^(BOOL finished){
            [sender setSelected:NO];
        }];
    }else{
        [UIView animateWithDuration:0.3 animations:^{
            //            UIImage *openImage=[UIImage imageNamed:@"dropup.png"];
            //            [_showBtn setImage:openImage forState:UIControlStateNormal];
            
            CGRect frame=_usersTableView.frame;
            
            NSMutableArray *array = [self getUsersFromPlist];
            if ([array count] < 6 ) {
                frame.size.height = 35 * array.count;
            }else
                frame.size.height=150;
            
            [_usersTableView setFrame:frame];
        } completion:^(BOOL finished){
            [sender setSelected:YES];
        }];
    }
}
- (void)hideKeyboardBeforeResignActive:(NSNotification *)notification{
    [self.usernameInput resignFirstResponder];
    [self.passwordInput resignFirstResponder];
}

#pragma mark -
#pragma mark URL Loading System methods

- (void) didReceiveString:(NSString *)string loaderName:(NSString *)name userDataDictionary:(NSDictionary *)dict{
    NSLog(@"Login account JSON String from server is \n%@",string);
    [HUD hide:YES];
    if([name isEqualToString:@"LoginDownloader"]) {
        MyEAccountData *anAccountData = [[MyEAccountData alloc] initWithJSONString:string];
        if(anAccountData && [anAccountData.loginSuccess isEqualToString:@"true"])
        {
            NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
            self.accountData = anAccountData;
            MainDelegate.accountData = self.accountData;
            if (anAccountData.houseList.count < 1 ){
                [prefs setObject:self.usernameInput.text forKey:@"user"];
                [prefs setObject:self.passwordInput.text forKey:@"pass"];//这里记录用户名和密码，以便在注册房子的时候使用到
                UIAlertView *alert =[[UIAlertView alloc]initWithTitle:@"Information" 
                                                              message:@"This app is for Smart Home control associated with a property. Please tap OK to go on adding a property to your account before using this app, or tap Cancel to exit."
                                                             delegate:self 
                                                    cancelButtonTitle:@"Cancel"
                                                    otherButtonTitles:@"OK",nil];
                alert.tag = 100;
                [alert show];
            }
//            else if (anAccountData.houseList.count == 1 &&
//                       ([(MyEHouseData *)[anAccountData.houseList objectAtIndex:0] isConnected]))
            else if ([anAccountData countOfValidHouseList] == 1)
            {
                // 如果只有一个带硬件的房子，且硬件在线，则不用在House List停留，直接将该房子选中而进入Dashboard。
//                MyEHouseData *houseData = [self.accountData validHouseInListAtIndex:0];
                MainDelegate.houseData = [self.accountData firstValidHouseInList];
                MainDelegate.terminalData = [MainDelegate.houseData firstConnectedThermostat];
                
                //在NSDefaults里面记录这次要进入的房屋
                [prefs setInteger:MainDelegate.houseData.houseId forKey:KEY_FOR_HOUSE_ID_LAST_VIEWED];
                [prefs synchronize];
                
//                MyETerminalData *thermostatData = [houseData.terminals objectAtIndex:0];// 用该房子的第一个T
//                MainDelegate.terminalData = thermostatData;
                
                UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard"  bundle:nil];
                SWRevealViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"SlideMenuVC"];
                [MainDelegate.window.rootViewController dismissViewControllerAnimated:NO completion:nil];
                MainDelegate.window.rootViewController = vc;// 用主Navigation VC作为程序的rootViewController
            }
//            else if (anAccountData.houseList.count >= 1 && [anAccountData countOfValidHouseList] > 0)
            else if ([anAccountData countOfValidHouseList] > 1)
            {
                MyEHouseData *defaultHouseData;
                NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
                NSInteger defaultHouseId = [prefs integerForKey:KEY_FOR_HOUSE_ID_LAST_VIEWED];
                if (defaultHouseId > 0) {
                    defaultHouseData = [self.accountData houseDataByHouseId:defaultHouseId];
                    if (defaultHouseData.connection!= 0 || defaultHouseData.mId == nil || [defaultHouseData.mId isEqualToString:@"" ] || defaultHouseData.terminals.count == 0)
                    {//如果偏好里面记录的房子没有连接，或无效， 就用用第一个有效的house初始化defaultHouseData
                       defaultHouseData = [self.accountData validHouseInListAtIndex:0];
                    }
                }else // 如果以前没有浏览并保存过默认的houseId， 就用第一个有效的house
//                    defaultHouseData = [self.accountData validHouseInListAtIndex:0];
                    defaultHouseData = [self.accountData firstValidHouseInList];
                MainDelegate.houseData = defaultHouseData;
                MainDelegate.terminalData = [MainDelegate.houseData firstConnectedThermostat];
                UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard"  bundle:nil];
                SWRevealViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"SlideMenuVC"];
                [MainDelegate.window.rootViewController dismissViewControllerAnimated:NO completion:nil];
                MainDelegate.window.rootViewController = vc;// 用主Navigation VC作为程序的rootViewController
            } else {
                UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard"  bundle:nil];
                UINavigationController *nav = [storyboard instantiateViewControllerWithIdentifier:@"houseListNav"];
                MyEHouseListViewController *vc = nav.childViewControllers[0];
                vc.jumpFromLogin = YES;
                [self presentViewController:nav animated:YES completion:nil];
            }
        }
        else if(anAccountData && [anAccountData.loginSuccess isEqualToString:@"-1"]){
            UIAlertView *alert =[[UIAlertView alloc]initWithTitle:@"Alert"
                                                          message:@"This gateway has been registed"
                                                         delegate:nil
                                                cancelButtonTitle:@"Ok"
                                                otherButtonTitles:nil];
            [alert show];
        }else{
            UIAlertView *alert =[[UIAlertView alloc]initWithTitle:@"Login error" 
                                                          message:@"Please check your user name and password and try again."
                                                         delegate:nil 
                                                cancelButtonTitle:@"Ok"
                                                otherButtonTitles:nil];
            [alert show];
        }
    }
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
    if(alertView.tag == 100 && index == 1) {
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
     UIStoryboard *story = [UIStoryboard storyboardWithName:@"MainStoryboard"  bundle:nil];
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
    
    NSString *urlStr = [NSString stringWithFormat:@"%@?username=%@&password=%@&type=1&checkCode=2&deviceType=0&deviceToken=%@&deviceAlias=%@&appVersion=%@",GetRequst(URL_FOR_LOGIN), self.usernameInput.text, self.passwordInput.text,MainDelegate.deviceTokenStr,MainDelegate.alias,[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"]] ;
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
        [self writeUserInfoInPlist];
    }else {
        [prefs setObject:[NSNumber numberWithBool:NO] forKey:@"rememberme"];
    }
    [prefs synchronize];
}

@end
