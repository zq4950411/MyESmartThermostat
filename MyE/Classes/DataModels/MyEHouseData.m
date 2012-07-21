//
//  HouseData.m
//  MyE
//
//  Created by Ye Yuan on 1/19/12.
//  Copyright (c) 2012 MyEnergy Domain. All rights reserved.
//

#import "MyEHouseData.h"
#import "SBJson.h"

@implementation MyEHouseData

@synthesize houseName = _houseName, houseId = _houseId, thermostat = _thermostat, remote = _remote;

- (id)initWithName:(NSString *)theName houseId:(NSInteger)theId thermostat:(NSInteger)thermostat remote:(NSInteger)remote{
    self = [super init];
    if (self) {
        _houseName = theName;
        _houseId = theId;
        _thermostat = thermostat;
        _remote = remote;
        return self;
    }
    return nil;
}

- (MyEHouseData *)initWithDictionary:(NSDictionary *)dictionary {
    if (self = [super init]) {
        self.houseId = [[dictionary objectForKey:@"houseId"] intValue];
        self.houseName = [dictionary objectForKey:@"houseName"];
        self.thermostat = [[dictionary objectForKey:@"thermostat"] intValue];
        
        //remote = 0表示禁止远程控制，1表示允许远程控制。（只有当thermostat=0 和1时才有remote的值,thermostat=2是没有硬件，就没有返回remote的值了
        if (self.thermostat == 0 || self.thermostat == 1) {
            self.remote = [[dictionary objectForKey:@"remote"] intValue] == 0 ? NO : YES;
        }
        return self;
    }
    return nil;
}
- (NSDictionary *)JSONDictionary {
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                          [NSNumber numberWithInt:self.houseId], @"houseId",
                          [NSNumber numberWithInt:self.thermostat], @"thermostat",
                          [NSNumber numberWithInt:self.remote ? 1 : 0],@"remote",
                          self.houseName, @"houseName",
                          nil ];
    return dict;
}
-(id)copyWithZone:(NSZone *)zone {
    return [[MyEHouseData alloc] initWithDictionary:[self JSONDictionary]];
}
@end
