//
//  NSDictionary+Extentioin.m
//  团购
//
//  Created by space bj on 13-2-28.
//  Copyright (c) 2013年 __MyCompanyName__. All rights reserved.
//

#import "NSDictionary+Extention.h"

@implementation NSDictionary (Extention)

-(id) safeObjectForKey:(NSString *) key
{
    id object = [self objectForKey:key];
    if ([object isKindOfClass:[NSNull class]]) 
    {
        return nil;
    }
    else
    {
        return object;
    }
}

@end
