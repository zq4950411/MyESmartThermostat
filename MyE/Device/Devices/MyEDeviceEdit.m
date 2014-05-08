//
//  MyEDeviceEdit.m
//  MyE
//
//  Created by 翟强 on 14-4-22.
//  Copyright (c) 2014年 MyEnergy Domain. All rights reserved.
//

#import "MyEDeviceEdit.h"

@implementation MyEDeviceEdit

-(MyEDeviceEdit *)initWithJSONString:(NSString *)string{
    NSDictionary *dic = [string JSONValue];
    MyEDeviceEdit *edit = [[MyEDeviceEdit alloc] initWithDic:dic];
    return edit;
}
-(MyEDeviceEdit *)initWithDic:(NSDictionary *)dic{
    if (self = [super init]) {
        self.types = [NSMutableArray array];
        self.terminals = [NSMutableArray array];
        self.rooms = [NSMutableArray array];
        if (dic[@"deviceMode"] != [NSNull null]) {
            self.device = [[MyEDevice alloc] initWithDic:dic[@"deviceMode"]];
        }
        
        for (NSDictionary *d in dic[@"typeList"]) {
            [self.types addObject:[[MyEType alloc] initWithDic:d]];
        }
        for (NSDictionary *d in dic[@"terminalList"]) {
            [self.terminals addObject:[[MyETerminal alloc] initWithDic:d]];
        }
        for (NSDictionary *d in dic[@"locationList"]) {
            [self.rooms addObject:[[MyERoom alloc] initWithDic:d]];
        }
        return self;
    }
    return nil;
}
-(id)getTypeByTypeId:(NSInteger)s{
    for (MyEType *t in self.types) {
        if (t.typeId == s) {
            return t;
        }
    }
    return nil;
}
-(id)getTypeByTypeName:(NSString *)name{
    for (MyEType *t in self.types) {
        if ([t.typeName isEqualToString:name]) {
            return t;
        }
    }
    return nil;
}
-(id)getTerminalByTid:(NSString *)tid{
    for (MyETerminal *t in self.terminals) {
        if ([t.tId isEqualToString:tid]) {
            return t;
        }
    }
    return nil;
}
-(MyETerminal *)getTerminalByTName:(NSString *)name{
    for (MyETerminal *t in self.terminals) {
        if ([t.terminalName isEqualToString:name]) {
            return t;
        }
    }
    return nil;
}
-(NSInteger)getRoomIdByRoomName:(NSString *)name{
    NSLog(@"%@",self.rooms);
    for (MyERoom *r in self.rooms) {
        if ([r.roomName isEqualToString:name]) {
            NSLog(@"%i",r.roomId);
            return r.roomId;
        }
    }
    return 0;
}
-(NSString *)getRoomNameByRoomId:(NSInteger)roomId{
    for (MyERoom *r in self.rooms) {
        if (r.roomId == roomId) {
            return r.roomName;
        }
    }
    return nil;
}
@end

@implementation MyETerminal

-(MyETerminal *)initWithDic:(NSDictionary *)dic{
    if (self = [super init]) {
        self.tId = dic[@"tid"];
        self.terminalName = dic[@"aliasName"];
        return self;
    }
    return nil;
}

@end

@implementation MyEType

-(MyEType *)initWithDic:(NSDictionary *)dic{
    if (self = [super init]) {
        self.typeId = [dic[@"typeId"] intValue];
        self.typeName = dic[@"typeName"];
        return self;
    }
    return nil;
}

@end