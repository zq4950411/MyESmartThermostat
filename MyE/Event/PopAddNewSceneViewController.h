//
//  PopAddNewSceneViewController.h
//  MyE
//
//  Created by space on 13-8-23.
//  Copyright (c) 2013年 MyEnergy Domain. All rights reserved.
//

#import "BaseViewController.h"

@interface PopAddNewSceneViewController : BaseViewController <UITextFieldDelegate>
{
    CGFloat orginY;
    CGFloat toY;
}

-(IBAction) next:(id) sender;
-(IBAction) cancel:(id) sender;
-(IBAction) buttonClick:(UIButton *) sender;

@end
