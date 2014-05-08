//
//  MyESwitchInfo.m
//  MyEHomeCN2
//
//  Created by 翟强 on 14-3-3.
//  Copyright (c) 2014年 My Energy Domain Inc. All rights reserved.
//

#import "MyESwitchInfo.h"

@implementation MyESwitchInfo
-(MyESwitchInfo *)initWithString:(NSString *)string{
    SBJsonParser *parser = [[SBJsonParser alloc] init];
    NSDictionary *dic = [parser objectWithString:string];
    MyESwitchInfo *info = [[MyESwitchInfo alloc] initWithDic:dic];
    return info;
}
-(MyESwitchInfo *)initWithDic:(NSDictionary *)dic{
    if (self = [super init]) {
        self.name = dic[@"name"];
        self.roomId = [dic[@"roomId"] intValue];
        self.powerType = [dic[@"powerType"] intValue];
        self.reportTime = [dic[@"reporteTime"] intValue];
        NSArray *array = dic[@"locationList"];
        self.rooms = [NSMutableArray array];
        for (NSDictionary *d in array) {
            [self.rooms addObject:[[MyERoom alloc] initWithDic:d]];
        }
        return self;
    }
    return nil;
}
@end


@implementation MyERoom

-(MyERoom *)initWithJSONString:(NSString *)string{
    NSDictionary *dic = [string JSONValue];
    MyERoom *room = [[MyERoom alloc] initWithDic:dic];
    return room;
}
-(MyERoom *)initWithDic:(NSDictionary *)dic{
    if (self = [super init]) {
        if (dic[@"locationId"]) {
            self.roomId = [dic[@"locationId"] integerValue];
        }
        if (dic[@"locationName"]) {
            self.roomName = dic[@"locationName"];
        }
    }
    return self;
}

@end