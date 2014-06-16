//
//  MyESwitchAutoControl.m
//  MyEHomeCN2
//
//  Created by 翟强 on 14-3-3.
//  Copyright (c) 2014年 My Energy Domain Inc. All rights reserved.
//

#import "MyESwitchAutoControl.h"

@implementation MyESwitchAutoControl
-(MyESwitchAutoControl *)initWithString:(NSString *)string{
    SBJsonParser *parser = [[SBJsonParser alloc] init];
    NSDictionary *dic = [parser objectWithString:string];
    MyESwitchAutoControl *control = [[MyESwitchAutoControl alloc] initWithDic:dic];
    return control;
}
-(MyESwitchAutoControl *)initWithDic:(NSDictionary *)dic{
    if (self = [super init]) {
        self.numChannel = [dic[@"numChannel"] intValue];
        NSMutableArray *schedules = [NSMutableArray array];
        NSArray *array = dic[@"SSList"];
        for (NSDictionary *dict in array) {
            [schedules addObject:[[MyESwitchSchedule alloc] initWithDic:dict]];
        }
        self.SSList = schedules;
        return self;
    }
    return nil;
}
@end

@implementation MyESwitchSchedule
-(id)init{
    if (self = [super init]) {
        self.scheduleId = 0;
        self.onTime = @"12:00";
        self.offTime = @"12:30";
        self.channels = [NSMutableArray array];
        self.weeks = [NSMutableArray array];
        self.runFlag = 1;   //默认是启用的
    }
    return self;
}
-(MyESwitchSchedule *)initWithString:(NSString *)string{
    SBJsonParser *parser = [[SBJsonParser alloc] init];
    NSDictionary *dic = [parser objectWithString:string];
    MyESwitchSchedule *schedule = [[MyESwitchSchedule alloc] initWithDic:dic];
    return schedule;
}
-(MyESwitchSchedule *)initWithDic:(NSDictionary *)dic{
    if (self = [super init]) {
        if (dic[@"id"]) {
            self.scheduleId = [dic[@"id"] intValue];
        }else{
            self.scheduleId = [dic[@"scheduleId"] intValue];
            self.onTime = dic[@"onTime"];
            self.offTime = dic[@"offTime"];
            NSMutableArray *channelArray = [NSMutableArray array];
            
            NSMutableArray *weekArray = [NSMutableArray array];
            NSArray *array = dic[@"channels"];
            for (NSNumber *i in array) {
                [channelArray addObject:i];
            }
            self.channels = channelArray;
            NSArray *array0 = dic[@"weeks"];
            for (NSNumber *j in array0) {
                [weekArray addObject:j];
            }
            self.weeks = weekArray;
            self.runFlag = [dic[@"runFlag"] intValue];
        }
        return self;
    }
    return nil;
}
-(id)copyWithZone:(NSZone *)zone{
    MyESwitchSchedule *copy = [[[self class] allocWithZone:zone] init];
    copy.scheduleId = self.scheduleId;
    copy.onTime = self.onTime;
    copy.offTime = self.offTime;
    copy.channels = [self.channels copy];
    copy.weeks = [self.weeks copy];
    copy.runFlag = self.runFlag;
    return copy;
}
@end
