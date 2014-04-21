//
//  DeviceEntity.m
//  MyE
//
//  Created by space on 13-8-24.
//  Copyright (c) 2013年 MyEnergy Domain. All rights reserved.
//

#import "MyEEventDeviceEntity.h"
#import "NSDictionary+Convert.h"

@implementation MyEEventDeviceEntity

@synthesize point;
@synthesize deviceName;
@synthesize terminalType;
@synthesize controlMode;
@synthesize sceneSubId;
@synthesize deviceId;
@synthesize instructionName;

+(NSMutableArray *) getDevicesByKey:(NSString *) key jsonString:(NSString *) json
{
    NSDictionary *dic = [json JSONValue];
    NSArray *array = [dic objectForKey:key];
    NSMutableArray *retArray = [NSMutableArray arrayWithCapacity:0];
    for (int i = 0; i < array.count; i++)
    {
        NSDictionary *tempDic = [array objectAtIndex:i];
        
        MyEEventDeviceEntity *device = [[MyEEventDeviceEntity alloc] init];
        
        device.point = [tempDic valueToStringForKey:@"point"];
        device.deviceName = [tempDic valueToStringForKey:@"deviceName"];
        device.terminalType = [tempDic valueToStringForKey:@"terminalType"];
        device.controlMode = [tempDic valueToStringForKey:@"controlMode"];
        device.sceneSubId = [tempDic valueToStringForKey:@"sceneSubId"];
        device.deviceId = [tempDic valueToStringForKey:@"deviceId"];
        device.instructionName = [tempDic valueToStringForKey:@"instructionName"];
        
        [retArray addObject:device];
    }
    return retArray;
}

@end




