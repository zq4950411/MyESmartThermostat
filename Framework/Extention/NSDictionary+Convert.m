//
//  NSDictionary+Convert.m
//  MyE
//
//  Created by space on 13-8-19.
//  Copyright (c) 2013年 MyEnergy Domain. All rights reserved.
//

#import "NSDictionary+Convert.h"

@implementation NSDictionary (Convert)

-(NSString *) valueToStringForKey:(NSString *) key
{
    id value = [self objectForKey:key];
    if ([value isKindOfClass:[NSNull class]])
    {
        return nil;
    }
    else if([value isKindOfClass:[NSNumber class]])
    {
        return [NSString stringWithFormat:@"%d",[value intValue]];
    }
    else
    {
        return value;
    }
}


@end
