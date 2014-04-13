//
//  PopAddNewSceneViewController.m
//  MyE
//
//  Created by space on 13-8-23.
//  Copyright (c) 2013年 MyEnergy Domain. All rights reserved.
//

#import <CoreGraphics/CoreGraphics.h>

#import "PopAddNewSceneViewController.h"
#import "SceneViewController.h"
#import "UIViewController+KNSemiModal.h"

#import "JYTextField.h"
#import "NSString+Common.h"

@implementation PopAddNewSceneViewController

-(void) saveScene
{
    JYTextField *jtf = (JYTextField *)[self.view viewWithTag:100];
    [jtf resignFirstResponder];
    
    if ([jtf.text isBlank])
    {
        [SVProgressHUD showErrorWithStatus:@"Please specify the name of the scene"];
        return;
    }
    
    UIButton *button1 = (UIButton *)[self.view viewWithTag:10];
    UIButton *button2 = (UIButton *)[self.view viewWithTag:11];
    NSString *type = @"0";
    
    if (button1.selected)
    {
        type = @"1";
    }
    else if(button2.selected)
    {
        type = @"2";
    }
    
    SceneViewController *sceneVc = (SceneViewController *)parentVC;
    [sceneVc addSceneWithName:jtf.text andMode:type];
}

-(IBAction) next:(id) sender
{
    [self saveScene];
}

-(IBAction) cancel:(id) sender
{
    SceneViewController *sceneVc = (SceneViewController *)parentVC;
    [sceneVc dimissView];
}

-(IBAction) buttonClick:(UIButton *) sender
{
    UIButton *button1 = (UIButton *)[self.view viewWithTag:10];
    button1.selected = NO;
    
    UIButton *button2 = (UIButton *)[self.view viewWithTag:11];
    button2.selected = NO;
    
    UIButton *button3 = (UIButton *)[self.view viewWithTag:20];
    
    ((UIButton *)sender).selected = YES;
    
    if (sender.tag == 11)
    {
        [button3 setTitle:@"Done" forState:UIControlStateNormal];
    }
    else
    {
        [button3 setTitle:@"Next" forState:UIControlStateNormal];
    }
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
