//
//  ControlSchedule.h
//  MyE
//
//  Created by space on 13-8-26.
//  Copyright (c) 2013年 MyEnergy Domain. All rights reserved.
//

#import "BaseObject.h"

@interface ControlSchedule : BaseObject
{
    NSString *scheduleId;
    NSArray *weekly_day;
    NSString *channels;
    NSArray *periodids;
}

@property (nonatomic,strong) NSString *scheduleId;
@property (nonatomic,strong) NSArray *weekly_day;
@property (nonatomic,strong) NSString *channels;
@property (nonatomic,strong) NSArray *periodids;

+(NSMutableArray *) getControlSchedules:(id) json;

-(NSString *) getChannelString;
-(NSString *) getWeekString;

@end
