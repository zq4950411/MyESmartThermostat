//
//  MyEUsageStat.h
//  MyEHomeCN2
//
//  Created by 翟强 on 14-3-4.
//  Edited by Ye Yuan 2014-5-24
//  Copyright (c) 2014年 My Energy Domain Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
@class MyEUsageStatus;
@interface MyEUsageStat : NSObject<NSCopying> 

@property(nonatomic, strong) NSMutableArray *powerRecordList;
@property(nonatomic) float currentPower;
@property(nonatomic) float totalPower;
@property(nonatomic, strong) MyEUsageStatus *elecStatus;

-(MyEUsageStat *)initWithString:(NSString *)string;
-(MyEUsageStat *)initWithDictionary:(NSDictionary *)dic;
- (NSDictionary *)JSONDictionary;
@end


@interface MyEUsageStatus : NSObject<NSCopying> 

@property(nonatomic, strong) NSString *date;
@property(nonatomic) float totalPower;

-(MyEUsageStatus *)initWithString:(NSString *)string;
-(MyEUsageStatus *)initWithDictionary:(NSDictionary *)dic;
- (NSDictionary *)JSONDictionary;
@end
