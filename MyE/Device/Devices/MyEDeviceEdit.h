//
//  MyEDeviceEdit.h
//  MyE
//
//  Created by 翟强 on 14-4-22.
//  Copyright (c) 2014年 MyEnergy Domain. All rights reserved.
//

#import <Foundation/Foundation.h>
@class MyETerminal;
@class MyEType;
@class MyERoom;

@interface MyEDeviceEdit : NSObject

@property (nonatomic,strong) MyEDevice *device;
@property (nonatomic,strong) NSMutableArray *types;
@property (nonatomic,strong) NSMutableArray *terminals;
@property (nonatomic,strong) NSMutableArray *rooms;

-(MyEDeviceEdit *)initWithJSONString:(NSString *)string;
-(MyEDeviceEdit *)initWithDic:(NSDictionary *)dic;
-(MyEType *)getTypeByTypeId:(NSInteger)s;
-(MyEType *)getTypeByTypeName:(NSString *)name;
-(MyETerminal *)getTerminalByTid:(NSString *)tId;
-(MyETerminal *)getTerminalByTName:(NSString *)name;
-(NSInteger)getRoomIdByRoomName:(NSString *)name;
-(NSString *)getRoomNameByRoomId:(NSInteger)roomId;

@end

@interface MyEType : NSObject
@property (nonatomic) NSInteger typeId;
@property (nonatomic, strong) NSString *typeName;

-(MyEType *)initWithDic:(NSDictionary *)dic;
@end

@interface MyETerminal : NSObject
@property (nonatomic, strong) NSString *tId;
@property (nonatomic, strong) NSString *terminalName;
-(MyETerminal *) initWithDic:(NSDictionary *)dic;
@end