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
    NSString *imgName = IS_IOS6?@"detailBtn-ios6":@"detailBtn";
    [self.stateBtn setBackgroundImage:[[UIImage imageNamed:imgName] stretchableImageWithLeftCapWidth:0 topCapHeight:0] forState:UIControlStateNormal];
    [self.stateBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 30)];
    _data = @[@"NE",@"CA",@"AL",@"AK",@"AZ",@"AR",@"CO",@"CT",@"DE",@"DC",@"FL",@"GA",@"HI",@"ID",@"IL",@"IN",@"IA",@"KS",@"KY",@"LA",@"ME",@"MD",@"MA",@"MI",@"MN",@"MS",@"MO",@"MT",@"NV",@"NH",@"NJ",@"NM",@"NY",@"NC",@"ND",@"OH",@"OK",@"OR",@"PA",@"RI",@"SC",@"SD",@"TN",@"TX",@"UT",@"VT",@"VA",@"WA",@"WV",@"WI",@"WY",@"AS",@"GU",@"MP",@"PR",@"VI"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}
#pragma mark - IBAction methods
- (IBAction)save:(UIButton *)sender {
    if ([self.stateBtn.currentTitle isEqualToString:@"Please Select Your State"]) {
        [MyEUtil showMessageOn:nil withMessage:@"Please select Your State"];
    }
    for (UITextField *t in self.view.subviews) {
        if ([t isKindOfClass:[UITextField class]]) {
            if ([t.text isEqualToString:@""]) {
                [MyEUtil showMessageOn:nil withMessage:@"Please Enter All Info"];
                return;
            }
        }
    }
    [self uploadOrDownloadInfoFromServerWithURL:[NSString stringWithFormat:@"%@?state=%@&city=%@&street=%@&mediatorBindFlag=%i",GetRequst(URL_FOR_ADD_ADDRESS),self.stateBtn.currentTitle,self.txtCity.text,self.txtStreet.text,self.bindBtn.selected] andName:@"addHouse"];
}
- (IBAction)bindMediator:(UIButton *)sender {
    sender.selected = !sender.selected;
}
- (IBAction)dismissVC:(UIBarButtonItem *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (IBAction)changeState:(UIButton *)sender {
    if (!_picker) {
        _picker = [[MYEPickerView alloc] initWithView:self.view andTag:100 title:@"Select State" dataSource:_data andSelectRow:0];
    }
    _picker.delegate = self;
    [_picker showInView:self.view];
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
        [self uploadOrDownloadInfoFromServerWithURL:[NSString stringWithFormat:@"%@?state=%@&city=%@&street=%@&mediatorBindFlag=%i",GetRequst(URL_FOR_ADD_ADDRESS),self.stateBtn.currentTitle,self.txtCity.text,self.txtStreet.text,self.bindBtn.selected] andName:@"addHouse"];
    }
}
#pragma mark - MYEPickerView delegate methods
-(void)MYEPickerView:(UIView *)pickerView didSelectTitles:(NSString *)title andRow:(NSInteger)row{
    [self.stateBtn setTitle:title forState:UIControlStateNormal];
}
@end
