//
//  MyEEventInfo.h
//  MyE
//
//  Created by 翟强 on 14-5-23.
//  Copyright (c) 2014年 MyEnergy Domain. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SBJson.h"
#import "MyEInstructions.h"
@interface MyEEventInfo : NSObject
@property (nonatomic, copy) NSString *sceneName;
@property (nonatomic, assign) NSInteger sceneId;
@property (nonatomic, assign) NSInteger type;  //0是自动，1是手动
@property (nonatomic, assign) NSInteger timeTriggerFlag;  //时间触发开关
@property (nonatomic, assign) NSInteger conditionTriggerFlag; //条件触发开关

-(MyEEventInfo *)initWithDictionary:(NSDictionary *)dic;
@end

@interface MyEEvents : NSObject
@property (nonatomic, strong) NSMutableArray *scenes;
-(MyEEvents *)initWithJsonString:(NSString *)string;
-(MyEEvents *)initWithArray:(NSArray *)array;
@end

@interface MyEEventDetail : NSObject
@property (nonatomic, strong) NSMutableArray *devices;
@property (nonatomic, strong) NSMutableArray *addDevices;
@property (nonatomic, strong) NSMutableArray *customConditions;
@property (nonatomic, strong) NSMutableArray *timeConditions;
@property (nonatomic, assign) NSInteger sortFlag;  //是否按序执行
-(MyEEventDetail *)initWithJsonString:(NSString *)string;
-(MyEEventDetail *)initWithDictionary:(NSDictionary *)dic;
-(NSArray *)getDeviceType;
-(NSArray *)getTypeDevices;
@end

@interface MyEEventDevice : NSObject<NSCopying>
@property (nonatomic, strong) NSString *name;
@property (nonatomic, assign) NSInteger deviceId;
@property (nonatomic, assign) NSInteger sceneSubId; //场景中对应设备的ID
@property (nonatomic, assign) NSInteger terminalType;  //设备类型  0表示美国温度控制器，1  红外转发器，2 智能插座，3  通用控制器，4 安防设备，6智能开关
@property (nonatomic, copy) NSString *instructionName;  //插座和红外设备的控制状态
@property (nonatomic, assign) NSInteger controlMode;  //温控器当前设定状态(温控器可用，表示控制状态1：heat，2：cool，3：auto，4：emgHeat，5：off。
@property (nonatomic, assign) NSInteger point;  //温控器当前设定的温度(温控器可用) 55-90
@property (nonatomic, assign) NSInteger typeId; //设备类型：2:TV,  3: Audio, 4:Automated Curtain, 5: Other,  6 智能插座,7:通用控制器 8:智能开关   0：温控器

-(MyEEventDevice *)initWithDictionary:(NSDictionary *)dic;
-(UIImage *)changeTypeToImage;
-(NSString *)getDeviceInstructionName;
@end

@interface MyEEventDeviceAdd : NSObject
@property (nonatomic, copy) NSString *typeName;
@property (nonatomic, assign) NSInteger typeId;
@property (nonatomic, strong) NSMutableArray *devices;
@end

@interface MyEEventDeviceInstructions : NSObject
@property (nonatomic, assign) NSInteger controlMode;  //1：heat，2：cool，3：auto，4：emgHeat，5：off
@property (nonatomic, assign) NSInteger point;  //55-90
@property (nonatomic, assign) NSInteger fan;  //0：auto，1：on
@property (nonatomic, copy) NSString *channel;  //控制路数（通用控制器和开关可用）分别代表channel的开关状态，1为第一个channel的状态，
@property (nonatomic, assign) NSInteger controlStatus; //当前的控制状态，插座显示的开/关的值为：on=1，off=0、智控星表示控制指令的id号、
@property (nonatomic, strong) NSMutableArray *instructions;
-(MyEEventDeviceInstructions *)initWithJsonString:(NSString *)string;
-(MyEEventDeviceInstructions *)initWithDictionary:(NSDictionary *)dic;
-(NSArray *)controlModeArray;
-(NSArray *)pointArray;
-(NSArray *)controlStatusArray;
-(NSArray *)fanMode;
-(NSArray *)ACControlMode;
-(NSArray *)ACFanMode;
-(NSArray *)ACPointArray;
@end

@interface MyEEventConditionCustom : NSObject<NSCopying>
@property (nonatomic, assign) NSInteger conditionId;
@property (nonatomic, assign) NSInteger dataType;  //条件数据类型：1-室内温度 2-室内湿度 3-室外温度 4-室外湿度
@property (nonatomic, assign) NSInteger parameterType;  //比较关系：1-大于 2-小于 3-等于
@property (nonatomic, assign) NSInteger parameterValue;
@property (nonatomic, copy) NSString *tId;
-(MyEEventConditionCustom *)initWithDictionary:(NSDictionary *)dic;
-(NSString *)changeDataToString;
-(NSArray *)dataTypeArray;
-(NSArray *)conditionArray;
-(NSArray *)conditionDetailArray;
@end

@interface MyEEventConditionTime : NSObject<NSCopying>
@property (nonatomic, assign) NSInteger conditionId;
@property (nonatomic, assign) NSInteger timeType;  //日期类型：1-按日期 2-按星期
@property (nonatomic, assign) NSInteger minute;
@property (nonatomic, assign) NSInteger hour;
@property (nonatomic, copy) NSString *date; //日期：当timeType=1，显示为:”19/4/2014”,
@property (nonatomic, strong) NSMutableArray *weeks; //timeType=2,显示为[1,2,3,4], 当timeType=1为空
-(MyEEventConditionTime *)initWithDictionary:(NSDictionary *)dic;
-(NSString *)changeDateToString;
@end
