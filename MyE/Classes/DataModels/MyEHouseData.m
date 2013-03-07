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
        self.mId = [[dictionary objectForKey:@"mId"] intValue];
        self.connection = [[dictionary objectForKey:@"connection"] intValue];
        
        NSArray *thermostatsInDict = [dictionary objectForKey:@"thermostats"];
        NSMutableArray *thermostats = [NSMutableArray array];
        for (NSDictionary *t in thermostatsInDict) {
            [thermostats addObject:[[MyEThermostatData alloc] initWithDictionary:t]];
        }
        
        self.thermostats = thermostats;
        
        return self;
    }
    return nil;
}
- (NSDictionary *)JSONDictionary {
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                          [NSNumber numberWithInt:self.houseId], @"houseId",
                          [NSNumber numberWithInt:self.mId], @"mId",
                          [NSNumber numberWithInt:self.connection],@"connection",
                          self.houseName, @"houseName",
                          [NSNumber numberWithInt:self.thermostats], @"thermostats",
                          nil ];
    return dict;
}
-(id)copyWithZone:(NSZone *)zone {
    return [[MyEHouseData alloc] initWithDictionary:[self JSONDictionary]];
}

@end
