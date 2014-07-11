//
//  MyEUCInfo.h
//  MyE
//
//  Created by 翟强 on 14-6-6.
//  Copyright (c) 2014年 MyEnergy Domain. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MyEUCInfo : NSObject

@end

@interface MyEUCManual : NSObject
@property (nonatomic, copy) NSString *channels;
-(MyEUCManual *)initWithJsonString:(NSString *)string;
-(MyEUCManual *)initWithDictionary:(NSDictionary *)dic;
-(NSString *)changeStringAtIndex:(NSInteger)index byString:(NSString *)str;
@end

@interface MyEUCAuto : NSObject
@property (nonatomic, strong) NSMutableArray *lists;
-(MyEUCAuto *)initWithJsonString:(NSString *)string;
-(MyEUCAuto *)initWithArray:(NSArray *)array;

@end

@interface MyEUCSchedule : NSObject<NSCopying>
@property (nonatomic, assign) NSInteger scheduleId;
@property (nonatomic, strong) NSMutableArray *weeks;
@property (nonatomic, copy) NSString *channels;
@property (nonatomic, strong) NSMutableArray *periods;
-(MyEUCSchedule *)initWithDictionary:(NSDictionary *)dic;
-(NSString *)getWeeks;
-(NSString *)getChannels;
-(NSArray *)getChannelArray;
-(NSString *)jsonSchedule;
@end

@interface MyEUCPeriod : NSObject<NSCopying>
@property (nonatomic, assign) NSInteger stid;
@property (nonatomic, assign) NSInteger edid;
-(MyEUCPeriod *)initWithDictionary:(NSDictionary *)dic;
-(NSDictionary *)jsonUCPeriod;
@end

@interface MyEUCSequential : NSObject
@property (nonatomic, strong) NSString *startTime;
@property (nonatomic, strong) NSMutableArray *weeks;
@property (nonatomic, assign) NSInteger preConditon;
@property (nonatomic, assign) NSInteger temperature;
@property (nonatomic, strong) NSMutableArray *sequentialOrder;
-(MyEUCSequential *)initWithJsonString:(NSString *)string;
-(MyEUCSequential *)initWithDictionary:(NSDictionary *)dic;
-(NSString *)jsonSequential;
-(NSArray *)conditionArray;
@end

@interface MyEUCChannelInfo : NSObject<NSCopying>
@property (nonatomic, assign) NSInteger channel;
@property (nonatomic, assign) NSInteger duration;
@property (nonatomic, assign) NSInteger orderId;
-(MyEUCChannelInfo *)initWithDictionary:(NSDictionary *)dic;
-(NSDictionary *)jsonUCChannel;
@end