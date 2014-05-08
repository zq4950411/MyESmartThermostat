//
//  SwitchButton.m
//  DouMiJie
//
//  Created by space bj on 12-5-17.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "SwitchButton.h"

@implementation SwitchButton

-(void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self];
    if (point.x <= self.frame.size.width / 2) 
    {
        if (!self.selected) 
        {
            return;
        }
    }
    else
    {
        if (self.selected) 
        {
            return;
        }
    }
    [super touchesBegan:touches withEvent:event];
}

//-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
//{    
//    UITouch *touch = [touches anyObject];
//    CGPoint point = [touch locationInView:self];
//    if (point.x <= self.frame.size.width / 2) 
//    {
//        if (!self.selected) 
//        {
//            return;
//        }
//    }
//    else
//    {
//        if (self.selected) 
//        {
//            return;
//        }
//    }
//    [super touchesBegan:touches withEvent:event];
//}

@end
