//
//  MyEScheduleTodayData.m
//  MyE
//
//  Created by Ye Yuan on 2/21/12.
//  Copyright (c) 2012 MyEnergy Domain. All rights reserved.
//

#import "MyEScheduleTodayData.h"
#import "MyETodayPeriodData.h"
#import "MyEScheduleModeData.h"
#import "MyEUtil.h"
#import "SBJson.h"

@interface MyEScheduleTodayData (PrivateMethods)


@end

@implementation MyEScheduleTodayData
@synthesize userId = _useId, 
houseId = _houseId,
locWeb = _locWeb, 
currentTime = _currentTime, 
weeklyId = _weeklyId, 
setpoint = _setpoint, 
hold = _hold, 
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
        _periods = [[NSMutableArray alloc] init];
        _metaModeArray = [[NSMutableArray alloc] init];
        
        return self;
    }
    return nil;
}

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
        MyETodayPeriodData *period = [self.periods objectAtIndex:i];
        MyEScheduleModeData *metaMode = [period scheduleModeDataWithModeId:i];
        [self.metaModeArray addObject:metaMode];
    }
}

- (MyEScheduleTodayData *)initWithDictionary:(NSDictionary *)dictionary
{
    if (self = [super init]) {
        self.userId = [dictionary objectForKey:@"userId"];
        self.houseId = [dictionary objectForKey:@"houseId"];
        self.locWeb = [dictionary objectForKey:@"locWeb"];
        self.weeklyId = [[dictionary objectForKey:@"weeklyId"] intValue];
        self.setpoint = [[dictionary objectForKey:@"setpoint"] intValue];
        self.hold = [[dictionary objectForKey:@"hold"] intValue];
        self.currentTime = [dictionary objectForKey:@"currentTime"];
        NSArray *periodsInDict = [dictionary objectForKey:@"periods"];
        NSMutableArray *periods = [NSMutableArray array];
        for (NSDictionary *period in periodsInDict) {
            [periods addObject:[[MyETodayPeriodData alloc] initWithDictionary:period]];
        }
        
        // 这里必须调用 - (void) setPeriods:(NSArray *)periods，在其中由根据periods生成新的metaModeArray的代码。
        self.periods = periods;
        
        return self;
    }
    return nil;
}

- (MyEScheduleTodayData *)initWithJSONString:(NSString *)jsonString
{
    // Create new SBJSON parser object
    SBJsonParser *parser = [[SBJsonParser alloc] init];
    // 把JSON转为字典  
    NSError *error = [[NSError alloc] init];
    NSDictionary *dict = [parser objectWithString:jsonString error:&error];
    if (dict && [dict isKindOfClass:[NSDictionary class]]) {
        MyEScheduleTodayData *today = [[MyEScheduleTodayData alloc] initWithDictionary:dict];
        return today;
    } else return nil;
}




#pragma mark -
#pragma mark JSON methods
- (NSDictionary *)JSONDictionary{
    // 这里把self.periods里面的每个时段对象进行json序列化后放入数组periods。这样才能把数组periods进行正确的JSON序列化
    NSMutableArray *periods = [NSMutableArray array];
    for (MyETodayPeriodData *period in self.periods)
        [periods addObject:[period JSONDictionary]];
    
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                          self.userId, @"userId",
                          self.houseId, @"houseId",
                          self.locWeb, @"locWeb",
                          [NSNumber numberWithInt:self.weeklyId], @"weeklyId",
                          [NSNumber numberWithInt:self.setpoint], @"setpoint",
                          [NSNumber numberWithInt:self.hold], @"hold",
                          self.currentTime, @"currentTime",
                          periods, @"periods",//这里不能把self.periods直接放在值的位置，因为其中数组的每个元素没有正确地进行JSON字符串序列化
                          
                          nil ];
    return dict;
}
-(id)copyWithZone:(NSZone *)zone {
//    NSDictionary *dict = [self JSONDictionary];
    return [[MyEScheduleTodayData alloc] initWithDictionary:[self JSONDictionary]];
}
-(NSString *)description
{
    NSMutableString *desc = [NSMutableString stringWithFormat:@"userId = (%@), houseId = %@, locWeb = %@, currentTime = %@, weeklyId = %i , \nsetpoint = %i, hold = %i\n periods:\n", _useId, _houseId, _locWeb, _currentTime, _weeklyId, _setpoint, _hold];
    for (MyETodayPeriodData *period in _periods)
        [desc appendString:[period description]];
    return desc;
}



#pragma mark -
#pragma mark utilites methods
// 因为today的时段数据和Weekly的数据情况不同。Today的时段数据没有mode的概念，而MyEDoughnutView类需要用到mode数组和mode到颜色的映射词典。
// 下面的函数的功能就是从today的metaModeArray数据中计算取得需要的mode数组和mode到颜色的映射词典
// 取得每个半小时对应的mode的modeId所构成的数组，数组元素是48个
- (NSMutableArray *) modeIdArray
{
    NSMutableArray *modeIdArray = [[NSMutableArray alloc] init];
    int count = [self.periods count];
    for (int i = 0; i < count; i++) {
        MyETodayPeriodData *period = [self.periods objectAtIndex:i];
        //注意，在today模块里，每个period对应一个mode。
        MyEScheduleModeData *modeData = [self.metaModeArray objectAtIndex:i];
        for (int j = period.stid; j < period.etid; j++) {
            [modeIdArray addObject:[NSNumber numberWithInt:modeData.modeId]];
        }
    }

    return  modeIdArray;
}
// 因为today的时段数据和Weekly的数据情况不同。Today的时段数据可以进行hold设置。
// 取得每个半小时对应的hold字符串，数组元素是48个
- (NSMutableArray *) holdArray
{
    NSMutableArray *holdArray = [[NSMutableArray alloc] init];
    int count = [self.periods count];
    for (int i = 0; i < count; i++) {
        MyETodayPeriodData *period = [self.periods objectAtIndex:i];
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
    MyETodayPeriodData *period = [[MyETodayPeriodData alloc] init];
    NSLog(@"count is %i",[self.metaModeArray count]);
    MyEScheduleModeData *currentModeInMetaModeArray = [self.metaModeArray objectAtIndex:metaModeIndex];
    //Today模块有个特点，它的时段边界可以移动，但不会减少和增加，它的元模式也不会增减，只是温度setpoint可以改变。
    //因此，today数据的第一个时段总是对应第一个元模式
    period.color = currentModeInMetaModeArray.color;
    period.stid = 0;
    period.etid = 1;
    period.heating = currentModeInMetaModeArray.heating;
    period.cooling = currentModeInMetaModeArray.cooling;
    period.title = currentModeInMetaModeArray.modeName;
    period.hold = currentModeInMetaModeArray.hold;

    
    
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
            period = [[MyETodayPeriodData alloc] init];
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
        }
    }
    // 处理最后一个时段
    period.etid = NUM_SECTOR;
    [periods addObject:period];
    
    //注意，这里不能调用self.periods进行复制，因为在setPeriods函数中对metaModeArray进行了更新，这里用空数组进行复制，导致metaModeArray也为空
    _periods = periods;
}

// 用户双击某个sector后，对其heating/cooling进行编辑，这里就用新的数据更新periods数据。
// 注意传入的已经是时段period的序号，而不是sector的序号
- (void)updateWithPeriodIndex:(NSUInteger)periodIndex heating:(float)heating cooling:(float)cooling {
    MyETodayPeriodData *period = [self.periods objectAtIndex:periodIndex];
    
    period.heating = heating;
    period.cooling = cooling;
    
    MyEScheduleModeData *mode = [self.metaModeArray objectAtIndex:periodIndex];
    mode.heating = heating;
    mode.cooling = cooling;
    
    [self refreshMetaModeArrayByPeriods];// 根据变化了的periods数组，更新元模式数组
}
@end
