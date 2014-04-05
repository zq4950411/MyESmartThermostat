//
//  RepwdViewController.h
//  MyE
//
//  Created by space on 13-9-9.
//  Copyright (c) 2013年 MyEnergy Domain. All rights reserved.
//

#import "BaseNetViewController.h"
#import "ACPButton.h"

@interface RepwdViewController : BaseNetViewController <UITextFieldDelegate>
{
    UITextField *pwd;
    UITextField *nowPwd;
    UITextField *renewPwd;
    
    ACPButton *okButton;
}

@property (nonatomic,strong) IBOutlet UITextField *pwd;
@property (nonatomic,strong) IBOutlet UITextField *nowPwd;
@property (nonatomic,strong) IBOutlet UITextField *renewPwd;

@property (nonatomic,strong) IBOutlet ACPButton *okButton;

-(IBAction) ok:(UIButton *) sender;

@end
