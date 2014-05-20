//
//  MyEThermostatPeriodData.h
//  MyE
//  用于Thermostat Weekly Schedule / Thermostat SpecialDays Schedule
//
//  Created by Ye Yuan on 2/29/12.
//  Copyright (c) 2012 MyEnergy Domain. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MyEScheduleModeData;


@interface MyEThermostatPeriodData : NSObject <NSCopying> 
{
    NSInteger _stid;//需要注意，stid的取值范围可能是0到47，0表示今天的凌晨12:00AM
    NSInteger _etid;//需要注意，etid的取值范围可能是1到48，48表示第二天的凌晨12:00AM
    NSInteger _modeId; 
}
@property (nonatomic) NSInteger stid;
@property (nonatomic) NSInteger etid;
@property (nonatomic) NSInteger modeId; 



- (MyEThermostatPeriodData *)initWithDictionary:(NSDictionary *)dictionary;
- (NSDictionary *)JSONDictionary;

@end
