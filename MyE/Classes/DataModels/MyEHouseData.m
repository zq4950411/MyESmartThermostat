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

- (BOOL)isValid {
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
@end
