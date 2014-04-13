//
//  MyEThermostatData.m
//  MyE
//
//  Created by Ye Yuan on 3/6/13.
//  Copyright (c) 2013 MyEnergy Domain. All rights reserved.
//

#import "MyEThermostatData.h"

@implementation MyEThermostatData
@synthesize tName = _tName, tId = _tId, thermostat = _thermostat, remote = _remote, deviceType = _deviceType, keypad = _keypad;

- (MyEThermostatData *)initWithDictionary:(NSDictionary *)dictionary {
    if (self = [super init]) {
        self.tId = [dictionary objectForKey:@"tId"];
        self.tName = [dictionary objectForKey:@"aliasName"];
        self.thermostat = [[dictionary objectForKey:@"thermostat"] intValue];
        self.deviceType = [[dictionary objectForKey:@"deviceType"] intValue];
        self.keypad = [[dictionary objectForKey:@"keypad"] intValue];
        
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
                          self.tId, @"tId",
                          [NSNumber numberWithInt:self.thermostat], @"thermostat",
                          [NSNumber numberWithInt:self.remote ? 1 : 0],@"remote",
                          self.tName, @"tName",
                          nil ];
    return dict;
}
-(id)copyWithZone:(NSZone *)zone {
    return [[MyEThermostatData alloc] initWithDictionary:[self JSONDictionary]];
}
@end
