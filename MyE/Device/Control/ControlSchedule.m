//
//  ControlSchedule.m
//  MyE
//
//  Created by space on 13-8-26.
//  Copyright (c) 2013年 MyEnergy Domain. All rights reserved.
//

#import "ControlSchedule.h"
#import "NSString+Common.h"

@implementation ControlSchedule

@synthesize scheduleId;
@synthesize weekly_day;
@synthesize channels;
@synthesize periodids;

-(NSString *) getChannelString
{
    NSMutableString *sb = [NSMutableString string];
    [sb appendString:@"Channel "];
    
    BOOL b = NO;
    for (int i = 0; i < channels.length; i++)
    {
        NSString *channelString = [NSString stringWithFormat:@"%c",[channels characterAtIndex:i]];

        if (channelString.intValue == 1)
        {
            if (b)
            {
                [sb appendString:@","];
            }
            [sb appendString:[NSString stringWithFormat:@"%d",(i + 1)]];
            b = YES;
        }
    }
    return sb;
}
-(NSString *) getWeekString
{
    NSMutableString *sb = [NSMutableString string];
    for (int i = 0; i < weekly_day.count; i++)
    {
        if (i > 0)
        {
            [sb appendString:@"  "];
        }
        
        NSString *temp = [NSString stringWithFormat:@"%d",([[weekly_day objectAtIndex:i] intValue] - 1)];
        [sb appendString:[temp intStringToWeekString]];
    }
    
    return sb;
}

+(NSMutableArray *) getControlSchedules:(id) json
{
    NSMutableArray *retArray = [NSMutableArray arrayWithCapacity:0];
    
    NSArray *tempArray = [json JSONValue];
    for (int i = 0; i < tempArray.count; i++)
    {
        NSDictionary *tempDic2 = [tempArray objectAtIndex:i];
        ControlSchedule *temp = [[ControlSchedule alloc] init];
        
        temp.periodids = [tempDic2 objectForKey:@"periods"];
        temp.weekly_day = [tempDic2 objectForKey:@"weekly_day"];
        temp.scheduleId = [tempDic2 objectForKey:@"scheduleId"];
        temp.channels = [tempDic2 objectForKey:@"channels"];
        
        [retArray addObject:temp];
    }
    return retArray;
}

@end
