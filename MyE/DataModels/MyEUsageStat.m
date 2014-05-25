//
//  MyEUsageStat.m
//  MyEHomeCN2
//
//  Created by 翟强 on 14-3-4.
//  Edited by Ye Yuan 2014-5-24
//  Copyright (c) 2014年 My Energy Domain Inc. All rights reserved.
//

#import "MyEUsageStat.h"

@implementation MyEUsageStat

-(MyEUsageStat *)initWithString:(NSString *)string{
    SBJsonParser *parser = [[SBJsonParser alloc] init];
    NSDictionary *dic = [parser objectWithString:string];
    MyEUsageStat *elec = [[MyEUsageStat alloc] initWithDictionary:dic];
    return elec;
}
-(MyEUsageStat *)initWithDictionary:(NSDictionary *)dic{
    if (self = [super init]) {
        self.totalPower = [dic[@"totalPower"] floatValue];
        self.currentPower = [dic[@"currentPower"] floatValue];
        NSMutableArray *powerList = [NSMutableArray array];
        NSArray *array = dic[@"powerRecordList"];
        for (NSDictionary *dict in array) {
            [powerList addObject:[[MyEUsageStatus alloc] initWithDictionary:dict]];
        }
        self.powerRecordList = powerList;
        return self;
    }
    return nil;
}
- (NSDictionary *)JSONDictionary {
    
    NSMutableArray *powerList = [NSMutableArray array];
    
    for (MyEUsageStatus *usage in self.powerRecordList)
        [powerList addObject:[usage JSONDictionary]];

    
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                          @(self.totalPower), @"totalPower",
                            (self.currentPower), @"currentPower",
                          powerList, @"powerList",
                          nil ];
    return dict;
}
-(id)copyWithZone:(NSZone *)zone {
    return [[MyEUsageStat alloc] initWithDictionary:[self JSONDictionary]];
}
@end


@implementation MyEUsageStatus

-(MyEUsageStatus *)initWithString:(NSString *)string{
    return self;//这里是没怎么写，直接返回self
}
-(MyEUsageStatus *)initWithDictionary:(NSDictionary *)dic{
    if (self = [super init]) {
        self.totalPower = [dic[@"totalPower"] floatValue];
        if (dic[@"dataTime"]) {
            self.date = dic[@"dataTime"];
        }
        return self;
    }
    return nil;
}
- (NSDictionary *)JSONDictionary {
    
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                          @(self.totalPower), @"totalPower",
                          self.date, @"dataTime",
                          nil ];
    return dict;
}
-(id)copyWithZone:(NSZone *)zone {
    return [[MyEUsageStatus alloc] initWithDictionary:[self JSONDictionary]];
}
@end