//
//  MyEThermostatDayData.h
//  MyE
//  用于Thermostat Weekly Schedule / Thermostat SpecialDays Schedule
// 
//  Created by Ye Yuan on 2/29/12.
//  Copyright (c) 2012 MyEnergy Domain. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MyEThermostatDayData : NSObject <NSCopying> 
@property (nonatomic) NSInteger dayId;
//title仅用于SpecialDays, Weekly情况, 就用默认的Mon,Tue, Wed.....
@property (retain, nonatomic) NSString *name;
@property (retain, nonatomic) NSMutableArray *periods;


- (MyEThermostatDayData *)initWithDictionary:(NSDictionary *)dictionary;
- (MyEThermostatDayData *)initWithJSONString:(NSString *)jsonString;

- (NSDictionary *)JSONDictionary;

-(void)updatePeriodWithAnother:(MyEThermostatDayData *)another;
@end
