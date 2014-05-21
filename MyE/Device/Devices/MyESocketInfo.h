//
//  MyESocketInfo.h
//  MyE
//
//  Created by 翟强 on 14-4-25.
//  Copyright (c) 2014年 MyEnergy Domain. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MyESocketInfo : NSObject

@property (nonatomic,strong) NSString *name;
@property (nonatomic,strong) NSString *tIdName;
@property (nonatomic) NSInteger locationId;
@property (nonatomic) NSInteger maxCurrent;

-(MyESocketInfo *)initWithJSONString:(NSString *)string;
-(MyESocketInfo *)initWithDic:(NSDictionary *)dic;
@end

@interface MyESocketControlInfo : NSObject
@property (nonatomic,strong) NSString *name;
@property (nonatomic) NSInteger currentPower;
@property (nonatomic, strong) NSString *startTime;
@property (nonatomic) NSInteger totalPower;
@property (nonatomic) NSInteger surplusMinutes;
@property (nonatomic) NSInteger switchStatus;
@property (nonatomic) NSInteger timeSet;
@property (nonatomic) NSInteger locationId;
@property (nonatomic) NSInteger maxCurrent;
-(MyESocketControlInfo *)initWithJSONString:(NSString *)string;
-(MyESocketControlInfo *)initWithDic:(NSDictionary *)dic;

@end

@interface MyESocketSchedules : NSObject
@property (nonatomic, strong) NSMutableArray *schedules;
-(MyESocketSchedules *)initWithJSONString:(NSString *)string;
-(MyESocketSchedules *)initWithDic:(NSDictionary *)dic;
@end

@interface MyESocketSchedule : NSObject<NSCopying>
@property (nonatomic, assign) NSInteger scheduleId;
@property (nonatomic, strong) NSString *onTime;
@property (nonatomic, strong) NSString *offTime;
@property (nonatomic, strong) NSMutableArray *weeks;
@property (nonatomic, assign) NSInteger runFlag;
-(MyESocketSchedule *)initWithDic:(NSDictionary *)dic;
@end