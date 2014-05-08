//
//  ServerViewController.m
//  MyE
//
//  Created by space on 13-9-2.
//  Copyright (c) 2013年 MyEnergy Domain. All rights reserved.
//

#import "ServerViewController.h"
@implementation ServerViewController

@synthesize tf;

-(IBAction) close:(UIButton *) sender
{
    [tf resignFirstResponder];
    NSUserDefaults *uf = [NSUserDefaults standardUserDefaults];
    [uf setValue:[NSString stringWithFormat:@"%@",tf.text] forKey:@"IP"];
    [uf synchronize];
    
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    NSUserDefaults *uf = [NSUserDefaults standardUserDefaults];
    self.tf.text = [uf valueForKey:@"IP"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
