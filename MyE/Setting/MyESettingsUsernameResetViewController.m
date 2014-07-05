//
//  MyESettingsUsernameResetViewController.m
//  MyE
//
//  Created by 翟强 on 14-7-5.
//  Copyright (c) 2014年 MyEnergy Domain. All rights reserved.
//

#import "MyESettingsUsernameResetViewController.h"

@interface MyESettingsUsernameResetViewController ()

@end

@implementation MyESettingsUsernameResetViewController

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
    self.txtUsername.text = MainDelegate.accountData.userName;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.txtUsername becomeFirstResponder];
    });
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)saveEditor:(UIBarButtonItem *)sender {
    NSInteger i = self.txtUsername.text.length;
    if (i < 4 || i > 20) {
        [SVProgressHUD showErrorWithStatus:@"name length error!"];
        return;
    }
    [MyEDataLoader startLoadingWithURLString:[NSString stringWithFormat:@"%@?username=%@",GetRequst(URL_FOR_SETTINGS_RESET_USERNAME),self.txtUsername.text] postData:nil delegate:self loaderName:@"name" userDataDictionary:nil];
}

#pragma mark - URL delegate methods
-(void)didReceiveString:(NSString *)string loaderName:(NSString *)name userDataDictionary:(NSDictionary *)dict{
    if (![string isEqualToString:@"fail"]) {
        if ([string isEqualToString:@"OK"]) {
            MainDelegate.accountData.userName = self.txtUsername.text;
            [self.navigationController popViewControllerAnimated:YES];
        }else{
        NSInteger i = [[string JSONValue] intValue];
        if (i == 1) {
            [SVProgressHUD showErrorWithStatus:@"name length error!"];
        }else if (i == 2){
            [SVProgressHUD showErrorWithStatus:@"Username contains special characters"];
        }else
            [SVProgressHUD showErrorWithStatus:@"User name already exists"];
        }
    }else
        [SVProgressHUD showErrorWithStatus:@"fail"];
}
-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error loaderName:(NSString *)name{
    [SVProgressHUD showErrorWithStatus:@"Connection Fail"];
}
@end
