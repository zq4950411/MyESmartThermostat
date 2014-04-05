//
//  NSMutableDictionary+Safe.m
//  明信片
//
//  Created by space bj on 12-11-15.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "NSMutableDictionary+Safe.h"

@implementation NSMutableDictionary (Safe)

- (void) safeSetObject:(id)anObject forKey:(id)aKey
{
    if (anObject == nil) 
    {
        NSLog(@"%@ is null",aKey);
    }
    else
    {
        [self setObject:anObject forKey:aKey];
    }
}

@end
