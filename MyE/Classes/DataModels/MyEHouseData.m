//
//  HouseData.m
//  MyE
//
//  Created by Ye Yuan on 1/19/12.
//  Copyright (c) 2012 MyEnergy Domain. All rights reserved.
//

#import "MyEHouseData.h"
#import "MyEThermostatData.h"
#import "SBJson.h"

@interface MyEHouseData ()
// private variables or method goes here
@end

@implementation MyEHouseData

@synthesize houseName = _houseName, houseId = _houseId, mId = _mId, connection = _connection, thermostats = _thermostats;

- (void)setthermostats:(NSMutableArray *)newList {
    if(_thermostats != newList) {
        _thermostats = [newList mutableCopy];
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
                    [thermostats addObject:[[MyEThermostatData alloc] initWithDictionary:t]];
            }
        }        
        self.thermostats = thermostats;
        
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
                          self.thermostats, @"thermostats",
                          nil ];
    return dict;
}
-(id)copyWithZone:(NSZone *)zone {
    return [[MyEHouseData alloc] initWithDictionary:[self JSONDictionary]];
}

// 判定房子是否有效，标准是房子的M状态必须为0表示M正常链接，T列表不能为空，这样的房子才算有效
- (BOOL)isValid{
    if([self.mId length] == 0 || [self.thermostats count] == 0)
        return NO;

    return YES;
}

//判定房子是否连接, 标准是房子是否有M，并且至少有一个T在连接工作，才能键入房子，因为我们的目标是点击进入一个房子后必须有一个T的信息。
- (BOOL)isConnected{
    if([self.mId length] == 0 || self.connection == 1)
        return NO;
    for (MyEThermostatData *t  in self.thermostats) {
        if (t.thermostat ==0 ) {
            return YES;
        }
    }
    return NO;
}

- (MyEThermostatData *)firstConnectedThermostat{
    for (MyEThermostatData *t  in self.thermostats) {
        if (t.thermostat ==0 ) {
            return t;
        }
    }

    return nil;
}

- (NSInteger)countOfConnectedThermostat{// 房子有连接的T的数目。
    NSInteger count =0;
    for (MyEThermostatData *t  in self.thermostats) {
        if (t.thermostat ==0 ) {
            count ++;
        }
    }
    return count;
}
@end
