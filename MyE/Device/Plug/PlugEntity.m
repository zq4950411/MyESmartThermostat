//
//  PlugEntity.m
//  MyE
//
//  Created by space on 13-8-20.
//  Copyright (c) 2013年 MyEnergy Domain. All rights reserved.
//

#import "PlugEntity.h"

@implementation PlugEntity

@synthesize aliasName;
@synthesize locationId;
@synthesize locationList;
@synthesize maximalCurrent;
@synthesize realPower;
@synthesize startTime;
@synthesize surplusMinutes;
@synthesize switchStatus;
@synthesize timerSet;
@synthesize totalPower;
@synthesize locationName;

+(PlugEntity *) getPlug:(id) json
{
    NSDictionary *dic = [json JSONValue];
    
    PlugEntity *plug = [[PlugEntity alloc] init];
    
    plug.aliasName = [dic valueToStringForKey:@"aliasName"];
    plug.locationId = [dic valueToStringForKey:@"locationId"];
    plug.locationName = [dic valueToStringForKey:@"locationName"];
    plug.maximalCurrent = [dic valueToStringForKey:@"maximalCurrent"];
    plug.realPower = [dic valueToStringForKey:@"realPower"];
    plug.startTime = [dic valueToStringForKey:@"startTime"];
    plug.surplusMinutes = [dic valueToStringForKey:@"surplusMinutes"];
    plug.switchStatus = [dic valueToStringForKey:@"switchStatus"];
    plug.timerSet = [dic valueToStringForKey:@"timerSet"];
    plug.totalPower = [dic valueToStringForKey:@"totalPower"];
    
    NSArray *tempArray = [dic objectForKey:@"locationList"];
    plug.locationList = tempArray;
    
    return plug;
}

@end
