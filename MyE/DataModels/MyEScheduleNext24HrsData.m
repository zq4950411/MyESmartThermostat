// aaaa
//  MyEScheduleNext24HrsData.m
//  MyE
//
//  Created by Ye Yuan on 7/10/12.
//  Copyright (c) 2012 MyEnergy Domain. All rights reserved.
//

#import "MyEScheduleNext24HrsData.h"
#import "MyENext24HrsDayItemData.h"
#import "MyENext24HrsPeriodData.h"
#import "MyEScheduleModeData.h"
#import "MyEUtil.h"
#import "SBJson.h"
@implementation MyEScheduleNext24HrsData
@synthesize userId = _useId, 
houseId = _houseId, 
currentTime = _currentTime,
locWeb = _locWeb,
weeklyId = _weeklyId, 
setpoint = _setpoint, 
hold = _hold, 
dayItems = _dayItems, 
periods = _periods,
metaModeArray = _metaModeArray;

- (id)init {
    if (self = [super init]) {
        _useId = @"1000100000000000831";
        _houseId = @"5379";
        _locWeb = @"Disabled";
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"MM/dd/yyyy HH:mm"];
        _currentTime = [dateFormatter stringFromDate:[NSDate date]];
        
        _weeklyId = 0;
        _setpoint = 77;
        _hold = 1;
        _dayItems = [[NSMutableArray alloc] init];
        _metaModeArray = [[NSMutableArray alloc] init];
        
        _periods = [[NSMutableArray alloc] init];
        
        return self;
    }
    return nil;
}

- (MyEScheduleNext24HrsData *)initWithDictionary:(NSDictionary *)dictionary
{
    if (self = [super init]) {
        self.userId = [dictionary objectForKey:@"userId"];
        self.houseId = [dictionary objectForKey:@"houseId"];
        self.locWeb = [dictionary objectForKey:@"locWeb"];
        self.weeklyId = [[dictionary objectForKey:@"weeklyId"] intValue];
        self.setpoint = [[dictionary objectForKey:@"setpoint"] intValue];
        self.hold = [[dictionary objectForKey:@"hold"] intValue];
        self.currentTime = [dictionary objectForKey:@"currentTime"];
        
        NSArray *dayItemsInDict = [dictionary objectForKey:@"dayItems"];
        NSMutableArray *dayItems = [NSMutableArray array];
        // 注意这里dayId和星期几的对应关系是(按照在dayItems里面传来的顺序排列):6-Sun, 0-Mon, 1-Tue, 2-Wed, 3-Thu, 4-Fri, 5-Sat
        for (NSDictionary *dayItem in dayItemsInDict) {
            [dayItems addObject:[[MyENext24HrsDayItemData alloc] initWithDictionary:dayItem]];
        }
        self.dayItems = dayItems;

        self.periods = [self computePeriodsFromDayItems];
        
        return self;
    }
    return nil;
}

- (MyEScheduleNext24HrsData *)initWithJSONString:(NSString *)jsonString
{
    // Create new SBJSON parser object
    SBJsonParser *parser = [[SBJsonParser alloc] init];
    // 把JSON转为字典  
    NSError *error = [[NSError alloc] init];
    NSDictionary *dict = [parser objectWithString:jsonString error:&error];
    if (dict && [dict isKindOfClass:[NSDictionary class]]) {
        MyEScheduleNext24HrsData *next24Hrs = [[MyEScheduleNext24HrsData alloc] initWithDictionary:dict];
        return next24Hrs;
    } else return nil;
}

#pragma mark -
#pragma mark  模拟MyEScheduleToday.h类中的属性periods的设置和获取方法。
// 根据服务器传来的2天的时段数据(保存在dayItems数组里)，返回在Next24Hrs面板上显示的、刚好落在24小时之内的时段periods数组，
// 并且各时段的stid、etid都是转换成从0计数的48半点形式了，也就是把当前时段的整点作为0
- (NSMutableArray *)computePeriodsFromDayItems {
    NSMutableArray *periods = [NSMutableArray array];// 生成空时段
    NSInteger currentHr = [self getHoursForCurrentTime]; //取得当前时刻所在的整点，也就是圆环Y正轴位置所在的整点
    NSInteger currentHalfHr = currentHr * 2;// 开始的整点转换成半点形式
    NSInteger zeroHourSectorId = (NUM_SECTOR - currentHalfHr) % NUM_SECTOR; // 在next24Hrs中，零点所在的圆环上的sector序号，如果是48，就取0 
    
    MyENext24HrsDayItemData *todayItem = [self.dayItems objectAtIndex:0];// 取得今天的数据对象
    MyENext24HrsDayItemData *nextDayItem = [self.dayItems objectAtIndex:1]; // 取得第二天的数据对象
    
    // 1 首先对今天的时段进行处理，寻找当前时刻之后的数据今天的所有时段，把它们放到结果数组里。第一个时段有可能是拆分而来的。
    MyENext24HrsPeriodData *lastPeriodOfToday; // 保存今天的时段数组中的最后一个时段
    for (NSInteger i = 0; i < [todayItem.periods count]; i++) {// 对今天的每个时段进行分析处理
        MyENext24HrsPeriodData *period = [todayItem.periods objectAtIndex:i];// 取得第i个时段
        MyENext24HrsPeriodData *newPeriod = [period copy]; // 克隆该时段为一个新对象

        // 对时段period进行测试，如果它的开始时刻小于等于当前时刻，并且其结束时刻大于当前时刻， 表示碰到正在运行的时段，也就是将在next24Hrs圆环上Y正轴方向出现的第一个时段
        if(period.stid <= currentHalfHr && period.etid >= currentHalfHr) {
            newPeriod.stid = 0;//设置该时段开始时刻是0
            newPeriod.etid -= currentHalfHr;// 该时段的结束时刻进行转换到next24Hrs空间
            if(newPeriod.stid < newPeriod.etid){// 如果此时段的结束刚好有可能位于0点，此时就不能添加此，略过，找下一个
                [periods addObject:newPeriod]; // 把此找到的时段添加到结果数据库
                lastPeriodOfToday = newPeriod;//用于记录下今天的最后一个时段转换后在next24hrs下的对象
            }
        } else if(period.stid > currentHalfHr) {// 如果当前正在测试的的时段的开始时刻在当前时刻之后，就添加它到结果数组
            newPeriod.stid -= currentHalfHr;
            newPeriod.etid -= currentHalfHr;
            [periods addObject:newPeriod];
            lastPeriodOfToday = newPeriod;//用于记录下今天的最后一个时段转换后在next24hrs下的对象
        }
    }
    
    // 2 对第二天的时段数组进行处理，把第二天里落在next 24 hrs之内的时段都添加到结果数组，最后一个时段有可能是拆分而来，而凌晨的时段有可能拼接到今天的最后一个时段。
    // 在分析第二天时段之前，需要进行判定。
    // 有可能在当前正在运行在0点到1:00之前这个时间时，self.periods的最后一个时段的结束半点时刻刚好是48，就不用再从第二天里面取数据，就可以退出了
    // 只有在lastPeriodOfToday.etid < NUM_SECTOR（即48） 时，也就是已经添加到结果数组的时段还没达到48个半点时，才需要从第二天取数据。
    if (lastPeriodOfToday.etid < NUM_SECTOR) { // 如果已经添加进self.periods的最后一个时段的结束不是48,表示至少最后一个时段还有一部分是从第二天获取的. 
        // 对第二天的每个时段进行循环分析处理
        for (NSInteger i = 0; i < [nextDayItem.periods count]; i++) {
            MyENext24HrsPeriodData *period = [nextDayItem.periods objectAtIndex:i];// 取得第i个时段
            MyENext24HrsPeriodData *newPeriod = [period copy];// 克隆该时段为一个新对象
            //对于第二天的第一个时段，要考虑：如果今天晚上的Sleep mode和明天凌晨的sleep mode完全一样，从界面上就把它们合并起来作为一个时段进行操作.
            // 这里对相同setpoint的0点前后时段进行合并
            if (i == 0 && newPeriod.heating == lastPeriodOfToday.heating && newPeriod.cooling == lastPeriodOfToday.cooling) {
                lastPeriodOfToday.etid = newPeriod.etid + zeroHourSectorId;// 标记结果数组里的最后一个时段的结束时刻为第二天的第一个时段的结束时刻
                if (lastPeriodOfToday.etid >= NUM_SECTOR) {// 如果最后添加的时段已经是最后时段，并且结束时刻大于48，就表示达到一整个24小时的时段全部加入了，可以退出了
                    lastPeriodOfToday.etid = NUM_SECTOR;
                    break;
                }
            } else {// 对于非第一个时段，或者不能拼接的时段进行处理
                if(period.etid < currentHalfHr) {// 测试当前period的结束时刻是否小于当前时刻半点，如果小于，就表示位于Next24Hrs之内，能够添加。
                    newPeriod.stid += zeroHourSectorId;// 对新时段的开始时刻进行转换到next24Hrs空间
                    newPeriod.etid += zeroHourSectorId;// 对新时段的结束时刻进行转换到next24Hrs空间
                    [periods addObject:newPeriod];// 添加到结果数组
                } else if(period.stid <= currentHalfHr && period.etid >= currentHalfHr) {// 如果当前正在测试的period是最后的时段
                    newPeriod.stid += zeroHourSectorId;// 对新时段的开始时刻进行转换到next24Hrs空间
                    newPeriod.etid = NUM_SECTOR;// 设置最后时段的结束时刻是48
                    if(newPeriod.stid < newPeriod.etid)// 如果最后一个时段的开始刚好有可能位于0点，此时就不能添加此
                        [periods addObject:newPeriod];
                }
            }
        }
    }
    if(![self isPeriodsValid:periods ])
        NSLog(@"正在拆分生成的Next24Hrs的periods不正确");
    return periods;
}

// 从dayItems数组获得Next24Hrs所用的periods
// 用户可能修改doughnut view上的periods，这里根据最新的periods数组，反向更新数据到dayItems，然后才能上传到服务器
/*
 在periods数组的每个perid里面已经记录此时段是属于哪一天一个时段的，现在我们允许next24hrs跨越0点操作，
 那么就有可能把今天和第二天的时段完全拖乱，就和可以涂抹，也就是可以更改时段数目和删除、新增时段时的效果一样，
 因此，我们这里就不能利用记录此时段是属于哪一天一个时段的变量快速访问每一开关时段原来的对应位置，这两个变量只是在访问开始结束时段时有效。
 * 可以知道修改后的最后一个时段对应于原来的哪个天那个时段，
 * 从而修改原来那个最后时段的没落在此24小时内的部分的setpoint信息。
 */
- (void)updaeDayItemsByPeriods {
    // 如果next24hrs缓冲时段数组为空，就返回
    if (self.periods == nil || [self.periods count] == 0) {
        return;
    }
    NSInteger currentHr = [self getHoursForCurrentTime]; //开始的整点
    NSInteger currentHalfHr = currentHr * 2;// 开始的半点
    NSInteger zeroHourSectorId = (NUM_SECTOR - currentHalfHr) % NUM_SECTOR; // 在next24Hrs中，零点所在的圆环上的sector序号，如果是48，就取0 
    
    if (zeroHourSectorId == 0) {// 0 如果zeroHourSectorId==0，那么成Next24Hrs 的 Periods的时段刚好构today的全部时段，此时单独处理
        MyENext24HrsDayItemData *dayItem = [self.dayItems objectAtIndex:0];// 取得今天的数据对象
        [dayItem.periods removeAllObjects];// 删除全部today里面的时段
        // 把所有Next24Hrs 的 Periods的时段复制到today时段里面
        for (NSInteger i = 0; i < [self.periods count]; i++ ) {
            MyENext24HrsPeriodData *p = [self.periods objectAtIndex:i];// 取得next24hrs的periods数组的第i个元素
            [dayItem.periods addObject:[p copy]];
        }
    } else {
        // 1 首先处理dayItems中today的periods数组，首先处理第一个时段，然后删除其中的其他非next24Hrs的第一个时段
        MyENext24HrsPeriodData *firstPeriod = [self.periods objectAtIndex:0];// 取得next24hrs的periods数组的第一个元素
        MyENext24HrsDayItemData *dayItem = [self.dayItems objectAtIndex:0];// 取得今天的数据对象
        NSInteger countOfTodayPeriods = [dayItem.periods count];//记录今天的periods数组的元素数目
        // 寻找第一时段在原来dayItem里面的下标, 取得当前period在原始dayItem里面的periods数组中的原始对象
        NSInteger originalFirstPeriodIndexInToday = 0; MyENext24HrsPeriodData *originalFirstPeriod = nil;
        for (NSInteger i= 0; i<countOfTodayPeriods; i++) {
            MyENext24HrsPeriodData *p = [dayItem.periods objectAtIndex:i];
            if (firstPeriod.stid + currentHalfHr>= p.stid && firstPeriod.stid + currentHalfHr< p.etid) {
                originalFirstPeriodIndexInToday = i;
                originalFirstPeriod = p;
            }
        }
    
        // 不管next24Hrs中periods的第一时段是完全还是部分取自today的periods的一个时段，不管有没有裁剪，此时仅需要修改原始时段的etid, 而不能修改stid、heating、cooling
        if (zeroHourSectorId != 0 && firstPeriod.etid > zeroHourSectorId) {
            originalFirstPeriod.etid = NUM_SECTOR;
        }else {
            originalFirstPeriod.etid = firstPeriod.etid + currentHalfHr; 
        }

        // 执行删除
        for (NSInteger i = countOfTodayPeriods - 1; i > originalFirstPeriodIndexInToday; i--) {
            [dayItem.periods removeObjectAtIndex:i];
        }

        // 执行添加next24Hrs中periods里面非next24Hrs的第一时段但属于today的时段
        for (NSInteger i = 1; i < [self.periods count]; i++ ) {
            MyENext24HrsPeriodData *p = [self.periods objectAtIndex:i];// 取得next24hrs的periods数组的第i个元素
            if (p.etid < zeroHourSectorId/* || p.stid > zeroHourSectorId*/) {// 如果p不是跨越0点、而是在0点之前的时段
                MyENext24HrsPeriodData *np = [p copy];
                np.stid = p.stid + currentHalfHr;
                np.etid = p.etid + currentHalfHr;
                [dayItem.periods addObject:np];
            }else if (p.stid < zeroHourSectorId && p.etid >= zeroHourSectorId) {// 如果p是跨越0点的时段
                MyENext24HrsPeriodData *np = [p copy];
                np.stid = p.stid + currentHalfHr;
                np.etid = NUM_SECTOR;
                [dayItem.periods addObject:np];
                break;
            }
        }

        // ========== 2 其次处理dayItems中第二天的periods数组，首先处理最后一个时段，然后删除其中的其他非next24Hrs的最后一个时段
        MyENext24HrsPeriodData *lastPeriod = [self.periods objectAtIndex:[self.periods count]-1];// 取得next24hrs的periods数组的最后一个元素
        dayItem = [self.dayItems objectAtIndex:1];// 取得今天的数据对象
        NSInteger countOfSecondDayPeriods = [dayItem.periods count];//记录今天的periods数组的元素数目
        if (lastPeriod.etid > zeroHourSectorId) {// 确保最后来自第二天，然后进行修改此最后一个时段的开始时间、heating、cooling
            // 寻找第一时段在原来dayItem里面的下标, 取得当前period在原始dayItem里面的periods数组中的原始对象
            NSInteger originalLastPeriodIndex = 0; MyENext24HrsPeriodData *originalLastPeriod = nil;
            for (NSInteger i= 0; i<countOfSecondDayPeriods; i++) {
                MyENext24HrsPeriodData *p = [dayItem.periods objectAtIndex:i];
                if (lastPeriod.etid - zeroHourSectorId > p.stid && lastPeriod.etid - zeroHourSectorId <= p.etid) {
                    originalLastPeriodIndex = i;
                    originalLastPeriod = p;
                }
            }

            // next24Hrs的最后一个时段刚好跨越0点,或者从0点开始, 或者如果next24Hrs中最后一个时段是second dayItem的第一个时段
            if ((lastPeriod.stid <= zeroHourSectorId && lastPeriod.etid > zeroHourSectorId) || originalLastPeriodIndex == 0) {
                NSLog(@"originalLastPeriodIndex = %i ", originalLastPeriodIndex);
                originalLastPeriod.stid = 0;
                originalLastPeriod.heating = lastPeriod.heating;
                originalLastPeriod.cooling = lastPeriod.cooling;
                originalLastPeriod.color = [MyEUtil colorWithHexString:[MyEUtil hexStringWithUIColor:lastPeriod.color]];
                originalLastPeriod.title = lastPeriod.title;
                originalLastPeriod.hold = lastPeriod.hold;
                
            }
            // next24Hrs的最后一个时段比0点晚，把原始时段的开始时刻修改为此最后时段的开始时刻，而且也要修改setpoint，因为用户修改了的时段如果是原来时段拆分的，就要对原来时段的setpoint进行修改
            if (lastPeriod.stid > zeroHourSectorId) {
                originalLastPeriod.stid = lastPeriod.stid - zeroHourSectorId;
                originalLastPeriod.heating = lastPeriod.heating;
                originalLastPeriod.cooling = lastPeriod.cooling;
                originalLastPeriod.color = [MyEUtil colorWithHexString:[MyEUtil hexStringWithUIColor:lastPeriod.color]];
                originalLastPeriod.title = lastPeriod.title;
                originalLastPeriod.hold = lastPeriod.hold;
                
            }
            
            // 执行删除第二天的其他非next24Hrs中最后一个时段
            for (NSInteger i = 0; i < originalLastPeriodIndex; i++) {
                [dayItem.periods removeObjectAtIndex:0];
            }

            // 执行添加next24Hrs中periods里面非next24Hrs的最后一个时段但属于second dayItem的时段
            if ([self.periods count] >= 2) {
                for (NSInteger i = [self.periods count] - 2; i >=0; i--){
                    //对每一个Next24Hrs.periods中最后一个时段之前的个时段进行检查
                    MyENext24HrsPeriodData *p = [self.periods objectAtIndex:i];
                    if (p.stid > zeroHourSectorId) {// 如果p不是跨越0点的时段,比0点晚
                        MyENext24HrsPeriodData *np = [p copy];
                        np.stid = p.stid - zeroHourSectorId;
                        np.etid = p.etid - zeroHourSectorId;
                        [dayItem.periods insertObject:np atIndex:0];//添加
                    }else if(p.stid <= zeroHourSectorId && p.etid > zeroHourSectorId){// 如果p是跨越0点的时段
                        MyENext24HrsPeriodData *np = [p copy];
                        np.stid = 0;
                        np.etid = p.etid - zeroHourSectorId;
                        [dayItem.periods insertObject:np atIndex:0];//添加
                        break;
                    }
                }
            }
        }
    }
       
    if(![self isResultValid])
        NSLog(@"[MyEScheduleNext24HrsData updaeDayItemsByPeriods] run error");
    else
        NSLog(@"[MyEScheduleNext24HrsData updaeDayItemsByPeriods] run ok");
}

// 
// 传递来一整天的24小时内的时段，其中的时段的stid、etid都是转换成从0计数的48半点形式了
// 注意，每次更新periods，也会根据它重新计算新的metaModeArray
- (void) setPeriods:(NSArray *)periods
{
    _periods = [NSMutableArray arrayWithArray:periods];
    
    [self refreshMetaModeArrayByPeriods];
}

// 根据更新的时段数组，来更新对应的元模式数组
- (void)refreshMetaModeArrayByPeriods{
    // 下面根据新的periods数据，新建模式元数据，注意每个时段都对应一个模式，不管两个时段的heating，cooling，color等是不是都一样，因为在Today数据中，每个时段都不能被删除，对于还没运行的时段，可以修改其开始和结束时间，但增大一个时段，它的相邻时段的最小时长只是是一个半小时；当前运行时段的下一时段的最早开始时间是当前时刻的下一个半点。
    self.metaModeArray = [NSMutableArray array];
    
    int count = [self.periods count];
    for (int i = 0; i < count; i++) 
    {
        MyENext24HrsPeriodData *period = [self.periods objectAtIndex:i];
        MyEScheduleModeData *metaMode = [period scheduleModeDataWithPeriodIndex:i];
        metaMode.modeId = period.modeId;
        [self.metaModeArray addObject:metaMode];
    }
}
// 返回当前时间所在的开始整点，取值范围是0~23
- (NSInteger)getHoursForCurrentTime {
    //首先根据当前时间，定位最先开始的时段，要把时段打断
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MM/dd/yyyy HH:mm"];
    [dateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"] ];
    NSDate *currentTime = [dateFormatter dateFromString:self.currentTime];
    
    //下面几行获得各个分量的字符
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *comps;
    NSInteger unitFlags = NSYearCalendarUnit | 
    NSMonthCalendarUnit |
    NSDayCalendarUnit | 
    NSHourCalendarUnit |
    NSMinuteCalendarUnit;
    
    comps = [calendar components:unitFlags fromDate:currentTime];
    return [comps hour];
}


#pragma mark -
#pragma mark JSON methods
- (NSDictionary *)JSONDictionary{
    // 这里把self.dayItems里面的每个dayItem对象进行json序列化后放入数组dayItems。这样才能把数组dayItems进行正确的JSON序列化
    NSMutableArray *dayItems = [NSMutableArray array];
    for (MyENext24HrsDayItemData *dayItem in self.dayItems)
        [dayItems addObject:[dayItem JSONDictionary]];
    
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                          self.userId, @"userId",
                          self.houseId, @"houseId",
                          self.locWeb, @"locWeb",
                          [NSNumber numberWithInt:self.weeklyId], @"weeklyId",
                          [NSNumber numberWithInt:self.setpoint], @"setpoint",
                          [NSNumber numberWithInt:self.hold], @"hold",
                          self.currentTime, @"currentTime",
                          dayItems, @"dayItems",//这里不能把self.dayItems直接放在值的位置，因为其中数组的每个元素没有正确地进行JSON字符串序列化
                          
                          nil ];
    return dict;
}
-(id)copyWithZone:(NSZone *)zone {
    MyEScheduleNext24HrsData *cloned = [[MyEScheduleNext24HrsData alloc] initWithDictionary:[self JSONDictionary]];
    
//    NSString *selfStr = [NSString stringWithFormat:@"%@",self];
//    NSString *clonedStr = [NSString stringWithFormat:@"%@",cloned];
//    if ([selfStr compare:clonedStr]== NSOrderedSame) {
//        NSLog(@"克隆Next24Hrs数据对象一样");
//    }
//    else {
//        NSLog(@"克隆Next24Hrs数据对象不一样???????????????????");
//        NSLog(@"--------------%@",self);
//        NSLog(@"--------------%@",cloned);
//        MyEScheduleNext24HrsData *cloned = [[MyEScheduleNext24HrsData alloc] initWithDictionary:dict];
//    }
    return cloned;
}
-(NSString *)description
{
    NSMutableString *desc = [NSMutableString stringWithFormat:@"userId = (%@), houseId = %@, locWeb=%@, currentTime = %@, weeklyId = %i , \nsetpoint = %i, hold = %i\n DayItems:\n", _useId, _houseId, _locWeb, _currentTime, _weeklyId, _setpoint, _hold];
    for (MyENext24HrsDayItemData *day in self.dayItems)
        [desc appendString:[NSString stringWithFormat:@"\n{%@}",[day description]]];
    [desc appendString:[NSString stringWithFormat:@"\n Periods: {\n"]];
    for (MyENext24HrsPeriodData *period in self.periods)
        [desc appendString:[NSString stringWithFormat:@"\n%@",[period description]]];
    [desc appendString:[NSString stringWithFormat:@"\n}\n"]];
    return desc;
}



#pragma mark -
#pragma mark utilites methods
/* 因为Next24Hrs的时段数据和Weekly的数据情况不同。Next24Hrs的时段数据没有mode的概念，
  * 而MyEDoughnutView类需要用到mode数组和mode到颜色的映射词典。
 * 并且Next24Hrs的时段数据是从两天的dayItems里面拼接重构出来的，起点的stid不是0， 终点的etid不是48，
 * 下面的函数的功能就是取得每个半小时对应的mode的modeId所构成的数组，数组元素是48个
 */
- (NSMutableArray *) modeIdArray {
    NSMutableArray *modeIdArray = [[NSMutableArray alloc] init];

    int count = [self.periods count];
    for (int i = 0; i < count; i++) {
        MyENext24HrsPeriodData *period = [self.periods objectAtIndex:i];
        //注意，在next24Hrs模块里，每个period对应一个mode。
        MyEScheduleModeData *modeData = [self.metaModeArray objectAtIndex:i];
        for (int j = period.stid; j < period.etid; j++) {
            [modeIdArray addObject:[NSNumber numberWithInt:modeData.modeId]];
        }
    }
    
    return  modeIdArray;
}
// 2013-11-27 由于上面函数的modeId在原来就是时段序号构成的48个元素数组，现在上面编程了用真正的modeId构成的48个元素数组，此函数就用于代替上面的函数
- (NSMutableArray *) periodIndexArray {
    NSMutableArray *periodIndexArray = [[NSMutableArray alloc] init];
    
    int count = [self.periods count];
    for (int i = 0; i < count; i++) {
        MyENext24HrsPeriodData *period = [self.periods objectAtIndex:i];
        //注意，在next24Hrs模块里，每个period对应一个mode。
        for (int j = period.stid; j < period.etid; j++) {
            [periodIndexArray addObject:[NSNumber numberWithInt:i]];
        }
    }
    
    return  periodIndexArray;
}
// 因为next24Hrs的时段数据和Weekly的数据情况不同。next24Hrs的时段数据可以进行hold设置。
// 取得每个半小时对应的hold字符串，数组元素是48个
- (NSMutableArray *) holdArray
{
    NSMutableArray *holdArray = [[NSMutableArray alloc] init];
    int count = [self.periods count];
    for (int i = 0; i < count; i++) {
        MyENext24HrsPeriodData *period = [self.periods objectAtIndex:i];
        for (int j = period.stid; j < period.etid; j++) {
            [holdArray addObject:period.hold];
        }
    }
    
    return  holdArray;
}


// 根据metaModeArray取得每个mode到颜色的映射词典。创建这个词典的目的是只把modeId及其对应的UIColor对象传递到MyEDoughnutView对象，而不直接把MyEScheduleModeData对象传入，从而保持model和view的尽量分离
- (NSMutableDictionary *)modeIdColorDictionary
{
    NSMutableDictionary *mcDictionary = [NSMutableDictionary dictionary];
    int count = [[self metaModeArray] count];
    int i;
    for (i = 0; i < count; i++)
    {
        MyEScheduleModeData *metaMode= [self.metaModeArray objectAtIndex:i];
        [mcDictionary setObject:metaMode.color forKey:[NSNumber numberWithInt:metaMode.modeId]];
    }
    return mcDictionary;
}

// 用户可能通过界面修改了48个半点所对应的modeId，这里就用新的modeIdArray和metaModeArray来更新periods数据。
- (void)updateWithModeIdArray:(NSArray *)modeIdArray
{
    NSMutableArray *periods = [NSMutableArray array];
    int metaModeIndex = 0;//当前正在处理的半点的元模式在metaModeArray数组中的编号
    MyENext24HrsPeriodData *period = [[MyENext24HrsPeriodData alloc] init];
    MyEScheduleModeData *currentModeInMetaModeArray = [self.metaModeArray objectAtIndex:metaModeIndex];
    //next24Hrs模块有个特点，它的时段边界可以移动，但不会减少和增加，它的元模式也不会增减，只是温度setpoint可以改变。
    //因此，next24Hrs数据的第一个时段总是对应第一个元模式
    period.color = currentModeInMetaModeArray.color;
    period.stid = 0;
    period.etid = 1;
    period.heating = currentModeInMetaModeArray.heating;
    period.cooling = currentModeInMetaModeArray.cooling;
    period.title = currentModeInMetaModeArray.modeName;
    period.hold = currentModeInMetaModeArray.hold;
    period.modeId = currentModeInMetaModeArray.modeId;
    
    
    
    //注意，i对应于stid，i从1开始循环，第0个半点已经放入period了
    for (int i = 1; i < NUM_SECTOR; i++) {
        NSInteger modeId = [(NSNumber *)[modeIdArray objectAtIndex:i] intValue];
        //如果两个modeIdArray中的modeId等于当前元模式的modeId，表示当前半点和period属于一个模式
        if (modeId == currentModeInMetaModeArray.modeId) {
            period.etid += 1;
        }else//如果两个modeIdArray中的modeId等于当前元模式的modeId，表示当前半点和period不属于一个模式，就要开始一个新period
        {
            // 首先保存前面找到的这个period
            [periods addObject:period];
            // 其次，创建一个新的period
            period = [[MyENext24HrsPeriodData alloc] init];
            // 当前正在处理的半点的元模式在metaModeArray数组中的编号增加1
            metaModeIndex++;
            if(metaModeIndex >= [self.metaModeArray count])
                metaModeIndex --;
            NSAssert((metaModeIndex < [self.metaModeArray count]), @"Error because period count is larger than the count of metaModeArray");
            
            // 取得新的元模式
            currentModeInMetaModeArray = [self.metaModeArray objectAtIndex:metaModeIndex];
            
            period.color = currentModeInMetaModeArray.color;
            period.stid = i;
            period.etid = i + 1;
            period.heating = currentModeInMetaModeArray.heating;
            period.cooling = currentModeInMetaModeArray.cooling;
            period.title = currentModeInMetaModeArray.modeName;
            period.hold = currentModeInMetaModeArray.hold;
            period.modeId = currentModeInMetaModeArray.modeId;
        }
    }
    // 处理最后一个时段
    period.etid = NUM_SECTOR;
    [periods addObject:period];
 
    
    //注意，这里不能调用self.periods进行复制，因为在setPeriods函数中对metaModeArray进行了更新，这里用空数组进行复制，导致metaModeArray也为空
    _periods = periods;
    [self updaeDayItemsByPeriods];
    //self.periods = [self computePeriodsFromDayItems];// 此语句应该不需要，并且疑似此语句导致在真机运行上crash，但在模拟器上不crash。再确认一下，如果确实不需要，就删除
    
    if(![self isPeriodsValid:periods ])
        NSLog(@"[MyEScheduleNext24HrsData updateWithModeIdArray] 正在拆分生成的Next24Hrs的periods不正确");
    
    if(![self isResultValid])
        NSLog(@"[MyEScheduleNext24HrsData updateWithModeIdArray] run error");

}

// 用户双击某个sector后，对其heating/cooling进行编辑，这里就用新的数据更新periods数据。
// 注意传入的已经是时段period的序号，而不是sector的序号
- (void)updateWithPeriodIndex:(NSUInteger)periodIndex heating:(float)heating cooling:(float)cooling {
    MyENext24HrsPeriodData *period = [self.periods objectAtIndex:periodIndex];
    
    period.heating = heating;
    period.cooling = cooling;
    
    MyEScheduleModeData *mode = [self.metaModeArray objectAtIndex:periodIndex];
    mode.heating = heating;
    mode.cooling = cooling;
    
    [self updaeDayItemsByPeriods];// 根据变化了的Next24Hrs.periods数组，更新dayItems
    [self refreshMetaModeArrayByPeriods];// 根据变化了的Next24Hrs.periods数组，更新元模式数组
}

#pragma mark
#pragma mark 测试函数，测试拼接结果是否正确
// 测试拼接结果是否正确,就是today和第二天的periods数组中的时段是否前后衔接真确，第一时段开始时刻是0， 最后时段的结束时刻是48；
-(BOOL)isResultValid{
    MyENext24HrsDayItemData *day0 = [self.dayItems objectAtIndex:0];
    MyENext24HrsDayItemData *day1 = [self.dayItems objectAtIndex:1];
    return [self isPeriodsValid:day0.periods] && [self isPeriodsValid:day1.periods];
}
// 测试Next24Hrs的periods中的时段中间的下标记录是否标记正确
-(BOOL)isPeriodsValid:(NSMutableArray *)periods {
    if ([periods count] == 1) {// 只有一个时段的情况
        MyENext24HrsPeriodData *p = [periods objectAtIndex:0];
        if (p.stid == 0 && p.etid == NUM_SECTOR) {
            return YES;
        } else {
            return NO;
        }
    }
    MyENext24HrsPeriodData *fp = [periods objectAtIndex:0];
    if (fp.stid != 0) {
        return NO;
    }
    MyENext24HrsPeriodData *lp = [periods objectAtIndex:[periods count]-1];
    if (lp.etid != NUM_SECTOR) {
        return NO;
    }
    for (NSInteger i = 0; i < [periods count] - 1; i++) {
        MyENext24HrsPeriodData *cp = [periods objectAtIndex:i];
        MyENext24HrsPeriodData *np = [periods objectAtIndex:i+1];
        if(cp.stid == cp.etid || np.stid == np.etid){
            return NO;
        }
        if (cp.etid != np.stid) {
            return NO;
        }
    }
    
    
    return YES;
}
@end
