//
//  HouseData.m
//  MyE
//
//  Created by Ye Yuan on 1/19/12.
//  Copyright (c) 2012 MyEnergy Domain. All rights reserved.
//

#import "MyEHouseData.h"
#import "MyETerminalData.h"
#import "SBJson.h"

@interface MyEHouseData ()
// private variables or method goes here
@end

@implementation MyEHouseData

@synthesize houseName = _houseName, houseId = _houseId, mId = _mId, connection = _connection, terminals = _terminals;

- (void)setthermostats:(NSMutableArray *)newList {
    if(_terminals != newList) {
        _terminals = [newList mutableCopy];
    }
}
- (MyEHouseData *)initWithDictionary:(NSDictionary *)dictionary {
    if (self = [super init]) {
        self.houseId = [[dictionary objectForKey:@"houseId"] intValue];
        self.houseName = [dictionary objectForKey:@"houseName"];
        self.mId = [dictionary objectForKey:@"mId"];
        self.connection = [[dictionary objectForKey:@"connection"] intValue];
        
        NSArray *thermostatsInDict = [dictionary objectForKey:@"thermostats"];
        NSMutableArray *thermostats = [NSMutableArray array];
        
        if ([thermostatsInDict isKindOfClass:[NSArray class]]){
            for (NSDictionary *t in thermostatsInDict) {
                if([[t objectForKey:@"thermostat"] intValue]<2)// 只统计有温控器的房屋。去掉这句就会统计所有房屋
                    [thermostats addObject:[[MyETerminalData alloc] initWithDictionary:t]];
            }
        }        
        self.terminals = thermostats;
        return self;
    }
    return nil;
}
- (MyEHouseData *)initWithJSONString:(NSString *)jsonString {
    // Create new SBJSON parser object
    SBJsonParser *parser = [[SBJsonParser alloc] init];
    // 把JSON转为字典
    NSError *error = [[NSError alloc] init];
    NSDictionary *dict = [parser objectWithString:jsonString error:&error];
    
    MyEHouseData *house = [[MyEHouseData alloc] initWithDictionary:dict];
    return house;
}
- (NSDictionary *)JSONDictionary {
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                          [NSNumber numberWithInt:self.houseId], @"houseId",
                          self.mId, @"mId",
                          [NSNumber numberWithInt:self.connection],@"connection",
                          self.houseName, @"houseName",
                          self.terminals, @"thermostats",
                          nil ];
    return dict;
}
-(id)copyWithZone:(NSZone *)zone {
    return [[MyEHouseData alloc] initWithDictionary:[self JSONDictionary]];
}

- (BOOL)isOnline{
    if([self.mId length] != 0 && self.connection == 0) //|| [self.thermostats count] == 0)
        return YES;
    return NO;
}
// 判定房子是否有效，标准是房子的M状态必须为0表示M正常链接，T列表不能为空，这样的房子才算有效
- (BOOL)isValid{
    if ([self.mId length] != 0) {
        return YES;
    }
    return NO;
}
//判定房子是否连接, 标准是房子是否有M，并且至少有一个T在连接工作，才能键入房子，因为我们的目标是点击进入一个房子后必须有一个T的信息。
- (BOOL)isConnected{
    if([self.mId length] == 0 || self.connection == 1)
        return NO;
    for (MyETerminalData *t  in self.terminals) {
        if (t.connection == 0) {
            return YES;
        }
    }
    return YES;
}

- (MyETerminalData *)firstConnectedThermostat
{
    for (MyETerminalData *t  in self.terminals)
    {
        if (t.connection == 0 && t.deviceType == 0)
        {
            return t;
        }
    }

    return nil;
}
- (NSArray *)thermostatList// 返回全部控器设备列表
{
    NSMutableArray *array = [NSMutableArray array];
    for (MyETerminalData *t  in self.terminals)
    {
        if (t.deviceType == 0)
        {
            [array addObject:t];
        }
    }
    return array;
}
// 返回有链接的温控器设备列表
- (NSArray *)connectedThermostatList
{
    NSMutableArray *array = [NSMutableArray array];
    for (MyETerminalData *t  in self.terminals)
    {
        if (t.connection == 0 && t.deviceType == 0)
        {
            [array addObject:t];
        }
    }
    return array;
}

// 给定一个tId，返回拥有该tId的温控器在有链接的温控器设备列表里面的序号. 如果没找到， 返回-1
- (NSInteger)indexInConnectedThermostatListFortId:(NSString *)tId
{
#warning 这里修改了
    if(!tId) return -1;
    NSArray *thermostatList = [self connectedThermostatList];
    for (NSInteger i=0; i < thermostatList.count; i++) {
        MyETerminalData *t = thermostatList[i];
        if ([t.tId isEqualToString:tId]) {
            return i;
        }
    }
    return -1;
}

- (MyETerminalData *)getTerminalDataBytId:(NSString *)tId{
    for (MyETerminalData *t  in self.terminals)
    {
        if ([t.tId isEqualToString:tId])
        {
            return t;
        }
    }
    return nil;
}

- (NSInteger)countOfConnectedTerminal{// 房子有连接的T的数目。
    NSInteger count =0;
    for (MyETerminalData *t  in self.terminals) {
        if (t.connection ==0 ) {
            count ++;
        }
    }
    return count;
}

// 返回可以用于电量显示的终端, 目前包括：智能插座、智能开关。
//0表示美国温度控制器,   1 红外转发器,    2智能插座,    3  通用控制器,    4 安防设备,    6智能开关
- (NSArray *)terminalsForUsageStats {
    NSMutableArray *arr = [NSMutableArray array];
    for (MyETerminalData *t in self.terminals) {
        if (t.deviceType == 2 || t.deviceType == 6){
            [arr addObject:t];
        }
    }
    return arr;
}
@end
