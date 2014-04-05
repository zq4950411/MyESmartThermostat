//
//  BaseView.m
//  EZFM
//
//  Created by space bj on 13-4-19.
//  Copyright (c) 2013年 __MyCompanyName__. All rights reserved.
//

#import "BaseView.h"

@implementation BaseView

@synthesize object;


-(void) dealloc
{
    self.object = nil;
    [super dealloc];
}

@end
