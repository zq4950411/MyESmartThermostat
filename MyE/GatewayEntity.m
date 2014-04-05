//
//  GatewayEntity.m
//  MyE
//
//  Created by space on 13-8-30.
//  Copyright (c) 2013年 MyEnergy Domain. All rights reserved.
//

#import "GatewayEntity.h"
#import "SmartUp.h"

@implementation GatewayEntity

@synthesize mid;
@synthesize houseName;
@synthesize timeZone;
@synthesize smartDevices;
@synthesize timeZones;

+(GatewayEntity *) getGateWay:(id) jsonString
{
    NSDictionary *dic = [jsonString JSONValue];
    
    GatewayEntity *gateway = [[GatewayEntity alloc] init];
    
    gateway.mid = [dic valueToStringForKey:@"mid"];
    gateway.houseName = [dic valueToStringForKey:@"houseName"];
    gateway.timeZones = [dic objectForKey:@"timeZoneList"];
    gateway.timeZone = [dic valueToStringForKey:@"timeZone"];
    
    NSArray *tempArray = [dic objectForKey:@"smartDevices"];
    NSMutableArray *devices = [NSMutableArray arrayWithCapacity:0];
    
    for (int i = 0; i < tempArray.count; i++)
    {
        NSDictionary *tempDic = [tempArray objectAtIndex:i];
        
        SmartUp *smart = [[SmartUp alloc] init];
        
        smart.tid = [tempDic valueToStringForKey:@"tid"];
        smart.deviceName = [tempDic valueToStringForKey:@"aliasName"];
        smart.rfStatus = [tempDic valueToStringForKey:@"rfStatus"];
        smart.typeId = [tempDic valueToStringForKey:@"terminalType"];
        smart.switchStatus = [tempDic valueToStringForKey:@"controlState"];
        
        [devices addObject:smart];
    }
    gateway.smartDevices = devices;
    
    return gateway;
}

@end
