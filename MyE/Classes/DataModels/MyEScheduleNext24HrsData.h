//
//  MyEScheduleNext24HrsData.h
//  MyE
//
//  Created by Ye Yuan on 7/10/12.
//  Copyright (c) 2012 MyEnergy Domain. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MyEScheduleNext24HrsData : NSObject <NSCopying> 
@property (copy, nonatomic) NSString *userId;
@property (copy, nonatomic) NSString *houseId;
@property (copy, nonatomic) NSString *currentTime;
@property (nonatomic) NSInteger weeklyId;
@property (nonatomic) NSInteger setpoint;//当前运行状态的setpoint值	整型	取值范围55~90
@property (nonatomic) NSInteger hold;//hold状态，对应于Dashboard模块的isOvrried字段。	整型	分别对应0(Run), 1(Permanent Hold), 2(Temporary Hold)。
@property (retain, nonatomic) NSMutableArray *dayItems;
@property (retain, nonatomic) NSMutableArray *metaModeArray;
@property (nonatomic, copy) NSString *locWeb;

// 用24小时的时段模拟一天的时段数组// 模拟MyEScheduleToday.h类中的属性periods的设置
@property (retain, nonatomic) NSMutableArray *periods;

- (MyEScheduleNext24HrsData *)initWithDictionary:(NSDictionary *)dictionary;
- (MyEScheduleNext24HrsData *)initWithJSONString:(NSString *)jsonString;
- (NSDictionary *)JSONDictionary;

// 因为today的时段数据和Weekly的数据情况不同。Today的时段数据没有mode的概念，而MyEDoughnutView类需要用到mode数组和mode到颜色的映射词典。
// 下面两个函数的功能就是从today的periods数据中计算取得需要的mode数组和mode到颜色的映射词典
- (NSMutableArray *) modeIdArray;
// 根据metaModeArray取得每个mode到颜色的映射词典。创建这个词典的目的是只把modeId及其对应的UIColor对象传递到MyEDoughnutView对象，而不直接把MyEScheduleModeData对象传入，从而保持model和view的尽量分离
- (NSMutableDictionary *)modeIdColorDictionary;
- (NSMutableArray *) holdArray;

// 根据服务器传来的2天的时段数据，返回在Next24Hrs面板上显示的、刚好落在24小时之内的时段和获取方法。
- (NSMutableArray *)computePeriodsFromDayItems;
// 更加最新的periods数组，反向更新数据到dayItems
- (void)updaeDayItemsByPeriods;
// 根据更新的时段数组，来更新对应的元模式数组
- (void)refreshMetaModeArrayByPeriods;
// 返回当前时间所在的开始整点，取值范围是0~23
- (NSInteger)getHoursForCurrentTime;

// 用户可能通过界面修改了48个半点所对应的modeId，这里就用新的modeIdArray了更新periods数据。此处的mode就对应一个period
- (void)updateWithModeIdArray:(NSArray *)modeIdArray;

// 用户双击某个sector后，对其heating/cooling进行编辑，这里就用新的数据更新periods数据。
// 注意传入的已经是时段period的序号，而不是sector的序号
- (void)updateWithPeriodIndex:(NSUInteger)periodIndex heating:(float)heating cooling:(float)cooling;

// 测试函数，测试拼接结果是否正确,就是today和第二天的periods数组中的时段是否前后衔接真确，第一时段开始时刻是0， 最后时段的结束时刻是48；
-(BOOL)isResultValid;
// 测试Next24Hrs的periods中的时段中间的下标记录是否标记正确
-(BOOL)isPeriodsValid:(NSMutableArray *)periods;
@end
