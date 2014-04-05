//
//  Sequential.m
//  MyE
//
//  Created by space on 13-8-26.
//  Copyright (c) 2013年 MyEnergy Domain. All rights reserved.
//

#import "Sequential.h"

@implementation Sequential

@synthesize locationId;
@synthesize seqName;

@synthesize startTime;
@synthesize repeatDays;
@synthesize precondition;
@synthesize weather_temperature;
@synthesize sequentialOrder;
@synthesize locationList;

+(Sequential *) getSequential:(id) json
{
    NSDictionary *tempDic = [json JSONValue];
    Sequential *seq = [[Sequential alloc] init];
    
    seq.startTime = [tempDic valueToStringForKey:@"startTime"];
    seq.repeatDays = [tempDic valueForKey:@"repeatDays"];
    seq.precondition = [tempDic valueToStringForKey:@"precondition"];
    seq.weather_temperature = [tempDic valueToStringForKey:@"weather_temperature"];
    seq.sequentialOrder = [NSMutableArray arrayWithArray:[tempDic valueForKey:@"sequentialOrder"]];
    
    seq.seqName = [tempDic valueForKey:@"name"];
    seq.locationId = [tempDic valueForKey:@"locationId"];
    seq.locationList = [tempDic valueForKey:@"locationList"];
    
    return seq;
}

@end
