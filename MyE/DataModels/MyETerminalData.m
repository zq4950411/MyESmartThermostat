//
//  MyETerminalData.m
//  MyE
//
//  Created by Ye Yuan on 3/6/13.
//  Copyright (c) 2013 MyEnergy Domain. All rights reserved.
//

#import "MyETerminalData.h"

@implementation MyETerminalData
-(MyETerminalData *)initWithString:(NSString *)string{
    SBJsonParser *parser = [[SBJsonParser alloc] init];
    NSDictionary *dic = [parser objectWithString:string];
    MyETerminalData *t = [[MyETerminalData alloc] initWithDictionary:dic];
    return t;
}
- (MyETerminalData *)initWithDictionary:(NSDictionary *)dictionary {
    if (self = [super init]) {
        self.tId = [dictionary objectForKey:@"tId"];
        self.tName = [dictionary objectForKey:@"aliasName"];
        self.connection = [[dictionary objectForKey:@"thermostat"] intValue];
        self.deviceType = [[dictionary objectForKey:@"deviceType"] intValue];
        self.keypad = dictionary[@"keypad"] == [NSNull null]?0:[[dictionary objectForKey:@"keypad"] intValue];
        
        //remote = 0表示禁止远程控制，1表示允许远程控制。（只有当thermostat=0 和1时才有remote的值,thermostat=2是没有硬件，就没有返回remote的值了
        if (self.connection == 0 || self.connection == 1) {
            self.remote = [[dictionary objectForKey:@"remote"] intValue] == 0 ? NO : YES;
        }
        return self;
    }
    return nil;
}
- (NSDictionary *)JSONDictionary {
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                          self.tId, @"tId",
                          [NSNumber numberWithInt:self.connection], @"thermostat",
                          [NSNumber numberWithInt:self.remote ? 1 : 0],@"remote",
                          self.tName, @"tName",
                          nil ];
    return dict;
}
-(id)copyWithZone:(NSZone *)zone {
    return [[MyETerminalData alloc] initWithDictionary:[self JSONDictionary]];
}
@end
