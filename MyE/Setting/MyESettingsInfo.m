//
//  MyESettingsInfo.m
//  MyE
//
//  Created by 翟强 on 14-6-16.
//  Copyright (c) 2014年 MyEnergy Domain. All rights reserved.
//

#import "MyESettingsInfo.h"

@implementation MyESettingsInfo
-(MyESettingsInfo *)initWithJsonString:(NSString *)string{
    NSDictionary *dic = [string JSONValue];
    MyESettingsInfo *info = [[MyESettingsInfo alloc] initWithDictionary:dic];
    return info;
}
-(MyESettingsInfo *)initWithDictionary:(NSDictionary *)dic{
    if (self = [super init]) {
        self.mid = dic[@"mid"];
        self.houseName = dic[@"houseName"];
        self.timeZone = dic[@"timeZone"] == nil?1:[dic[@"timeZone"] intValue];
        self.terminals = [NSMutableArray array];
        for (NSDictionary *d in dic[@"smartDevices"]) {
            [self.terminals addObject:[[MyESettingsTerminal alloc] initWithDictionary:d]];
        }
        _subSwitchList = [NSMutableArray array];
        if (dic[@"subSwitchs"] && dic[@"subSwitchs"] != [NSNull null]) {
            for (NSDictionary *d in dic[@"subSwitchs"]) {
                [_subSwitchList addObject:[[MyESettingSubSwitch alloc] initWithDictionary:d]];
            }
        }
    }
    return self;
}
-(NSArray *)timeZoneArray{
    return @[@"EST",@"CST",@"MST",@"PST",@"AKST",@"HST"];
}
@end


@implementation MyESettingsTerminal

-(MyESettingsTerminal *)initWithDictionary:(NSDictionary *)dic{
    if (self = [super init]) {
        self.tid = dic[@"tid"];
        self.name = dic[@"aliasName"]== [NSNull null]?@"":dic[@"aliasName"];
        self.signal = [dic[@"rfStatus"] intValue];
        self.type = [dic[@"terminalType"] intValue];
        self.controlState = dic[@"controlState"]==[NSNull null]?0:[dic[@"controlState"] intValue];
    }
    return self;
}
-(UIImage *)changeSignalToImage{
    NSArray *array = @[@"signal0",@"signal1",@"signal2",@"signal3",@"signal4"];
    NSString *str = nil;
    if (self.signal == -1) {
        str = array[0];
    }else
        str = array[self.signal];
    return [UIImage imageNamed:str];
}
-(NSString *)changeTypeToString{
    NSArray *array = @[@"Thermostat",@"Smart Remote",@"Smart Socket",@"Smart DIY",@"Other",@"Other",@"Smart Switch"];
    return array[self.type];
}
@end

@implementation MyESettingsHouse

-(MyESettingsHouse *)initWithDictionary:(NSDictionary *)dic{
    if (self = [super init]) {
        self.houseName = dic[@"houseName"];
        self.houseId = [dic[@"houseId"] intValue];
    }
    return self;
}

@end

@implementation MyESettingSubSwitch

-(MyESettingSubSwitch *)initWithDictionary:(NSDictionary *)dic{
    if (self = [super init]) {
        self.gid = dic[@"gid"];
        self.tid = dic[@"tid"];
//        self.mId = dic[@"Mid"];
        self.name = dic[@"aliasName"];
        self.mainTid = dic[@"mainTId"];
        self.signal = [dic[@"rfStatus"] intValue];
    }
    return self;
}
-(UIImage *)getImage{
    NSArray *array = @[@"signal0",@"signal1",@"signal2",@"signal3",@"signal4"];
    if (self.signal == -1) {
        return [UIImage imageNamed:@"noconnection"];
    }
    return [UIImage imageNamed:array[self.signal]];
}
@end