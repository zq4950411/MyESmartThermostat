//
//  DashboardData.h
//  MyE
//
//  Created by Ye Yuan on 1/19/12.
//  Copyright (c) 2012 MyEnergy Domain. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MyEDashboardData : NSObject <NSCopying> 
@property (nonatomic, copy) NSString *locWeb;
@property (nonatomic) unsigned int isheatcool;
@property (nonatomic) unsigned int setpoint;
@property (nonatomic) unsigned int stageLevel;
@property (nonatomic) unsigned int controlMode;
@property (nonatomic, copy) NSString *realControlMode;
@property (nonatomic) float temperature;//indoor temperature;
@property (nonatomic) unsigned int isOvrried;
@property (nonatomic) unsigned int fan_control;
@property (nonatomic, copy) NSString *fan_status;
@property (nonatomic, copy) NSString *currentProgram;
@property (nonatomic) NSInteger con_hp;//紧急加热是否允许
@property (nonatomic) NSInteger aux;//紧急加热是否允许
@property (nonatomic) NSInteger energyLeaver;// 节能类型

- (MyEDashboardData *)initWithDictionary:(NSDictionary *)dictionary;
- (MyEDashboardData *)initWithJSONString:(NSString *)jsonString;
- (NSDictionary *)JSONDictionary;
@end
