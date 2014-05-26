//
//  MyEUsageStat.h
//  MyEHomeCN2
//
//  Created by 翟强 on 14-3-4.
//  Edited by Ye Yuan 2014-5-24
//  Copyright (c) 2014年 My Energy Domain Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
@class MyEUsageRecord;
@interface MyEUsageStat : NSObject<NSCopying> 

@property(nonatomic, strong) NSMutableArray *powerRecordList;
@property(nonatomic) float currentPower;
@property(nonatomic) float totalPower;
@property(nonatomic, strong) MyEUsageRecord *elecStatus;

-(MyEUsageStat *)initWithString:(NSString *)string;
-(MyEUsageStat *)initWithDictionary:(NSDictionary *)dic;
- (NSDictionary *)JSONDictionary;
@end


@interface MyEUsageRecord : NSObject<NSCopying> 

@property(nonatomic, strong) NSString *date;
@property(nonatomic) float totalPower;

-(MyEUsageRecord *)initWithString:(NSString *)string;
-(MyEUsageRecord *)initWithDictionary:(NSDictionary *)dic;
- (NSDictionary *)JSONDictionary;
@end
