//
//  MyESettingsPasswordResetViewController.m
//  MyE
//
//  Created by 翟强 on 14-6-17.
//  Copyright (c) 2014年 MyEnergy Domain. All rights reserved.
//

#import "MyESettingsPasswordResetViewController.h"

@interface MyESettingsPasswordResetViewController ()

@end

@implementation MyESettingsPasswordResetViewController

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
    self.pwd.delegate = self;
    self.nowPwd.delegate = self;
    self.renewPwd.delegate = self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}
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
            [self.navigationController popViewControllerAnimated:YES];
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


-(IBAction) ok:(UIBarButtonItem *) sender
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
    else if([_nowPwd.text length] < 6)
    {
        UIAlertView *alert =[[UIAlertView alloc]initWithTitle:@"Warning"
                                                      message:@"The password must have at least 6 characters."
                                                     delegate:self
                                            cancelButtonTitle:@"Ok"
                                            otherButtonTitles:nil];
        [alert show];
        
        return;
    }

    [MyEDataLoader startLoadingWithURLString:[NSString stringWithFormat:@"%@?currentPassword=%@&newPassword=%@",GetRequst(MORE_REPWD),_pwd.text, _nowPwd.text] postData:nil delegate:self loaderName:@"reset_password" userDataDictionary:nil];
}
@end
