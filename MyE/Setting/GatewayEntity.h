//
//  GatewayEntity.h
//  MyE
//
//  Created by space on 13-8-30.
//  Copyright (c) 2013年 MyEnergy Domain. All rights reserved.
//


#import "BaseObject.h"

@interface GatewayEntity : BaseObject
{
    NSString *mid;
    NSString *houseName;
    NSString *timeZone;
    
    NSMutableArray *smartDevices;//设备列表
    NSArray *timeZones;//时区列表
}

@property (nonatomic,strong) NSString *mid;
@property (nonatomic,strong) NSString *houseName;
@property (nonatomic,strong) NSString *timeZone;

@property (nonatomic,strong) NSMutableArray *smartDevices;
@property (nonatomic,strong) NSArray *timeZones;

+(GatewayEntity *) getGateWay:(id) jsonString;

@end
