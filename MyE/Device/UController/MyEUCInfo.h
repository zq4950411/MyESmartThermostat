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
@property (nonatomic, strong) NSString *channels;
-(MyEUCManual *)initWithJsonString:(NSString *)string;
-(MyEUCManual *)initWithDictionary:(NSDictionary *)dic;
-(NSString *)changeStringAtIndex:(NSInteger)index byString:(NSString *)str;
@end

@interface MyEUCAuto : NSObject
@property (nonatomic, strong) NSMutableArray *lists;
-(MyEUCAuto *)initWithJsonString:(NSString *)string;
-(MyEUCAuto *)initWithArray:(NSArray *)array;

@end

@interface MyEUCSchedule : NSObject
@property (nonatomic, assign) NSInteger scheduleId;
@property (nonatomic, strong) NSMutableArray *weeks;
@property (nonatomic, strong) NSString *channels;
@property (nonatomic, strong) NSMutableArray *periods;
-(MyEUCSchedule *)initWithDictionary:(NSDictionary *)dic;
-(NSString *)getWeeks;
-(NSString *)getChannels;
@end

@interface MyEUCPeriod : NSObject
@property (nonatomic, assign) NSInteger stid;
@property (nonatomic, assign) NSInteger edid;
-(MyEUCPeriod *)initWithDictionary:(NSDictionary *)dic;
@end