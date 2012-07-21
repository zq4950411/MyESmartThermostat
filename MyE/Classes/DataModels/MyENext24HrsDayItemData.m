//
//  MyENext24HrsDayItemData.m
//  MyE
//
//  Created by Ye Yuan on 7/11/12.
//  Copyright (c) 2012 MyEnergy Domain. All rights reserved.
//

#import "MyENext24HrsDayItemData.h"
#import "MyETodayPeriodData.h"
#import "SBJson.h"
#import "MyEUtil.h"

@implementation MyENext24HrsDayItemData
@synthesize year = _year, month = _month, date = _date,  periods = _periods;
- (id)init {
    if (self = [super init]) {
        self.date = 0;
        self.year = 2012;
        self.month = 7;
        _periods = [[NSMutableArray alloc] init];
        return self;
    }
    return nil;
}



- (MyENext24HrsDayItemData *)initWithDictionary:(NSDictionary *)dictionary
{
    _periods = [[NSMutableArray alloc] init];
    self.year = [[dictionary objectForKey:@"year"] intValue];
    self.month = [[dictionary objectForKey:@"month"] intValue];
    self.date = [[dictionary objectForKey:@"date"] intValue];
    NSArray *periodsInDict = [dictionary objectForKey:@"periods"];
    NSMutableArray *periods = [NSMutableArray array];
    for (NSDictionary *period in periodsInDict) {
        [periods addObject:[[MyETodayPeriodData alloc] initWithDictionary:period]];
    }
    
    // 这里必须调用 - (void) setPeriods:(NSArray *)periods，在其中由根据periods生成新的metaModeArray的代码。
    self.periods = periods;
    
    return self;
}

- (MyENext24HrsDayItemData *)initWithJSONString:(NSString *)jsonString
{
    // Create new SBJSON parser object
    SBJsonParser *parser = [[SBJsonParser alloc] init];
    // 把JSON转为字典    
    NSDictionary *dict = [parser objectWithString:jsonString error:nil];
    
    MyENext24HrsDayItemData *day = [[MyENext24HrsDayItemData alloc] initWithDictionary:dict];
    return day;
}

- (NSDictionary *)JSONDictionary
{
    NSMutableArray *periods = [NSMutableArray array];
    
    for (MyETodayPeriodData *period in self.periods)
        [periods addObject:[period JSONDictionary]];
    
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                          [NSString stringWithFormat:@"%i",self.year], @"year",
                          [NSString stringWithFormat:@"%i",self.month], @"month",
                          [NSString stringWithFormat:@"%i",self.date], @"date",
                          periods, @"periods",
                          
                          nil ];
    return dict;
}


-(id)copyWithZone:(NSZone *)zone {
    return [[MyENext24HrsDayItemData alloc] initWithDictionary:[self JSONDictionary]];
}
-(void)updatePeriodWithAnother:(MyENext24HrsDayItemData *)another {
    self.periods = [another.periods copy];
}
-(NSString *)description
{
    NSMutableString *desc = [NSMutableString stringWithFormat:@"\nyear = %i ,\nmonth = %i ,\ndate = %i , \nperiods:[",self.year, self.month, self.date];
    for (MyETodayPeriodData *period in self.periods)
        [desc appendString:[NSString stringWithFormat:@"{\n%@\n}",[period description]]];
    [desc appendString:@"\n]"];
    return desc;
}

@end
