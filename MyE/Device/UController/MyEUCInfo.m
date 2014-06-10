//
//  MyEUCInfo.m
//  MyE
//
//  Created by 翟强 on 14-6-6.
//  Copyright (c) 2014年 MyEnergy Domain. All rights reserved.
//

#import "MyEUCInfo.h"

@implementation MyEUCInfo

@end

@implementation MyEUCManual

-(MyEUCManual *)initWithJsonString:(NSString *)string{
    NSDictionary *dic = [string JSONValue];
    MyEUCManual *manual = [[[self class] alloc] initWithDictionary:dic];
    return manual;
}
-(MyEUCManual *)initWithDictionary:(NSDictionary *)dic{
    if (self = [super init]) {
        self.channels = dic[@"channels"];
    }
    return self;
}
-(NSString *)changeStringAtIndex:(NSInteger)index byString:(NSString *)str{
    NSMutableString *string = [NSMutableString stringWithString:self.channels];
    [string replaceCharactersInRange:NSMakeRange(index, 1) withString:str];
    return string;
}
@end

@implementation MyEUCAuto

-(MyEUCAuto *)initWithJsonString:(NSString *)string{
    NSArray *array = [string JSONValue];
    MyEUCAuto *uc = [[MyEUCAuto alloc] initWithArray:array];
    return uc;
}
-(MyEUCAuto *)initWithArray:(NSArray *)array{
    if (self = [super init]) {
        self.lists = [NSMutableArray array];
        for (NSDictionary *d in array) {
            [self.lists addObject:[[MyEUCSchedule alloc] initWithDictionary:d]];
        }
    }
    return self;
}

@end

@implementation MyEUCSchedule
-(id)init{
    if (self = [super init]) {
        self.scheduleId = -1;  //这个是接口指定的
        self.channels = @"";
        self.weeks = [NSMutableArray array];
        self.periods = [NSMutableArray array];
    }
    return self;
}
-(MyEUCSchedule *)initWithDictionary:(NSDictionary *)dic{
    if (self = [super init]) {
        self.scheduleId = [dic[@"scheduleId"] intValue];
        self.weeks = [NSMutableArray array];
        for (NSNumber *i in dic[@"weekly_day"]) {
            [self.weeks addObject:i];
        }
        self.channels = dic[@"channels"];
        self.periods = [NSMutableArray array];
        for (NSDictionary *d in dic[@"periodids"]) {
            [self.periods addObject:[[MyEUCPeriod alloc] initWithDictionary:d]];
        }
    }
    return self;
}
-(NSString *)getWeeks{
    NSArray *array = @[@"Mon",@"Tues",@"Wed",@"Thur",@"Fri",@"Sat",@"Sun"];
    NSMutableArray *week = [NSMutableArray array];
    for (NSNumber *i in self.weeks) {
        [week addObject:array[i.intValue]];
    }
    NSLog(@"string is %@",[week componentsJoinedByString:@" "]);
    return [week componentsJoinedByString:@" "];
}
-(NSString *)getChannels{
    NSMutableArray *array = [NSMutableArray array];
    NSString *string = nil;
    for (int i = 0; i < self.channels.length; i++) {
        string = [self.channels substringWithRange:NSMakeRange(i, 1)];
        if (string.intValue == 1) {
            [array addObject:@(i)];
        }
    }
    NSLog(@"channels is %@",[array componentsJoinedByString:@","]);
    return [array componentsJoinedByString:@","];
}
-(NSString *)jsonSchedule{
    SBJsonWriter *writer = [[SBJsonWriter alloc] init];
    NSDictionary *dic = @{@"periods": self.periods,
                          @"weekly_day":self.weeks,
                          @"channels":self.channels};
    NSDictionary *mainDic = @{@"schedules": dic};
    NSString *string = [writer stringWithObject:mainDic];
    NSLog(@"string is %@",string);
    return string;
}
-(id)copyWithZone:(NSZone *)zone{
    MyEUCSchedule *schedule = [[[self class] allocWithZone:zone] init];
    schedule.scheduleId = self.scheduleId;
    schedule.weeks = [self.weeks mutableCopy];
    schedule.channels = self.channels;
    schedule.periods = [self.periods mutableCopy];
    return schedule;
}
@end

@implementation MyEUCPeriod
-(id)init{
    if (self = [super init]) {
        self.stid = 23;
        self.edid = 24;
    }
    return self;
}
-(MyEUCPeriod *)initWithDictionary:(NSDictionary *)dic{
    if (self = [super init]) {
        self.stid = [dic[@"stid"] intValue];
        self.edid = [dic[@"edid"] intValue];
    }
    return self;
}
-(id)copyWithZone:(NSZone *)zone{
    MyEUCPeriod *period = [[[self class] allocWithZone:zone] init];
    period.stid = self.stid;
    period.edid = self.edid;
    return period;
}
@end

@implementation MyEUCSequential

-(MyEUCSequential *)initWithJsonString:(NSString *)string{
    NSDictionary *dic = [string JSONValue];
    MyEUCSequential *seque = [[MyEUCSequential alloc] initWithDictionary:dic];
    return seque;
}
-(MyEUCSequential *)initWithDictionary:(NSDictionary *)dic{
    if (self = [super init]) {
        self.startTime = dic[@"startTime"];
        self.preConditon = [dic[@"precondition"] intValue];
        self.weeks = [NSMutableArray array];
        for (NSNumber *i in dic[@"repeatDays"]) {
            [self.weeks addObject:i];
        }
        self.temperature = [dic[@"weather_temperature"] intValue];
        self.sequentialOrder = [NSMutableArray array];
        for (NSDictionary *d in dic[@"sequentialOrder"]) {
            [self.sequentialOrder addObject:[[MyEUCChannelInfo alloc] initWithDictionary:d]];
        }
    }
    return self;
}
-(NSString *)jsonSequential{
    SBJsonWriter *writer = [[SBJsonWriter alloc] init];
    NSDictionary *dic = @{@"startTime": self.startTime,
                          @"repeatDays":self.weeks,
                          @"precondition":@(self.preConditon),
                          @"weather_temperature":@(self.temperature),
                          @"sequentialOrder":self.sequentialOrder};
    NSDictionary *mainDic = @{@"control": dic};
    NSString *string = [writer stringWithObject:mainDic];
    NSLog(@"string is %@",string);
    return string;
}
-(NSArray *)conditionArray{
    return @[@"None",@"If Snow",@"If Rain",@"If No Rain",@"If Sunny",@"If Temperature >=",@"If Temperature <="];
}
-(NSString *)description{
    return [NSString stringWithFormat:@"\nstartTime:%@\nweeks:%@\ncondition:%i\ntem:%i\norder:%@",self.startTime,[self.weeks componentsJoinedByString:@","],self.preConditon,self.temperature,self.sequentialOrder];
}
@end


@implementation MyEUCChannelInfo
-(id)init{
    if (self = [super init]) {
        self.channel = 1;
        self.duration = 5;
        self.orderId = -1;
    }
    return self;
}
-(MyEUCChannelInfo *)initWithDictionary:(NSDictionary *)dic{
    if (self = [super init]) {
        self.channel = [dic[@"channel"] intValue];
        self.duration = [dic[@"duration"] intValue];
        self.orderId = [dic[@"orderId"] intValue];
    }
    return self;
}
-(id)copyWithZone:(NSZone *)zone{
    MyEUCChannelInfo *info = [[[self class] allocWithZone:zone] init];
    info.channel = self.channel;
    info.duration = self.duration;
    info.orderId = self.orderId;
    return info;
}
-(NSString *)description{
    return [NSString stringWithFormat:@"channel:%i  duration:%i  orderId:%i",self.channel,self.duration,self.orderId];
}
@end