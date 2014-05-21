//
//  MyESocketInfo.m
//  MyE
//
//  Created by 翟强 on 14-4-25.
//  Copyright (c) 2014年 MyEnergy Domain. All rights reserved.
//

#import "MyESocketInfo.h"

@implementation MyESocketInfo

-(MyESocketInfo *)initWithJSONString:(NSString *)string{
    NSDictionary *dic = [string JSONValue];
    MyESocketInfo *info = [[MyESocketInfo alloc] initWithDic:dic];
    return info;
}
-(MyESocketInfo *)initWithDic:(NSDictionary *)dic{
    if (self = [super init]) {
        self.name = dic[@"name"];
        self.tIdName = dic[@"t_aliasName"];
        self.locationId = [dic[@"localtionId"] intValue];
        self.maxCurrent = [dic[@"maxCurrent"] intValue];
        return self;
    }
    return nil;
}

@end

@implementation MyESocketControlInfo
-(MyESocketControlInfo *)initWithJSONString:(NSString *)string{
    NSDictionary *dic = [string JSONValue];
    MyESocketControlInfo *info = [[MyESocketControlInfo alloc] initWithDic:dic];
    return info;
}
-(MyESocketControlInfo *)initWithDic:(NSDictionary *)dic{
    if (self = [super init]) {
        self.name = dic[@"aliasName"];
        self.currentPower = [dic[@"realPower"] intValue];
        self.startTime = dic[@"startTime"];
        self.totalPower = [dic[@"totalPower"] intValue];
        self.surplusMinutes = [dic[@"surplusMinutes"] intValue];
        self.switchStatus = dic[@"switchStatus"]==[NSNull null]?0: [dic[@"switchStatus"] intValue];
        self.timeSet = [dic[@"timerSet"] intValue];
        self.maxCurrent = [dic[@"maximalCurrent"] intValue];
        self.locationId = [dic[@"locationId"] intValue];
        return self;
    }
    return nil;
}
@end

@implementation MyESocketSchedules

-(MyESocketSchedules *)initWithJSONString:(NSString *)string{
    NSDictionary *dic = [string JSONValue];
    MyESocketSchedules *scedules = [[MyESocketSchedules alloc] initWithDic:dic];
    return scedules;
}
-(MyESocketSchedules *)initWithDic:(NSDictionary *)dic{
    if (self = [super init]) {
        self.schedules = [NSMutableArray array];
        for (NSDictionary *d in dic[@"SSList"]) {
            [self.schedules addObject:[[MyESocketSchedule alloc] initWithDic:d]];
        }
        return self;
    }
    return nil;
}
@end

@implementation MyESocketSchedule
-(id)init{
    if (self = [super init]) {
        self.weeks = [NSMutableArray array];
        self.scheduleId = 0;
        self.onTime = @"11:00";  //这里的初始值用于btn的显示
        self.offTime = @"12:00";
        self.runFlag = 0;
    }
    return self;
}
-(MyESocketSchedule *)initWithDic:(NSDictionary *)dic{
    if (self = [super init]) {
        self.weeks = [NSMutableArray array];
        for (NSNumber *n in dic[@"weeks"]) {
            [self.weeks addObject:n];
        }
        self.scheduleId = [dic[@"scheduleId"] intValue];
        self.onTime = dic[@"onTime"];
        self.offTime = dic[@"offTime"];
        self.runFlag = [dic[@"runFlag"] intValue];
        return self;
    }
    return nil;
}
-(id)copyWithZone:(NSZone *)zone{
    MyESocketSchedule *schedule = [[[self class] allocWithZone:zone] init];
    schedule.weeks = self.weeks;
    schedule.scheduleId = self.scheduleId;
    schedule.onTime = self.onTime;
    schedule.offTime = self.offTime;
    schedule.runFlag = self.runFlag;
    return schedule;
}
-(NSString *)description{
    return [NSString stringWithFormat:@"%i %@ %@ %@ %i",self.scheduleId,self.onTime,self.offTime,[self.weeks componentsJoinedByString:@","],self.runFlag];
}
@end