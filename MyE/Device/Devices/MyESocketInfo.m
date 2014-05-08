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
        self.name = dic[@"aliasName"];
        self.currentPower = [dic[@"realPower"] intValue];
        self.startTime = dic[@"startTime"];
        self.totalPower = [dic[@"totalPower"] intValue];
        self.surplusMinutes = [dic[@"surplusMinutes"] intValue];
        self.switchStatus = [dic[@"switchStatus"] intValue];
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
        self.autoMode = [dic[@"autoMode"] intValue];
        self.schedules = [NSMutableArray array];
        for (NSDictionary *d in dic[@"schedules"]) {
            [self.schedules addObject:[[MyESocketSchedule alloc] initWithDic:d]];
        }
        return self;
    }
    return nil;
}
@end

@implementation MyESocketSchedule

-(MyESocketSchedule *)initWithDic:(NSDictionary *)dic{
    if (self = [super init]) {
        self.periods = [NSMutableArray array];
        self.weeks = [NSMutableArray array];
        for (NSDictionary *d in dic[@"periods"]) {
            [self.periods addObject:[[MyESocketPeriod alloc] initWithDic:d]];
        }
        for (NSNumber *n in dic[@"weekDays"]) {
            [self.weeks addObject:n];
        }
        self.scheduleId = [dic[@"scheduleId"] intValue];
        return self;
    }
    return nil;
}

@end

@implementation MyESocketPeriod

-(MyESocketPeriod *)initWithDic:(NSDictionary *)dic{
    if (self = [super init]) {
        self.stid = [dic[@"stid"] intValue];
        self.etid = [dic[@"etid"] intValue];
        return self;
    }
    return nil;
}

@end