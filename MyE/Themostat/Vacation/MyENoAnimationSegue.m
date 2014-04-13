//
//  MyENoAnimationSegue.m
//  MyE
//
//  Created by Ye Yuan on 3/26/12.
//  Copyright (c) 2012 MyEnergy Domain. All rights reserved.
//

#import "MyENoAnimationSegue.h"

@implementation MyENoAnimationSegue
// 自定义segue的目的是使得vacation和staycation编辑面板之间的切换没有动画，
- (void) perform {
    
    UIViewController *src = (UIViewController *) self.sourceViewController;
    UIViewController *dst = (UIViewController *) self.destinationViewController;
    
    [UIView transitionWithView:src.navigationController.view duration:0.0
                       options:UIViewAnimationOptionTransitionNone
                    animations:^{
                        [src.navigationController pushViewController:dst animated:NO];
                    }
                    completion:NULL];
}

@end	
