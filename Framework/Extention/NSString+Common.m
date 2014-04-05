//
//  NSString+Common.m
//  MyE
//
//  Created by space on 13-8-19.
//  Copyright (c) 2013年 MyEnergy Domain. All rights reserved.
//

#import "NSString+Common.h"

@implementation NSString (Common)

-(BOOL) isBlank
{
    if ([self nilValue])
    {
        return YES;
    }
    if ([self isKindOfClass:[NSString class]])
    {
        NSString *temp = [self nonBlankString];
        return [temp isEqualToString:@""];
    }
    return YES;
}

-(BOOL) nilValue
{
    if ([self isKindOfClass:[NSNull class]])
    {
        return YES;
    }
    else
    {
        return NO;
    }
}

-(NSString *) nonBlankString
{    
    return [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];;
}

-(NSString *) intStringToWeekString
{
    switch (self.intValue)
    {
        case 0:
            return @"Mon";
        case 1:
            return @"The";
        case 2:
            return @"Wed";
        case 3:
            return @"Thu";
        case 4:
            return @"Fri";
        case 5:
            return @"Sat";
        case 6:
            return @"Sun";
        default:
            break;
    }
    return @"";
}

-(NSString *) conditiontoString:(int) i
{
    switch (i)
    {
        case 0:
            return @"None";
        case 1:
            return @"If snow";
        case 2:
            return @"If rain";
        case 3:
            return @"If no rain";
        case 4:
            return @"If sunny";
        case 5:
            return @"If the temperature >";
        case 6:
            return @"If the temperature <";
        default:
            break;
    }
    return @"";
}

-(int) stringToCondition:(NSString *) string
{
    if ([string isEqualToString:@"None"])
    {
        return 0;
    }
    else if ([string isEqualToString:@"If snow"])
    {
        return 1;
    }
    else if ([string isEqualToString:@"If rain"])
    {
        return 2;
    }
    else if ([string isEqualToString:@"If no rain"])
    {
        return 3;
    }
    else if ([string isEqualToString:@"If sunny"])
    {
        return 4;
    }
    else if ([string isEqualToString:@"If the temperature >w"])
    {
        return 5;
    }
    else if ([string isEqualToString:@"If the temperature <"])
    {
        return 6;
    }
    return 0;
}

+(NSString *) errorInfo:(NSString *) error
{
    return error;
}

-(BOOL) isChannel
{
    if (self.length != 6)
    {
        return NO;
    }
    for (int i = 0; i < self.length; i++)
    {
        char c = [self characterAtIndex:i];
        if (c != '0' && c!= '1')
        {
            return NO;
        }
    }
    
    return YES;
}

-(NSString *) safeReplaceString:(NSString *) s1 atIndex:(int) i
{
    if (i >= self.length)
    {
        return self;
    }
    
    NSRange range;
    range.location = i;
    range.length = 1;
    
    return [self stringByReplacingCharactersInRange:range withString:s1];
}

@end









