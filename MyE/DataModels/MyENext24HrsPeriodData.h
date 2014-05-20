//
//  MyENext24HrsPeriodData.h
//  MyE
//
//  Created by Ye Yuan on 2/21/12.
//  Copyright (c) 2012 MyEnergy Domain. All rights reserved.
//  专为Today的时段数据设计的。

#import <Foundation/Foundation.h>
@class MyEScheduleModeData;


@interface MyENext24HrsPeriodData : NSObject <NSCopying> 
@property (retain, nonatomic) UIColor *color;
@property (nonatomic) NSInteger stid;//需要注意，stid的取值范围可能是0到47，0表示今天的凌晨12:00AM
@property (nonatomic) NSInteger etid;//需要注意，etid的取值范围可能是1到48，48表示第二天的凌晨12:00AM
@property (nonatomic) NSInteger cooling;
@property (nonatomic) NSInteger heating;
@property (copy, nonatomic) NSString *hold; 
@property (copy, nonatomic) NSString *title;
@property (nonatomic) NSInteger modeId;

///* 下面几个变量，仅用于在Next24Hrs面板的MyEScheduleNext24HrsData数据类，在生成模拟24小时的periods时，
// * 在每个perid里面记录此时段是属于哪一天一个时段的，在目前不允许改过时段数目的操作方式下，
// * 此两变量可以有效快速访问原来该时段所对应的位置，但如果在现在操作模式修改成可以跨越0点，和涂抹类似，
// * 也就是可以更改时段数目和删除、新增时段时，这里记录的哪天、哪个时段就意义不大了，
// * 但这两个信息对于最后一个时段有意义，可以知道修改后的最后一个时段对应于原来的哪个天那个时段，
// * 从而修改原来那个最后时段的没落在此24小时内的部分的setpoint信息。
// */
//@property (nonatomic) NSInteger indexInDayItems;
//@property (nonatomic) NSInteger indexInPeriods;



- (MyENext24HrsPeriodData *)initWithDictionary:(NSDictionary *)dictionary;
- (NSDictionary *)JSONDictionary;

//从period数据获取由MyEScheduleModeData类对象，它是元模式数据.传入的参数modeId其实是时段的在today数据中的编号，
- (MyEScheduleModeData *)scheduleModeDataWithPeriodIndex:(NSInteger)periodIndex;
@end
