//
//  ServerUtils.m
//  MyE
//
//  Created by space on 13-9-2.
//  Copyright (c) 2013年 MyEnergy Domain. All rights reserved.
//

#import "ServerUtils.h"

@implementation ServerUtils

+(NSString *) getServierIp
{
    NSUserDefaults *uf = [NSUserDefaults standardUserDefaults];
    NSString *string = [uf valueForKey:@"IP"];
    if (string == nil)
    {
        string = @"htttp://www.myenergydomain.com";
    }
    return string;
}

@end
