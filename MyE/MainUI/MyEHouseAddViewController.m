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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
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
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
            MyEHouseListViewController *hlvc = [storyboard instantiateViewControllerWithIdentifier:@"HouseListVC"];
            MainDelegate.accountData = self.accountData;
            [MainDelegate.window.rootViewController dismissViewControllerAnimated:NO completion:nil];
            MainDelegate.window.rootViewController = hlvc;// 用主Navigation VC作为程序的rootViewController
        }else if (i == -1){
            [MyEUtil showMessageOn:nil withMessage:@"This house does not exist,Please rewrite"];
        }else{
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Alert" message:@"Add House Failed,Do You Want To Try Again?" delegate:self cancelButtonTitle:@"NO" otherButtonTitles:@"YES", nil];
            alert.tag = 100;
            [alert show];
        }
    }
}
#pragma mark - UIAlertView delegate methods
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (alertView.tag == 100 && buttonIndex == 1) {
        [self uploadOrDownloadInfoFromServerWithURL:[NSString stringWithFormat:@"%@?state=%@&city=%@&street=%@&mediatorBindFlag=%i",GetRequst(URL_FOR_ADD_ADDRESS),self.lblState.text,self.txtCity.text,self.txtStreet.text,self.bindBtn.selected] andName:@"addHouse"];
    }
}
#pragma mark - MYEPickerView delegate methods
-(void)MYEPickerView:(UIView *)pickerView didSelectTitles:(NSString *)title andRow:(NSInteger)row{
    self.lblState.text = title;
}
@end
