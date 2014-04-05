//
//  SmartUp.m
//  MyE
//
//  Created by space on 13-8-8.
//  Copyright (c) 2013年 MyEnergy Domain. All rights reserved.
//

#import "SmartUp.h"

@implementation SmartUp

@synthesize deviceId;
@synthesize deviceName;
@synthesize switchStatus;

@synthesize typeId;
@synthesize typeName;

@synthesize tid;
@synthesize tidName;

@synthesize rfStatus;
@synthesize sortId;

@synthesize locationId;
@synthesize locationName;

@synthesize isExpand;

+(NSMutableArray *) devices:(id) json
{
    NSArray *array = (NSArray *)[(NSString *)json JSONValue];
    if ([array isKindOfClass:[NSArray class]])
    {
        NSMutableArray *retArray = [NSMutableArray arrayWithCapacity:0];
        for (int i = 0; i < array.count;i++)
        {
            NSDictionary *tempDic = (NSDictionary *)[array objectAtIndex:i];
            
            SmartUp *temp = [[SmartUp alloc] init];
            
            temp.deviceId = [tempDic valueToStringForKey:@"deviceId"];
            temp.deviceName = [tempDic valueToStringForKey:@"deviceName"];
            temp.switchStatus = [tempDic valueToStringForKey:@"switchStatus"];
            temp.typeId = [NSString stringWithFormat:@"%d",[[tempDic valueToStringForKey:@"typeId"] intValue]];
            temp.tid = [NSString stringWithFormat:@"%@",[tempDic valueToStringForKey:@"tid"]];
            temp.rfStatus = [tempDic valueToStringForKey:@"rfStatus"];
            temp.sortId = [NSString stringWithFormat:@"%d",[[tempDic valueToStringForKey:@"sortId"] intValue]];
            temp.locationName = [tempDic valueToStringForKey:@"locationName"];
            
            [retArray addObject:temp];
        }
        return retArray;
    }
    else
    {
        return nil;
    }
}





@end
