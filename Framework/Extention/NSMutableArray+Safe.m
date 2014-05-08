//
//  NSMutableArray+NSMutableArray_Safe.m
//  明信片
//
//  Created by space bj on 12-12-2.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "NSMutableArray+Safe.h"

@implementation NSMutableArray (Safe)

-(id) safeObjectAtIndex:(int) index
{
    if (self.count > index) 
    {
        return [self objectAtIndex:index];
    }
    else
    {
        return nil;
    }
}

-(void) safeRemovetAtIndex:(int) index
{
    if (self.count > index) 
    {
        [self removeObjectAtIndex:index];
    }
    else
    {
        return ;
    }
}

-(void) safeReplaceObjectAtIndex:(int) index withObject:(id) object
{
    if (self.count > index) 
    {
        return [self replaceObjectAtIndex:index withObject:object];
    }
    else
    {
        return ;
    }
}

@end
