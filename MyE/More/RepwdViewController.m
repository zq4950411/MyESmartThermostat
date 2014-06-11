//
//  RepwdViewController.m
//  MyE
//
//  Created by space on 13-9-9.
//  Copyright (c) 2013年 MyEnergy Domain. All rights reserved.
//

#import "RepwdViewController.h"


@implementation RepwdViewController

@synthesize pwd;
@synthesize nowPwd;
@synthesize renewPwd;
@synthesize okButton;



-(BOOL) textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}


-(void)didReceiveString:(NSString *)string loaderName:(NSString *)name userDataDictionary:(NSDictionary *)dict{
    NSLog(@"receive string is %@",string);
    if ([name isEqualToString:@"reset_password"]) {
        if ([@"OK" isEqualToString:string])
        {
            [SVProgressHUD showSuccessWithStatus:@"New password saved"];
        }
        else
        {
            [SVProgressHUD showSuccessWithStatus:@"Error"];
        }

    }
}
- (void) connection:(NSURLConnection *)connection didFailWithError:(NSError *)error loaderName:(NSString *)name{
    [SVProgressHUD showErrorWithStatus:@"Resetting password communication Error"];
}


-(IBAction) ok:(UIButton *) sender
{
    [self.pwd resignFirstResponder];
    [self.nowPwd resignFirstResponder];
    [self.renewPwd resignFirstResponder];
    
    if (![self.nowPwd.text isEqualToString:self.renewPwd.text])
    {
        UIAlertView *alert =[[UIAlertView alloc]initWithTitle:@"Warning"
                                                      message:@"New password doesn't match."
                                                     delegate:self
                                            cancelButtonTitle:@"Ok"
                                            otherButtonTitles:nil];
        [alert show];
        
        return;
    }
    else if([nowPwd.text length] < 6)
    {
        UIAlertView *alert =[[UIAlertView alloc]initWithTitle:@"Warning"
                                                      message:@"The password must have at least 6 characters."
                                                     delegate:self
                                            cancelButtonTitle:@"Ok"
                                            otherButtonTitles:nil];
        [alert show];
        
        return;
    }
    
    self.isShowLoading = YES;
    /* 彭辉原来采用BaseNetViewController的做法， 现在其网络请求出问题了，所以停止使用
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    
    [params setObject:pwd.text forKey:@"currentPassword"];
    [params setObject:nowPwd.text forKey:@"newPassword "];
    
    
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:params,REQUET_PARAMS, nil];
    
    [[NetManager sharedManager] requestWithURL:GetRequst(MORE_REPWD)
                                      delegate:self
                                  withUserInfo:dic];
    */

    [MyEDataLoader startLoadingWithURLString:[NSString stringWithFormat:@"%@?currentPassword=%@&newPassword=%@",GetRequst(MORE_REPWD),pwd.text, nowPwd.text] postData:nil delegate:self loaderName:@"reset_password" userDataDictionary:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [okButton setStyleType:ACPButtonOK];
    
    self.pwd.delegate = self;
    self.nowPwd.delegate = self;
    self.renewPwd.delegate = self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
