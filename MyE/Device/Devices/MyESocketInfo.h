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
@property (nonatomic) NSInteger currentPower;
@property (nonatomic, strong) NSString *startTime;
@property (nonatomic) NSInteger totalPower;
@property (nonatomic) NSInteger surplusMinutes;
@property (nonatomic) NSInteger switchStatus;
@property (nonatomic) NSInteger timeSet;
@property (nonatomic) NSInteger locationId;
@property (nonatomic) NSInteger maxCurrent;
-(MyESocketInfo *)initWithJSONString:(NSString *)string;
-(MyESocketInfo *)initWithDic:(NSDictionary *)dic;
@end


@interface MyESocketSchedules : NSObject
@property (nonatomic, assign) NSInteger autoMode;
@property (nonatomic, strong) NSMutableArray *schedules;
-(MyESocketSchedules *)initWithJSONString:(NSString *)string;
-(MyESocketSchedules *)initWithDic:(NSDictionary *)dic;
@end

@interface MyESocketSchedule : NSObject
@property (nonatomic, strong) NSMutableArray *periods;
@property (nonatomic, strong) NSMutableArray *weeks;
@property (nonatomic, assign) NSInteger scheduleId;
-(MyESocketSchedule *)initWithDic:(NSDictionary *)dic;
@end

@interface MyESocketPeriod : NSObject
@property (nonatomic, assign) NSInteger stid;
@property (nonatomic, assign) NSInteger etid;
-(MyESocketPeriod *)initWithDic:(NSDictionary *)dic;
@end