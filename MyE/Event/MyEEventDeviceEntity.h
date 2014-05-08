//
//  DeviceEntity.h
//  MyE
//
//  Created by space on 13-8-24.
//  Copyright (c) 2013年 MyEnergy Domain. All rights reserved.
//

#import "BaseObject.h"
    
@interface MyEEventDeviceEntity : BaseObject
{
    NSString *point;
    NSString *deviceName;
    NSString *terminalType;
    NSString *controlMode;
    NSString *sceneSubId;
    NSString *deviceId;
    NSString *instructionName;
}

@property (nonatomic,strong) NSString *point;
@property (nonatomic,strong) NSString *deviceName;
@property (nonatomic,strong) NSString *terminalType;
@property (nonatomic,strong) NSString *controlMode;
@property (nonatomic,strong) NSString *sceneSubId;
@property (nonatomic,strong) NSString *deviceId;
@property (nonatomic,strong) NSString *instructionName;

+(NSMutableArray *) getDevicesByKey:(NSString *) key jsonString:(NSString *) json;

@end
