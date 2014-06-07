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
    NSString *string = @"";
    for (NSNumber *i in self.weeks) {
        string = [string stringByAppendingString:array[i.intValue]];
    }
    NSLog(@"string is %@",string);
    return string;
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

@end

@implementation MyEUCPeriod

-(MyEUCPeriod *)initWithDictionary:(NSDictionary *)dic{
    if (self = [super init]) {
        self.stid = [dic[@"stid"] intValue];
        self.edid = [dic[@"edid"] intValue];
    }
    return self;
}

@end