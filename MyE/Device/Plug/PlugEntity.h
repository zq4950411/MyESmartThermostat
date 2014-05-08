//
//  PlugEntity.h
//  MyE
//
//  Created by space on 13-8-20.
//  Copyright (c) 2013年 MyEnergy Domain. All rights reserved.
//

#import "BaseObject.h"

@interface PlugEntity : BaseObject
{
    NSString *aliasName;
    NSString *locationId;
    NSArray *locationList;
    NSString *maximalCurrent;
    NSString *realPower;
    NSString *startTime;
    NSString *surplusMinutes;
    NSString *switchStatus;
    NSString *timerSet;
    NSString *totalPower;
    NSString *locationName;
}

@property (nonatomic,strong) NSString *aliasName;
@property (nonatomic,strong) NSString *locationId;
@property (nonatomic,strong) NSArray *locationList;
@property (nonatomic,strong) NSString *maximalCurrent;
@property (nonatomic,strong) NSString *realPower;
@property (nonatomic,strong) NSString *startTime;
@property (nonatomic,strong) NSString *surplusMinutes;
@property (nonatomic,strong) NSString *switchStatus;
@property (nonatomic,strong) NSString *timerSet;
@property (nonatomic,strong) NSString *totalPower;
@property (nonatomic,strong) NSString *locationName;

+(PlugEntity *) getPlug:(id) json;

@end
