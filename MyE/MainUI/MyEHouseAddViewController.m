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
}

@end

@implementation MyEHouseAddViewController

#pragma mark - life circle methods
- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}
#pragma mark - IBAction methods
- (IBAction)save:(UIButton *)sender {
    for (UITextField *t in self.view.subviews) {
        if ([t isKindOfClass:[UITextField class]]) {
            if ([t.text isEqualToString:@""]) {
                [MyEUtil showMessageOn:nil withMessage:@"Please Enter All Info"];
                return;
            }
        }
    }
    [self uploadOrDownloadInfoFromServerWithURL:[NSString stringWithFormat:@"%@?state=%@&city=%@&street=%@&mediatorBindFlag=%i",GetRequst(URL_FOR_ADD_ADDRESS),self.txtState.text,self.txtCity.text,self.txtStreet.text,self.bindBtn.selected] andName:@"addHouse"];
}
- (IBAction)bindMediator:(UIButton *)sender {
    sender.selected = !sender.selected;
}
- (IBAction)dismissVC:(UIBarButtonItem *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
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
            hlvc.accountData = self.accountData;
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
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (alertView.tag == 100 && buttonIndex == 1) {
        [self uploadOrDownloadInfoFromServerWithURL:[NSString stringWithFormat:@"%@?state=%@&city=%@&street=%@&mediatorBindFlag=%i",GetRequst(URL_FOR_ADD_ADDRESS),self.txtState.text,self.txtCity.text,self.txtStreet.text,self.bindBtn.selected] andName:@"addHouse"];
    }
}
@end
