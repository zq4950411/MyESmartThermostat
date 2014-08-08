//
//  SmartUp.h
//  MyE
//
//  Created by space on 13-8-8.
//  Copyright (c) 2013年 MyEnergy Domain. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "BaseObject.h"
#import "MyESwitchInfo.h"
#import "MyEAcInstructionSet.h"
@class MyEDeviceStatus;
@interface MyEDevice : BaseObject

@property (nonatomic,strong) NSString *deviceId;
@property (nonatomic,strong) NSString *deviceName;
@property (nonatomic,strong) NSString *switchStatus;
@property (nonatomic,strong) NSString *typeId; //2:TV,  3: Audio, 4:Automated Curtain, 5: Other,  6 智能插座,7:通用控制器, 8:智能开关
@property (nonatomic,strong) NSString *tid;
@property (nonatomic,strong) NSString *rfStatus;
@property (nonatomic,strong) NSString *sortId;
@property (nonatomic,strong) NSString *locationId;
@property (nonatomic,strong) NSString *locationName;
@property (nonatomic,assign) NSInteger point; //温控器设置的温度，温控器可用
@property (nonatomic,strong) NSString *instructionName;  //显示指令的名称如：”on”,”off”，通用控制器和开关显示“110000”，“102“，开关的2代表禁用
@property (nonatomic,assign) BOOL showSpecialDays;  //是否显示SpecialDays,温控器可用
@property (nonatomic, assign) NSInteger maxCurrent;  //插座可用
@property (nonatomic,assign) BOOL isExpand;

//以下这两个字段是针对空调设备存在的
@property (nonatomic, assign) BOOL isSystemDefined;
@property (nonatomic, strong) MyEDeviceStatus *status;
@property (nonatomic, assign) NSInteger instructionMode; //这个表示除湿模式是否存在
@property (nonatomic, assign) NSInteger modelId; //空调型号
@property (nonatomic, assign) NSInteger brandId;
@property (nonatomic, strong) NSString *brand,*model;
@property (nonatomic, assign) MyEAcInstructionSet *acInstructionSet;

+(NSMutableArray *) devices:(id) json;
-(MyEDevice *)initWithDic:(NSDictionary *)dic;
-(NSDictionary *)jsonDevice:(MyEDevice *)device;

@end


@interface MyEMainDevice : NSObject
@property (nonatomic, strong) NSMutableArray *devices;
@property (nonatomic, strong) NSMutableArray *rooms;
-(MyEMainDevice *)initWithJSONString:(NSString *)string;
-(MyEMainDevice *)initWithDic:(NSDictionary *)dic;
-(MyEMainDevice *)initWithJSONString:(NSString *)string andTag:(NSInteger)tag;
-(MyEMainDevice *)initWithArray:(NSArray *)array andTag:(NSInteger)tag;
@end


@interface MyEDeviceStatus : NSObject

@property (nonatomic, assign) NSInteger powerSwitch;
@property (nonatomic, assign) NSInteger runMode;
@property (nonatomic, assign) NSInteger windLevel;
@property (nonatomic, assign) NSInteger setpoint;
@property (nonatomic, assign) NSInteger humidity;
@property (nonatomic, assign) NSInteger temperature;
//以下三个字段表示的是空调温度监控的相关信息
@property (nonatomic, assign) NSInteger tempMornitorEnabled;
@property (nonatomic, assign) NSInteger acAutoRunEnabled;
@property (nonatomic, assign) NSInteger acTmin;
@property (nonatomic, assign) NSInteger acTmax;

-(MyEDeviceStatus *)initWithJSONString:(NSString *)string;
-(MyEDeviceStatus *)initWithDic:(NSDictionary *)dic;
@end