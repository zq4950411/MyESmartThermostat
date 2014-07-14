//
//  MyEThermostatDayData.m
//  MyE
//
//  Created by Ye Yuan on 2/29/12.
//  Copyright (c) 2012 MyEnergy Domain. All rights reserved.
//

#import "MyEThermostatDayData.h"
#import "MyEThermostatPeriodData.h"
#import "SBJson.h"
#import "MyEUtil.h"

@implementation MyEThermostatDayData
- (id)init {
    if (self = [super init]) {
        _dayId = 0;
        _name = @"Noname";
        _periods = [[NSMutableArray alloc] init];
        return self;
    }
    return nil;
}

- (MyEThermostatDayData *)initWithDictionary:(NSDictionary *)dictionary
{
    _periods = [[NSMutableArray alloc] init];
    self.dayId = [dictionary objectForKey:@"dayId"]==[NSNull null]?-1:[[dictionary objectForKey:@"dayId"] intValue];
    _name = [dictionary objectForKey:@"name"]?[dictionary objectForKey:@"name"]:@"";
    NSArray *periodsInDict = [dictionary objectForKey:@"periods"];
    NSMutableArray *periods = [NSMutableArray array];
    for (NSDictionary *period in periodsInDict) {
        [periods addObject:[[MyEThermostatPeriodData alloc] initWithDictionary:period]];
    }
    
    // 这里必须调用 - (void) setPeriods:(NSArray *)periods，在其中由根据periods生成新的metaModeArray的代码。
    self.periods = periods;
    
    return self;
}

- (MyEThermostatDayData *)initWithJSONString:(NSString *)jsonString
{
    // Create new SBJSON parser object
    SBJsonParser *parser = [[SBJsonParser alloc] init];
    // 把JSON转为字典    
    NSDictionary *dict = [parser objectWithString:jsonString error:nil];
    
    MyEThermostatDayData *day = [[MyEThermostatDayData alloc] initWithDictionary:dict];
    return day;
}

- (NSDictionary *)JSONDictionary
{
    NSMutableArray *periods = [NSMutableArray array];
    
    for (MyEThermostatPeriodData *period in self.periods)
        [periods addObject:[period JSONDictionary]];
    
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                          [NSString stringWithFormat:@"%i",self.dayId], @"dayId",
                          self.name, @"name",
                          periods, @"periods",
                          nil ];
    return dict;
}
-(NSString *)jsonSelf{
    SBJsonWriter *writer = [[SBJsonWriter alloc] init];
    NSMutableArray *array = [NSMutableArray array];
    for (MyEThermostatPeriodData *d in self.periods) {
        [array addObject:[d JSONDictionary]];
    }
    NSDictionary *dic = @{@"periods": array,
                          @"specialName":self.name};
    NSString *str = [writer stringWithObject:dic];
    NSLog(@"str is %@",str);
    return str;
}
-(id)copyWithZone:(NSZone *)zone {
    return [[MyEThermostatDayData alloc] initWithDictionary:[self JSONDictionary]];
//    MyEThermostatDayData *copy = [[[self class] allocWithZone:zone] init];
//    copy.dayId = self.dayId;
//    copy.name = self.name;
//    copy.periods = [self.periods copy];
//    return copy;
}
-(void)updatePeriodWithAnother:(MyEThermostatDayData *)another {
    self.periods = [another.periods copy];
}
-(NSString *)description
{
    return [NSString stringWithFormat:@"periods:%@ \n dayId:%i",self.periods,self.dayId];
//    NSMutableString *desc = [NSMutableString stringWithFormat:@"\ndayId = %i , name = %@, \nperiods:[",_dayId, self.name];
//    for (MyEThermostatPeriodData *period in self.periods)
//        [desc appendString:[NSString stringWithFormat:@"{\n%@\n}",[period description]]];
//    [desc appendString:@"\n]"];
//    return desc;
}

@end
