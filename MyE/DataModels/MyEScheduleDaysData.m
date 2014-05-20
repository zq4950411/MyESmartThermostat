//
//  MyEScheduleWeeklyData.m
//  MyE
//
//  Created by Ye Yuan on 2/29/12.
//  Copyright (c) 2012 MyEnergy Domain. All rights reserved.
//

#import "MyEScheduleDaysData.h"
#import "MyEThermostatDayData.h"
#import "MyEThermostatPeriodData.h"
#import "MyEScheduleModeData.h"
#import "MyENext24HrsPeriodData.h"
#import "MyEUtil.h"
#import "SBJson.h"

@implementation MyEScheduleDaysData
- (id)init {
    if (self = [super init]) {
        _userId = @"1000100000000000831";
        _houseId = @"5379";
        _locWeb = @"Disabled";
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"MM/dd/yyyy HH:mm"];
        _currentTime = [dateFormatter stringFromDate:[NSDate date]];
        
        _dayItems = [[NSMutableArray alloc] init];
        _metaModeArray = [[NSMutableArray alloc] init];
        return self;
    }
    return nil;
}


- (MyEScheduleDaysData *)initWithDictionary:(NSDictionary *)dictionary
{
    _dayItems = [[NSMutableArray alloc] init];
    self.userId = [dictionary objectForKey:@"userId"];
    self.houseId = [dictionary objectForKey:@"houseId"];
    self.locWeb = [dictionary objectForKey:@"locWeb"];
    self.currentTime = [dictionary objectForKey:@"currentTime"];
    NSArray *dayItemsInDict = [dictionary objectForKey:@"dayItems"];
    NSMutableArray *dayItems = [NSMutableArray array];
    
    // 注意这里dayId和星期几的对应关系是(按照在dayItems里面传来的顺序排列):6-Sun, 0-Mon, 1-Tue, 2-Wed, 3-Thu, 4-Fri, 5-Sat
    for (NSDictionary *dayItem in dayItemsInDict) {
        [dayItems addObject:[[MyEThermostatDayData alloc] initWithDictionary:dayItem]];
    }
    self.dayItems = dayItems;
    
    NSArray *modesInDict = [dictionary objectForKey:@"modes"];
    NSMutableArray *metaModeArray = [NSMutableArray array];
    for (int i = 0; i < [modesInDict count]; i++) {
        [metaModeArray addObject:[[MyEScheduleModeData alloc] initWithDictionary:[modesInDict objectAtIndex:i]]];
    }
    
    self.metaModeArray = metaModeArray;
    
    return self;
}

- (MyEScheduleDaysData *)initWithJSONString:(NSString *)jsonString
{
    // Create new SBJSON parser object
    SBJsonParser *parser = [[SBJsonParser alloc] init];
    // 把JSON转为字典    
    NSDictionary *dict = [parser objectWithString:jsonString error:nil];
    if (dict && [dict isKindOfClass:[NSDictionary class]]) {
        MyEScheduleDaysData *weekly = [[MyEScheduleDaysData alloc] initWithDictionary:dict];
        return weekly;
    } else return nil;
}

- (NSDictionary *)JSONDictionary
{
    // 这里把self.dayItems里面的每个dayItem对象进行json序列化后放入数组dayItems。这样才能把数组dayItems进行正确的JSON序列化
    NSMutableArray *dayItems = [NSMutableArray array];
    for (MyEThermostatDayData *dayItem in self.dayItems)
        [dayItems addObject:[dayItem JSONDictionary]];
    
    /* 注意， Thermostat Weekly Schedule :在服务器传递的数据中，dayItem的dayId对应的关系是：0-Mod, 1-Tue, ..., 5-Sat, 6-Sun, 这个在本程序里面没有用到，
     * 但是服务器程序把dayItem的顺序调整成[{6-Sun}, {0-Mon}, {1-Tue}, {2-Wed}, {3-Thu}, {4-Fri}, {5-Sat}]。
     * 对每个Day的Schedule的任何改变，直接写到对应的dayItems的元素中，所以在我们应用里面不要考虑dayItem自带的dayId属性。
     * 为了区分在服务器传递的数据中dayItem的dayId属性和我们这里的自己的day排序，这里我们都用变量dayId做day的id
     * 我们在这里保存的dayItems中的dayId和day对应关系以及dayItem顺序是: 0-Sun, 1-Mon, 2-Tue, 3-Wed, 4-Thu, 5-Fri, 6-Sat。
     */
    NSMutableArray *modes = [NSMutableArray array];
    for (MyEScheduleModeData *mode in self.metaModeArray)
        [modes addObject:[mode JSONDictionary]];
    
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                          self.userId, @"userId",
                          self.houseId, @"houseId",
                          self.locWeb, @"locWeb",
                          self.currentTime, @"currentTime",
                          dayItems, @"dayItems",//这里不能把self.dayItems直接放在值的位置，因为其中数组的每个元素没有正确地进行JSON字符串序列化
                          modes, @"modes",//这里不能把self.metaModeArray直接放在值的位置，因为其中数组的每个元素没有正确地进行JSON字符串序列化
                          nil ];
    return dict;
}

-(id)copyWithZone:(NSZone *)zone {
    return [[MyEScheduleDaysData alloc] initWithDictionary:[self JSONDictionary]];
}
-(NSString *)description
{
    NSMutableString *desc = [NSMutableString stringWithFormat:@"userId = (%@), houseId = %@, locWeb = %@, currentTime = %@,  \ndayItems:\n", _userId, _houseId, _locWeb, _currentTime];
    for (MyEThermostatDayData *day in self.dayItems)
        [desc appendString:[NSString stringWithFormat:@"\n{%@}",[day description]]];
    [desc appendString:@"\nmodes:\n"];
    for (MyEScheduleModeData *mode in self.metaModeArray)
        [desc appendString:[mode description]];
    return desc;
}



/* 注意，在服务器传递的数据中，dayItem的dayId对应的关系是：0-Mod, 1-Tue, ..., 5-Sat, 6-Sun, 这个在本程序里面没有用到，
 * 但是服务器程序把dayItem的顺序调整成[{6-Sun}, {0-Mon}, {1-Tue}, {2-Wed}, {3-Thu}, {4-Fri}, {5-Sat}]。
 * 对每个Day的Schedule的任何改变，直接写到对应的dayItems的元素中，所以在我们应用里面不要考虑dayItem自带的dayId属性。
 * 为了区分在服务器传递的数据中dayItem的dayId属性和我们这里的自己的day排序，这里我们都用变量dayId做day的id
 * 我们在这里保存的dayItems中的dayId和day对应关系以及dayItem顺序是: 0-Sun, 1-Mon, 2-Tue, 3-Wed, 4-Thu, 5-Fri, 6-Sat。
 */
// 下面函数作用是取得每个半小时对应的mode的modeId所构成的数组，数组元素是48个
- (NSMutableArray *) modeIdArrayForDayId:(NSUInteger)dayId
{
    NSMutableArray *modeArray = [[NSMutableArray alloc] init];
    MyEThermostatDayData * dayItem = [self.dayItems objectAtIndex:dayId];
    int count = [dayItem.periods count];
    for (int i = 0; i < count; i++) {
        MyEThermostatPeriodData *period = [dayItem.periods objectAtIndex:i];

        for (int j = period.stid; j < period.etid; j++) {

            [modeArray addObject:[NSNumber numberWithInt:period.modeId]];
        }
    }
    
    return  modeArray;
}
-(MyEScheduleModeData *)getModeDataByModeId:(NSInteger)modeId {
    for (NSInteger i = 0; i < [self.metaModeArray count]; i++) {
        MyEScheduleModeData *mode = [self.metaModeArray objectAtIndex:i];
        if(modeId == mode.modeId)
            return mode;
    }
    return nil;
}
// 下面函数作用是取得给定dayId那一天的由MyETodayPeriodData对象构成的时段数组
// 此函数的主要作用是和Today面板公用MyEPeriodDoughnutView类来显示圆环上的提示信息，
// 那里要用MyETodayPeriodData对象构成的数组，也就是一个Today数据的时段数组
- (NSMutableArray *) periodsForDayId:(NSUInteger)dayId {
    NSMutableArray *periods = [NSMutableArray array]; 
    MyEThermostatDayData *dayItem = [self.dayItems objectAtIndex:dayId];
    for (MyEThermostatPeriodData *weeklyPeriod in dayItem.periods) {
        MyENext24HrsPeriodData *todayPeriod = [[MyENext24HrsPeriodData alloc] init];
        todayPeriod.stid = weeklyPeriod.stid;
        todayPeriod.etid = weeklyPeriod.etid;
        MyEScheduleModeData *mode = [self getModeDataByModeId:weeklyPeriod.modeId];
        if(mode) {
            todayPeriod.color = mode.color;
            todayPeriod.heating = mode.heating;
            todayPeriod.cooling = mode.cooling;
        }
        [periods addObject:todayPeriod];
    }
    return periods;
}

// 根据metaModeArray取得每个mode到颜色的映射词典。创建这个词典的目的是只把modeId及其对应的UIColor对象传递到MyEDoughnutView对象，而不直接把MyEScheduleModeData对象传入，从而保持model和view的尽量分离
- (NSMutableDictionary *)modeIdColorDictionary
{
    NSMutableDictionary *mcDictionary = [NSMutableDictionary dictionary];

    for (MyEScheduleModeData *mode in self.metaModeArray)
    {
        UIColor *color= [mode color];
        [mcDictionary setObject:color forKey:[NSNumber numberWithInteger:mode.modeId]];
    }

    return mcDictionary;
}

// 判定给定的名字或颜色是否已经被其他mode使用
- (BOOL) isModeNameInUse:(NSString *)name  exceptCurrentModeId:(NSInteger)modeId{
    for (MyEScheduleModeData *mode in self.metaModeArray) {
        if ([mode.modeName caseInsensitiveCompare:name] == NSOrderedSame && mode.modeId != modeId) {
            return YES;
        }
    }
    return NO;
}
- (BOOL) isModeColorInUse:(UIColor *)color  exceptCurrentModeId:(NSInteger)modeId{
    for (MyEScheduleModeData *mode in self.metaModeArray) {
        if([mode.color isEqual:color] && mode.modeId != modeId)
            return YES;
    }
    return NO;
}
@end
