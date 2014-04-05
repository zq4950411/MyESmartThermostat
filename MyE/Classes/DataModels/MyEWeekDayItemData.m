//
//  MyEWeekDayItemData.m
//  MyE
//
//  Created by Ye Yuan on 2/29/12.
//  Copyright (c) 2012 MyEnergy Domain. All rights reserved.
//

#import "MyEWeekDayItemData.h"
#import "MyEWeeklyPeriodData.h"
#import "SBJson.h"
#import "MyEUtil.h"

@implementation MyEWeekDayItemData
@synthesize dayId = _dayId, periods = _periods;
- (id)init {
    if (self = [super init]) {
        _dayId = 0;
        _periods = [[NSMutableArray alloc] init];
        return self;
    }
    return nil;
}



- (MyEWeekDayItemData *)initWithDictionary:(NSDictionary *)dictionary
{
    _periods = [[NSMutableArray alloc] init];
    self.dayId = [[dictionary objectForKey:@"dayId"] intValue];
    NSArray *periodsInDict = [dictionary objectForKey:@"periods"];
    NSMutableArray *periods = [NSMutableArray array];
    for (NSDictionary *period in periodsInDict) {
        [periods addObject:[[MyEWeeklyPeriodData alloc] initWithDictionary:period]];
    }
    
    // 这里必须调用 - (void) setPeriods:(NSArray *)periods，在其中由根据periods生成新的metaModeArray的代码。
    self.periods = periods;
    
    return self;
}

- (MyEWeekDayItemData *)initWithJSONString:(NSString *)jsonString
{
    // Create new SBJSON parser object
    SBJsonParser *parser = [[SBJsonParser alloc] init];
    // 把JSON转为字典    
    NSDictionary *dict = [parser objectWithString:jsonString error:nil];
    
    MyEWeekDayItemData *day = [[MyEWeekDayItemData alloc] initWithDictionary:dict];
    return day;
}

- (NSDictionary *)JSONDictionary
{
    NSMutableArray *periods = [NSMutableArray array];
    
    for (MyEWeeklyPeriodData *period in self.periods)
        [periods addObject:[period JSONDictionary]];
    
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                          [NSString stringWithFormat:@"%i",self.dayId], @"dayId",
                          periods, @"periods",
                          
                          nil ];
    return dict;
}
-(id)copyWithZone:(NSZone *)zone {
    return [[MyEWeekDayItemData alloc] initWithDictionary:[self JSONDictionary]];
}
-(void)updatePeriodWithAnother:(MyEWeekDayItemData *)another {
    self.periods = [another.periods copy];
}
-(NSString *)description
{
    NSMutableString *desc = [NSMutableString stringWithFormat:@"\ndayId = %i , \nperiods:[",_dayId];
    for (MyEWeeklyPeriodData *period in self.periods)
        [desc appendString:[NSString stringWithFormat:@"{\n%@\n}",[period description]]];
    [desc appendString:@"\n]"];
    return desc;
}

@end
