//
//  PopEditSceneViewController.h
//  MyE
//
//  Created by space on 13-10-7.
//  Copyright (c) 2013年 MyEnergy Domain. All rights reserved.
//

#import "BaseViewController.h"

@interface PopEditSceneViewController : BaseViewController <UITextFieldDelegate>
{
    CGFloat orginY;
    CGFloat toY;
    
    NSString *sceneName;
}

@property (nonatomic,strong) NSString *sceneName;

-(id) initWithSceneName:(NSString *) n;
-(IBAction) ok:(UIButton *) sender;

@end
