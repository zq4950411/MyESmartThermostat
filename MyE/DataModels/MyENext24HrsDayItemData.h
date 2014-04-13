//
//  MyENext24HrsDayItemData.h
//  MyE
//
//  Created by Ye Yuan on 7/11/12.
//  Copyright (c) 2012 MyEnergy Domain. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MyENext24HrsDayItemData : NSObject<NSCopying> 

@property (nonatomic) NSInteger year;
@property (nonatomic) NSInteger month;// 1~12
@property (nonatomic) NSInteger date;// 根据月份不同，取值范围可能是1~、28、29、30、31
@property (retain, nonatomic) NSMutableArray *periods;


- (MyENext24HrsDayItemData *)initWithDictionary:(NSDictionary *)dictionary;
- (MyENext24HrsDayItemData *)initWithJSONString:(NSString *)jsonString;

- (NSDictionary *)JSONDictionary;
@end
