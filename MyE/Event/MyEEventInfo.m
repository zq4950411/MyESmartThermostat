//
//  MyEEventInfo.m
//  MyE
//
//  Created by 翟强 on 14-5-23.
//  Copyright (c) 2014年 MyEnergy Domain. All rights reserved.
//

#import "MyEEventInfo.h"

@implementation MyEEventInfo
-(id)init{
    if (self = [super init]) {
        self.sceneName = @"";  //初始化给这个名字
        self.sceneId = -1;  //这个是接口明文规定的，新增场景是，ID为0
        self.type = 0;  //0是不可应用，1是可应用,默认是自动的
        self.timeTriggerFlag = 0;
        self.conditionTriggerFlag = 0;
    }
    return self;
}
-(MyEEventInfo *)initWithDictionary:(NSDictionary *)dic{
    if (self = [super init]) {
        self.sceneName = dic[@"sceneName"];
        self.sceneId = [dic[@"sceneId"] intValue];
        self.type = [dic[@"type"] intValue];
        self.timeTriggerFlag = [dic[@"timeTriggerFlag"] intValue];
        self.conditionTriggerFlag = [dic[@"conditionTriggerFlag"] intValue];
        return self;
    }
    return nil;
}
-(NSString *)description{
    return [NSString stringWithFormat:@"type:%i time:%i condition:%i",self.type,self.timeTriggerFlag,self.conditionTriggerFlag];
}
@end
@implementation MyEEvents

-(MyEEvents *)initWithJsonString:(NSString *)string{
    NSArray *array = [string JSONValue];
    MyEEvents *events = [[MyEEvents alloc] initWithArray:array];
    return events;
}
-(MyEEvents *)initWithArray:(NSArray *)array{
    if (self = [super init]) {
        self.scenes = [NSMutableArray array];
        for (NSDictionary *d in array) {
            [self.scenes addObject:[[MyEEventInfo alloc] initWithDictionary:d]];
        }
    }
    return self;
}
@end

@implementation MyEEventDetail

-(id)init{
    if (self = [super init]) {
        self.customConditions = [NSMutableArray array];
        self.timeConditions = [NSMutableArray array];
        self.devices = [NSMutableArray array];
        self.addDevices = [NSMutableArray array];
    }
    return self;
}
-(MyEEventDetail *)initWithJsonString:(NSString *)string{
    NSDictionary *dic = [string JSONValue];
    MyEEventDetail *detail = [[MyEEventDetail alloc] initWithDictionary:dic];
    return detail;
}
-(MyEEventDetail *)initWithDictionary:(NSDictionary *)dic{
    if (self = [super init]) {
        self.devices = [NSMutableArray array];
        for (NSDictionary *d in dic[@"deviceList"]) {
            [self.devices addObject:[[MyEEventDevice alloc] initWithDictionary:d]];
        }
        self.addDevices = [NSMutableArray array];
        for (NSDictionary *d in dic[@"addDeviceList"]) {
            [self.addDevices addObject:[[MyEEventDevice alloc] initWithDictionary:d]];
        }
        self.customConditions = [NSMutableArray array];
        for (NSDictionary *d in dic[@"customParameterList"]) {
            [self.customConditions addObject:[[MyEEventConditionCustom alloc] initWithDictionary:d]];
        }
        self.timeConditions = [NSMutableArray array];
        for (NSDictionary *d in dic[@"timeParameterList"]) {
            [self.timeConditions addObject:[[MyEEventConditionTime alloc] initWithDictionary:d]];
        }
        self.sortFlag = [dic[@"sortFlag"] intValue];
    }
    return self;
}
-(NSArray *)getDeviceType{
    //设备类型：0：温控器  2:TV,  3: Audio, 4:Automated Curtain, 5: Other,  6 智能插座,7:通用控制器 8:智能开关
    NSMutableArray *deviceTypes = [NSMutableArray array];
    NSArray *names = @[@"Thermostat",@"TV",@"Audio",@"Curtain",@"Other",@"Socket",@"DIY",@"Switch"];
    for (int i = 1; i < 9; i++) {
        MyEEventDeviceAdd *add = [[MyEEventDeviceAdd alloc] init];
        if (i == 1 ) {
            add.typeId = 0;
        }else
            add.typeId = i;
        add.typeName = names[i-1];
        [deviceTypes addObject:add];
    }
    
    return deviceTypes;
}
-(NSArray *)getTypeDevices{
    //设备类型：0：温控器  2:TV,  3: Audio, 4:Automated Curtain, 5: Other,  6 智能插座,7:通用控制器 8:智能开关
    NSArray *deviceTypes = [self getDeviceType];
    NSMutableArray *array = [deviceTypes mutableCopy];
    for (MyEEventDeviceAdd *add in deviceTypes) {
        for (MyEEventDevice *d in self.addDevices) {
            if (d.typeId == add.typeId) {
                [add.devices addObject:d];
            }
        }
        if (![add.devices count]) {
            [array removeObject:add];
        }
    }
//    NSLog(@"deviceTypes is %@",deviceTypes);
    NSLog(@"array is %@",array);
    return array;
}
@end

@implementation MyEEventDevice

-(id)init{
    if (self = [super init]) {
        self.name = @"New Device";
        self.sceneSubId = 0;
        self.terminalType = 0;
        self.instructionName = @"";
        self.point = 50;
        self.controlMode = 1;
        self.typeId = 0;
        self.deviceId = 0;
    }
    return self;
}
-(MyEEventDevice *)initWithDictionary:(NSDictionary *)dic{
    if (self = [super init]) {
        self.name = dic[@"deviceName"];
        self.sceneSubId = dic[@"sceneSubId"] == [NSNull null]?0:[dic[@"sceneSubId"] integerValue];
        self.terminalType = [dic[@"terminalType"] intValue];
        self.instructionName = dic[@"instructionName"] == [NSNull null]? @"":dic[@"instructionName"];
        self.point = dic[@"point"] == [NSNull null]?0:[dic[@"point"] intValue];
        self.controlMode = dic[@"controlMode"] == [NSNull null]?0:[dic[@"controlMode"] intValue];
        self.typeId = [dic[@"typeId"] intValue];
        self.deviceId = [dic[@"deviceId"] intValue];
    }
    return self;
}
-(UIImage *)changeTypeToImage{
    //设备类型：2:TV,  3: Audio, 4:Automated Curtain, 5: Other,  6 智能插座,7:通用控制器 8:智能开关   0：温控器
    NSArray *imageArray = @[@"tv-on",@"audio-on",@"curtain-on",@"other-on",@"socket-on",@"universe-on",@"switch-on"];
    NSString *imageName = nil;
    if (self.typeId == 0) {
        imageName = @"";
    }else
        imageName = imageArray[self.typeId - 2];   //这里的减2是因为电视是从2开始的
    return [UIImage imageNamed:imageName];
}
-(NSString *)getDeviceInstructionName{
    NSArray *controlMode = @[@"Heat",@"Cool",@"Auto",@"EmgHeat",@"OFF"];
    if (self.typeId == 0) {
        return [NSString stringWithFormat:@"%@ %i",controlMode[self.controlMode - 1],self.point];
    }else if(self.typeId == 6){
        return [self.instructionName isEqualToString:@"1"]?@"ON":@"OFF";
    }else
        return [NSString stringWithFormat:@"%@",self.instructionName];
}
-(id)copyWithZone:(NSZone *)zone{
    MyEEventDevice *device = [[[self class] allocWithZone:zone] init];
    device.name = self.name;
    device.sceneSubId = self.sceneSubId;
    device.terminalType = self.terminalType;
    device.instructionName = self.instructionName;
    device.point = self.point;
    device.controlMode = self.controlMode;
    device.typeId = self.typeId;
    device.deviceId = self.deviceId;
    return device;
}
-(NSString *)description{
    return [NSString stringWithFormat:@"%@ %i mode:%i point:%i",self.name,self.typeId,self.controlMode,self.point];
}
@end

@implementation MyEEventDeviceAdd

-(id)init{
    if (self = [super init]) {
        self.typeName = @"";
        self.typeId = 0;
        self.devices = [NSMutableArray array];
    }
    return self;
}
-(NSString *)description{
    return [NSString stringWithFormat:@"%i  %@  %@",self.typeId,self.typeName,self.devices];
}
@end

@implementation MyEEventDeviceInstructions
-(id)init{
    if (self = [super init]) {
        self.controlMode = 1;
        self.point = 55;
        self.fan = 0;
        self.channel = @"";
        self.controlStatus = 0;
        self.instructions = [NSMutableArray array];
    }
    return self;
}
-(MyEEventDeviceInstructions *)initWithJsonString:(NSString *)string{
    NSDictionary *dic = [string JSONValue];
    MyEEventDeviceInstructions *instructions = [[MyEEventDeviceInstructions alloc] initWithDictionary:dic];
    return instructions;
}
-(MyEEventDeviceInstructions *)initWithDictionary:(NSDictionary *)dic{
    if (self = [super init]) {
        self.controlMode = [dic[@"controlMode"] intValue];
        self.point = [dic[@"point"] intValue];
        self.fan = [dic[@"fan"] intValue];
        self.channel = dic[@"channel"];
        if ([self.channel isEqualToString:@""]) {
            self.channel = @"000000";
        }
        self.controlStatus = [dic[@"controlStatus"] intValue];
        self.instructions = [NSMutableArray array];
        if (dic[@"instructionDeviceList"] != [NSNull null]) {
            for (NSDictionary *d in dic[@"instructionDeviceList"]) {
                [self.instructions addObject:[[MyEInstruction alloc] initWithDic:d]];
            }
        }
    }
    return self;
}
-(NSArray *)controlModeArray{
    return @[@"Heat",@"Cool",@"Auto",@"EmgHeat",@"OFF"];
}
-(NSArray *)pointArray{
    NSMutableArray *array = [NSMutableArray array];
    for (int i = 55; i < 91; i++) {
        [array addObject:[NSString stringWithFormat:@"%i F",i]];
    }
    return array;
}
-(NSArray *)controlStatusArray{
    return @[@"OFF",@"ON"]; //对应了0关1开
}
-(NSArray *)fanMode{
    return @[@"Auto",@"ON"];  //0:auto  1:on
}
@end

@implementation MyEEventConditionCustom
-(id)init{
    if (self = [super init]) {
        self.conditionId = 0;
        self.dataType = 1;
        self.parameterType = 1;
        self.parameterValue = 50;
        self.tId = @"";
    }
    return self;
}
-(MyEEventConditionCustom *)initWithDictionary:(NSDictionary *)dic{
    if (self = [super init]) {
        self.conditionId = [dic[@"id"] intValue];
        self.dataType = [dic[@"dataType"] intValue];
        self.parameterType = [dic[@"parameterType"] intValue];
        self.parameterValue = [dic[@"parameterValue"] intValue];
        self.tId = self.tId == (NSString *)[NSNull null]?@"":dic[@"tid"];
    }
    return self;
}
-(NSString *)changeDataToString{
    return [NSString stringWithFormat:@"%@ %@ %i",self.dataTypeDetailArray[self.dataType-1],self.conditionDetailArray[self.parameterType-1],self.parameterValue];
}
-(NSArray *)dataTypeArray{
    return @[@"Indoor Temperature",
             @"Indoor Humidity",
             @"Outdoor Temperature",
             @"Outdoor Humidty"];
}
-(NSArray *)conditionArray{
    return @[@"Higher than",
             @"Lower than",
             @"Equal to"];
}
-(NSArray *)dataTypeDetailArray{
    return @[@"Indoor Tem",
             @"Indoor Hum",
             @"Outdoor Tem",
             @"Outdoor Hum"];
}
-(NSArray *)conditionDetailArray{
    return @[@">",@"<",@"="];
}
-(id)copyWithZone:(NSZone *)zone{
    MyEEventConditionCustom *custom = [[[self class] allocWithZone:zone] init];
    custom.conditionId = self.conditionId;
    custom.dataType = self.dataType;
    custom.parameterType = self.parameterType;
    custom.parameterValue = self.parameterValue;
    custom.tId = self.tId;
    return custom;
}
-(NSString *)description{
    return [NSString stringWithFormat:@"id: %i type: %i relation: %i value: %i tid: %@",self.conditionId,self.dataType,self.parameterType,self.parameterValue,self.tId];
}
@end

@implementation MyEEventConditionTime
-(id)init{
    if (self = [super init]) {
        self.conditionId = 0;
        self.timeType = 1;  //默认是日期的格式
        self.date = @"";
        self.hour = 12;
        self.minute = 10;
        self.weeks = [NSMutableArray array];
    }
    return self;
}
-(MyEEventConditionTime *)initWithDictionary:(NSDictionary *)dic{
    if (self = [super init]) {
        self.conditionId = [dic[@"id"] intValue];
        self.timeType = [dic[@"timeType"] intValue];
        self.minute = [dic[@"minute"] intValue];
        self.hour = [dic[@"hour"] intValue];
        self.date = dic[@"date"] == [NSNull null]?@"":dic[@"date"];
        self.weeks = [NSMutableArray array];
        if (dic[@"weeks"] != [NSNull null]) {
            NSMutableArray *array = [NSMutableArray array];
            for (NSNumber *i in dic[@"weeks"]) {
                [array addObject:i];
            }
            NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"self" ascending:YES];
            NSArray *sortArray = [array sortedArrayUsingDescriptors:@[sort]];
            self.weeks = [sortArray mutableCopy];
        }
    }
    return self;
}
-(id)copyWithZone:(NSZone *)zone{
    MyEEventConditionTime *time = [[[self class] allocWithZone:zone] init];
    time.conditionId = self.conditionId;
    time.timeType = self.timeType;
    time.date = self.date;
    time.hour = self.hour;
    time.minute = self.minute;
    time.weeks = [self.weeks copy];
//    for (NSNumber *i in self.weeks) {
//        [time.weeks addObject:i];
//    }
    return time;
}
-(NSString *)changeDateToString{
    
    return [NSString stringWithFormat:@"%i:%@ %@ %@",self.hour,self.minute == 0? @"00":[NSString stringWithFormat:@"%i",self.minute],self.date,[self.weeks componentsJoinedByString:@","]];
}
@end
