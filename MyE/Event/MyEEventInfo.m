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
        self.sceneName = @"New Event";  //初始化给这个名字
        self.sceneId = -1;  //这个是接口明文规定的，新增场景是，ID为0
        self.type = 0;
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
        self.timeTriggerFlag = [dic[@""] intValue];
        self.conditionTriggerFlag = [dic[@""] intValue];
        return self;
    }
    return nil;
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
            [self.addDevices addObject:[[MyEEventDeviceAdd alloc] initWithDictionary:d]];
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
@end

@implementation MyEEventDevice

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
    }else
        return [NSString stringWithFormat:@"%@",self.instructionName];
}
@end

@implementation MyEEventDeviceAdd

-(MyEEventDeviceAdd *)initWithDictionary:(NSDictionary *)dic{
    if (self = [super init]) {
        self.name = dic[@"deviceName"];
        self.deviceId = [dic[@"deviceId"] intValue];
        self.terminalType = [dic[@"terminalType"] intValue];
    }
    return self;
}

@end

@implementation MyEEventConditionCustom
-(id)init{
    if (self = [super init]) {
        self.conditionId = 0;
        self.dataType = 1;
        self.parameterType = 1;
        self.parameterValue = 25;
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
    return [NSString stringWithFormat:@"%@ %@ %i",self.dataTypeArray[self.dataType],self.conditionArray[self.parameterType],self.parameterValue];
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
        self.timeType = 1;
        self.date = @"10/10/2014";
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
            for (NSNumber *i in dic[@"weeks"]) {
                [self.weeks addObject:i];
            }
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
