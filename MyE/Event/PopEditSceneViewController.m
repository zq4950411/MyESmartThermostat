//
//  PopEditSceneViewController.m
//  MyE
//
//  Created by space on 13-10-7.
//  Copyright (c) 2013年 MyEnergy Domain. All rights reserved.
//

#import "PopEditSceneViewController.h"
#import "SceneDeviceViewController.h"

#import "JYTextField.h"


@implementation PopEditSceneViewController

@synthesize sceneName;

-(id) initWithSceneName:(NSString *) n
{
    if (self = [super init])
    {
        self.sceneName = n;
    }
    
    return self;
}

-(void) saveScene
{
    JYTextField *jtf = (JYTextField *)[self.view viewWithTag:100];
    [jtf resignFirstResponder];
    
    if ([jtf.text isBlank])
    {
        [SVProgressHUD showErrorWithStatus:@"Please specify the name of the scene"];
        return;
    }
    
    
    if ([jtf.text isEqualToString:sceneName])
    {
        return;
    }
    
    SceneDeviceViewController *deviceVc = (SceneDeviceViewController *)parentVC;
    [deviceVc editSceneName:jtf.text];
}


-(IBAction) ok:(UIButton *) sender
{
    [self saveScene];
}






-(void) textFieldDidBeginEditing:(UITextField *)textField
{
    [UIView animateWithDuration:0.3 animations:^{
        self.view.top = toY;
    }];
}


-(void) textFieldDidEndEditing:(UITextField *)textField
{
    textField.borderStyle = UITextBorderStyleLine;
    [UIView animateWithDuration:0.3 animations:^{
        self.view.top = orginY;
    }];
}

-(BOOL) textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    JYTextField *jtf = (JYTextField *)[self.view viewWithTag:100];
    [jtf setCornerRadio:5
            borderColor:RGB(166, 166, 166)
            borderWidth:2
             lightColor:RGB(55, 154, 255)
              lightSize:8
       ligthBorderColor:RGB(235, 235, 235)
     ];
    jtf.text = sceneName;
    
    orginY = [[UIScreen mainScreen] bounds].size.height - self.view.height;
    toY = [[UIScreen mainScreen] bounds].size.height - 216 - self.view.height;
    
    self.view.layer.cornerRadius = 5.0f;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
