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
            [powerList addObject:[[MyEUsageRecord alloc] initWithDictionary:dict]];
        }
        self.powerRecordList = powerList;
        return self;
    }
    return nil;
}
- (NSDictionary *)JSONDictionary {
    
    NSMutableArray *powerList = [NSMutableArray array];
    
    for (MyEUsageRecord *usage in self.powerRecordList)
        [powerList addObject:[usage JSONDictionary]];

    
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                          @(self.totalPower), @"totalPower",
                            (self.currentPower), @"currentPower",
                          powerList, @"powerRecordList",
                          nil ];
    return dict;
}
-(id)copyWithZone:(NSZone *)zone {
    return [[MyEUsageStat alloc] initWithDictionary:[self JSONDictionary]];
}
@end


@implementation MyEUsageRecord

-(MyEUsageRecord *)initWithString:(NSString *)string{
    // Create new SBJSON parser object
    SBJsonParser *parser = [[SBJsonParser alloc] init];
    // 把JSON转为字典
    NSError *error = [[NSError alloc] init];
    NSDictionary *dict = [parser objectWithString:string error:&error];
    
    if (dict && [dict isKindOfClass:[NSDictionary class]]) {
        MyEUsageRecord *ur = [[MyEUsageRecord alloc] initWithDictionary:dict];
        return ur;
    }else
        return nil;

}
-(MyEUsageRecord *)initWithDictionary:(NSDictionary *)dic{
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
    return [[MyEUsageRecord alloc] initWithDictionary:[self JSONDictionary]];
}
@end