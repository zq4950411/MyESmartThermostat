//
//  ScheduleEntity.h
//  MyE
//
//  Created by space on 13-8-21.
//  Copyright (c) 2013年 MyEnergy Domain. All rights reserved.
//

#import "BaseObject.h"

@interface ScheduleEntity : BaseObject
{
    NSString *scheduleId;
    NSArray *periods;
    NSArray *weekdays;
    NSString *autoMode;
}

@property (nonatomic,strong) NSString *scheduleId;
@property (nonatomic,strong) NSArray *periods;
@property (nonatomic,strong) NSArray *weekdays;
@property (nonatomic,strong) NSString *autoMode;

+(NSMutableArray *) getSchedules:(id) json;

@end
