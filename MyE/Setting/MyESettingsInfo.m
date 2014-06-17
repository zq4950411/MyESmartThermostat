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
        self.timeZone = [dic[@"timeZone"] intValue];
        self.terminals = [NSMutableArray array];
        for (NSDictionary *d in dic[@"smartDevices"]) {
            [self.terminals addObject:[[MyESettingsTerminal alloc] initWithDictionary:d]];
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
        self.name = dic[@"aliasName"];
        self.signal = [dic[@"rfStatus"] intValue];
        self.type = [dic[@"terminalType"] intValue];
        self.controlState = [dic[@"controlState"] intValue];
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
    NSArray *array = @[@"Thermostat",@"Smart Remote",@"Smart Socket",@"Universal Controller",@"Other",@"Other",@"Smart Switch"];
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