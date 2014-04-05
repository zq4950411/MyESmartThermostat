//  NSDictionary+JSONNSNull.m
//
//  Created by Matthew McFarling on 12/7/12.
//  Copyright (c) 2012 Matthew McFarling. All rights reserved.
//

#import "NSDictionary+JSONNSNull.h"

@implementation NSDictionary (JSONNSNull)

-(id) valueForKeyPathNotNull:(NSString *) path
{
    id object = [self objectForKey:path];
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