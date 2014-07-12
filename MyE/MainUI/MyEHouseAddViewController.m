//
//  MyEHouseAddViewController.m
//  MyE
//
//  Created by 翟强 on 14-5-15.
//  Copyright (c) 2014年 MyEnergy Domain. All rights reserved.
//

#import "MyEHouseAddViewController.h"
#import "MyEHouseListViewController.h"

@interface MyEHouseAddViewController (){
    MBProgressHUD *HUD;
    NSArray *_data;
    MYEPickerView *_picker;
}

@end

@implementation MyEHouseAddViewController

#pragma mark - life circle methods
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.okBtn setStyleType:ACPButtonOK];
    _data = @[@"AL",@"AK",@"AS",@"AZ",@"AR",@"CA",@"CO",@"CT",@"DE",@"DC",@"FL",@"GA",@"GU",@"HI",@"IA",@"ID",@"IL",@"IN",@"KS",@"KY",@"LA",@"MA",@"ME",@"MD",@"MI",@"MN",@"MO",@"MP",@"MS",@"MT",@"NC",@"ND",@"NE",@"NH",@"NJ",@"NM",@"NV",@"NY",@"OH",@"OK",@"OR",@"PA",@"PR",@"RI",@"SC",@"SD",@"TN",@"TX",@"UT",@"VA",@"VI",@"VT",@"WA",@"WV",@"WI",@"WY"];
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
    [btn setFrame:CGRectMake(0, 0, 50, 30)];
    [btn setBackgroundImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
    if (!IS_IOS6) {
        [btn setTitleEdgeInsets:UIEdgeInsetsMake(0, 20, 0, 0)];
    }
    [btn addTarget:self action:@selector(dismissVC) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btn];
    [self defineTapGestureRecognizer];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}
#pragma mark - private methods
-(void)defineTapGestureRecognizer{
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
    tapGesture.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tapGesture];
}

-(void)hideKeyboard{
    [self.txtCity endEditing:YES];
    [self.txtStreet endEditing:YES];
}

-(void)login{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *urlStr = [NSString stringWithFormat:@"%@?username=%@&password=%@&type=1&checkCode=2&deviceType=0&deviceToken=%@&deviceAlias=%@&appVersion=%@",GetRequst(URL_FOR_LOGIN), [defaults objectForKey:@"user"], [defaults objectForKey:@"pass"],MainDelegate.deviceTokenStr,MainDelegate.alias,[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"]] ;
    MyEDataLoader *downloader = [[MyEDataLoader alloc] initLoadingWithURLString:urlStr postData:nil delegate:self loaderName:@"LoginDownloader" userDataDictionary:nil];
    NSLog(@"downloader.name is  %@ urlStr =  %@",downloader.name, urlStr);
}
#pragma mark - IBAction methods
- (IBAction)save:(UIButton *)sender {
    [self.txtStreet resignFirstResponder];
    [self.txtCity resignFirstResponder];
    if ([self.lblState.text isEqualToString:@"Press Here To Select Your State"]) {
        [MyEUtil showMessageOn:nil withMessage:@"Please select Your State"];
        return;
    }
    if ([self.txtCity.text isEqualToString:@""]) {
        [MyEUtil showMessageOn:nil withMessage:@"Please select your city"];
        return;
    }
    if ([self.txtStreet.text isEqualToString:@""]) {
        [MyEUtil showMessageOn:nil withMessage:@"Please select your street"];
        return;
    }
    [self uploadOrDownloadInfoFromServerWithURL:[NSString stringWithFormat:@"%@?state=%@&city=%@&street=%@&mediatorBindFlag=%i",GetRequst(URL_FOR_ADD_ADDRESS),self.lblState.text,self.txtCity.text,self.txtStreet.text,self.bindBtn.selected] andName:@"addHouse"];
}
- (IBAction)bindMediator:(UIButton *)sender {
    sender.selected = !sender.selected;
}
- (void)dismissVC{
    [self dismissViewControllerAnimated:YES completion:nil];
}
#pragma mark - UITableView delegate methods
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self.txtStreet resignFirstResponder];
    [self.txtCity resignFirstResponder];
    _picker = [[MYEPickerView alloc] initWithView:self.view andTag:100 title:@"Select State" dataSource:_data andSelectRow:[_data containsObject:self.lblState.text]?[_data indexOfObject:self.lblState.text]:0];
    _picker.delegate = self;
    [_picker showInView:self.view];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}
#pragma mark - url methods
-(void)uploadOrDownloadInfoFromServerWithURL:(NSString *)string andName:(NSString *)name{
    if (HUD == nil) {
        HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    }
    [HUD show:YES];
    MyEDataLoader *loader = [[MyEDataLoader alloc] initLoadingWithURLString:string postData:nil delegate:self loaderName:name userDataDictionary:nil];
    NSLog(@"%@",loader.name);
}
#pragma mark - URL Delegate methods
-(void)didReceiveString:(NSString *)string loaderName:(NSString *)name userDataDictionary:(NSDictionary *)dict{
    NSLog(@"receive string is %@",string);
    [HUD hide:YES];
    if ([name isEqualToString:@"addHouse"]) {
        NSInteger i = [MyEUtil getResultFromAjaxString:string];
        if (i == 1) {
            NSDictionary *dic = [string JSONValue];
            if ([dic[@"mediatorBindState"] intValue] == 1) {
                
            }else{
                
            }
            [self login];
        }else if (i == -1){
            [MyEUtil showMessageOn:nil withMessage:@"This house does not exist,Please rewrite"];
        }else{
            [SVProgressHUD showErrorWithStatus:@"error!"];
        }
    }
    if([name isEqualToString:@"LoginDownloader"]) {
        MyEAccountData *anAccountData = [[MyEAccountData alloc] initWithJSONString:string];
        if(anAccountData && [anAccountData.loginSuccess isEqualToString:@"true"])
        {
            NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
            self.accountData = anAccountData;
            MainDelegate.accountData = self.accountData;
            
            if (anAccountData.houseList.count == 1 &&
                     ([(MyEHouseData *)[anAccountData.houseList objectAtIndex:0] isConnected]))
            {
                // 如果只有一个带硬件的房子，且硬件在线，则不用在House List停留，直接将该房子选中而进入Dashboard。
                MyEHouseData *houseData = [self.accountData validHouseInListAtIndex:0];
                MainDelegate.houseData = houseData;
//                MainDelegate.terminalData = [MainDelegate.houseData firstConnectedThermostat];
                
                //在NSDefaults里面记录这次要进入的房屋
                [prefs setInteger:houseData.houseId forKey:KEY_FOR_HOUSE_ID_LAST_VIEWED];
                [prefs synchronize];
                
//                MyETerminalData *thermostatData = [houseData.terminals objectAtIndex:0];// 用该房子的第一个T
//                MainDelegate.terminalData = thermostatData;
                
                UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
                SWRevealViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"SlideMenuVC"];
                [MainDelegate.window.rootViewController dismissViewControllerAnimated:NO completion:nil];
                MainDelegate.window.rootViewController = vc;// 用主Navigation VC作为程序的rootViewController
            }else{
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Alert" message:@"Something is wrong, please try again!" delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
                alert.tag = 200;
                [alert show];
            }
        }else{
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Alert" message:@"Login error, please try again!" delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
            alert.tag = 200;
            [alert show];
        }
    }
}
-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error loaderName:(NSString *)name{
    [HUD hide:YES];
    [SVProgressHUD showErrorWithStatus:@"Connection Fail"];
}
#pragma mark - UIAlertView delegate methods
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (alertView.tag == 100 && buttonIndex == 1) {
        [self uploadOrDownloadInfoFromServerWithURL:[NSString stringWithFormat:@"%@?state=%@&city=%@&street=%@&mediatorBindFlag=%i",GetRequst(URL_FOR_ADD_ADDRESS),self.lblState.text,self.txtCity.text,self.txtStreet.text,self.bindBtn.selected] andName:@"addHouse"];
    }
    if (alertView.tag == 200 && buttonIndex == 0) { //两个Btn的话索引为1，一个btn的话索引为0
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
        MyELoginViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"LoginViewController"];
        [MainDelegate.window.rootViewController dismissViewControllerAnimated:NO completion:nil];
        MainDelegate.window.rootViewController = vc;// 用主Navigation VC作为程序的rootViewController
    }
}
#pragma mark - MYEPickerView delegate methods
-(void)MYEPickerView:(UIView *)pickerView didSelectTitles:(NSString *)title andRow:(NSInteger)row{
    self.lblState.text = title;
}
@end
