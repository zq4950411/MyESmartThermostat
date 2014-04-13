//
//  ScheduleEntity.m
//  MyE
//
//  Created by space on 13-8-21.
//  Copyright (c) 2013年 MyEnergy Domain. All rights reserved.
//

#import "ScheduleEntity.h"

@implementation ScheduleEntity

@synthesize scheduleId;
@synthesize periods;
@synthesize weekdays;
@synthesize autoMode;

+(NSMutableArray *) getSchedules:(id) json
{
    NSDictionary *tempDic = [json JSONValue];
    NSMutableArray *retArray = [NSMutableArray arrayWithCapacity:0];
    
    NSString *tempMode = [tempDic objectForKey:@"autoMode"];
    NSArray *tempArray = [tempDic objectForKey:@"schedules"];
    for (int i = 0; i < tempArray.count; i++)
    {
        NSDictionary *tempDic2 = [tempArray objectAtIndex:i];
        ScheduleEntity *temp = [[ScheduleEntity alloc] init];
        
        temp.periods = [tempDic2 objectForKey:@"periods"];
        temp.weekdays = [tempDic2 objectForKey:@"weekDays"];
        temp.scheduleId = [tempDic2 objectForKey:@"scheduleId"];
        temp.autoMode = tempMode;
        
        [retArray addObject:temp];
    }
    return retArray;
}

@end
