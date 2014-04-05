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




-(void) netFinish:(id) jsonString withUserInfo:(NSDictionary *) userInfo andURL:(NSString *) u
{
    if ([u rangeOfString:MORE_REPWD].location != NSNotFound)
    {
        if ([@"OK" isEqualToString:jsonString])
        {
            [SVProgressHUD showSuccessWithStatus:@"New password saved"];
        }
        else
        {
            [SVProgressHUD showSuccessWithStatus:@"Error"];
        }
        
        //[MainDelegate getLoginView];
    }
}

-(void) netError:(id)errorMsg withUserInfo:(NSDictionary *)userInfo andURL:(NSString *) u
{
    if ([u rangeOfString:MORE_NOTIFICATION].location != NSNotFound)
    {
        
    }
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
    
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    
    [params setObject:pwd.text forKey:@"currentPassword"];
    [params setObject:nowPwd.text forKey:@"newPassword "];
    
    
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:params,REQUET_PARAMS, nil];

    [[NetManager sharedManager] requestWithURL:GetRequst(MORE_REPWD)
                                      delegate:self
                                  withUserInfo:dic];  
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
