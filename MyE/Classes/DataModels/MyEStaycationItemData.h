//
//  MyEStaycationItemData.h
//  MyE
//
//  Created by Ye Yuan on 3/13/12.
//  Copyright (c) 2012 MyEnergy Domain. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MyEStaycationItemData : NSObject <NSCopying> {
    // common
    NSString *_name;
    NSString *_old_end_date;
    
    NSInteger _nightCooling;
    NSInteger _nightHeating;
    
    NSInteger _dayCooling;
    NSInteger _dayHeating;
    
    NSDate *_startDate;
    NSDate *_endDate;
    
    NSDate *_riseTime;
    NSDate *_sleepTime;
}
@property (copy, nonatomic) NSString *name;
@property (copy, nonatomic) NSString *old_end_date;

@property (nonatomic) NSInteger nightCooling;
@property (nonatomic) NSInteger nightHeating;
@property (nonatomic) NSInteger dayCooling;
@property (nonatomic) NSInteger dayHeating;

@property (retain, nonatomic) NSDate *startDate;
@property (retain, nonatomic) NSDate *endDate;
@property (retain, nonatomic) NSDate *riseTime;
@property (retain, nonatomic) NSDate *sleepTime;

- (MyEStaycationItemData *)initWithDictionary:(NSDictionary *)dictionary;
- (MyEStaycationItemData *)initWithJSONString:(NSString *)jsonString;

- (NSDictionary *)JSONDictionary;


@end
