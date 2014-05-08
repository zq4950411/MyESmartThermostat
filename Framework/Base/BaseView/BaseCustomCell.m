//
//  BaseCustomCell.m
//  FinalFantasy
//
//  Created by space bj on 12-4-16.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "BaseCustomCell.h"
#import "Utils.h"

@implementation BaseCustomCell

@synthesize headURLString;
@synthesize headButton;
@synthesize userLabel;
@synthesize dateLabel;
@synthesize headImageView;

@synthesize object;

@synthesize currentOriention;


-(void) prepareForReuse
{
    self.headImageView.image = nil;
}


+ (CGFloat)heightWithObject:(id) object
{
    return 0.0;
}

-(void) dealloc
{
    CLog(@"内存释放 Class = %@",[[self class] description]);
    [headURLString release];
    [headButton release];
    [userLabel release];
    [dateLabel release];
    [headImageView release];
    [object release];
    
    [super dealloc];
}

@end
