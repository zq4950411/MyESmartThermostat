//
//  ServerViewController.h
//  MyE
//
//  Created by space on 13-9-2.
//  Copyright (c) 2013年 MyEnergy Domain. All rights reserved.
//

#import "BaseViewController.h"

@interface ServerViewController : BaseViewController
{
    UITextField *tf;
}

@property (nonatomic,strong) IBOutlet UITextField *tf;

-(IBAction) close:(UIButton *) sender;

@end
