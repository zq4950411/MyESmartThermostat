//
//  MyEScheduleWeeklyData.h
//  MyE
//
//  Created by Ye Yuan on 2/29/12.
//  Copyright (c) 2012 MyEnergy Domain. All rights reserved.
//

#import <Foundation/Foundation.h>
@class MyEScheduleModeData;

@interface MyEScheduleWeeklyData : NSObject <NSCopying> 
{
    NSString *_userId;
    NSString *_houseId;
    NSString *_currentTime;
    NSMutableArray *_dayItems;
    
    //模式数组。在Today模块，这个数组就对应MyEScheduleTodayData的metaModeArray，其元素是MyEScheduleModeData类对象
    NSMutableArray *_metaModeArray;
}

@property (copy, nonatomic) NSString *userId;
@property (copy, nonatomic) NSString *houseId;
@property (copy, nonatomic) NSString *currentTime;
@property (nonatomic, copy) NSString *locWeb;
@property (retain, nonatomic) NSMutableArray *dayItems;
@property (retain, nonatomic) NSMutableArray *metaModeArray;

- (MyEScheduleWeeklyData *)initWithDictionary:(NSDictionary *)dictionary;
- (MyEScheduleWeeklyData *)initWithJSONString:(NSString *)jsonString;

- (NSDictionary *)JSONDictionary;

/* 注意，在服务器传递的数据中，dayItem的dayId对应的关系是：0-Mod, 1-Tue, ..., 5-Sat, 6-Sun, 这个在本程序里面没有用到，
 * 但是服务器程序把dayItem的顺序调整成[{6-Sun}, {0-Mon}, {1-Tue}, {2-Wed}, {3-Thu}, {4-Fri}, {5-Sat}]。
 * 对每个Weekday的Schedule的任何改变，直接写到对应的dayItems的元素中，所以在我们应用里面不要考虑dayItem自带的dayId属性。
 * 为了区分在服务器传递的数据中dayItem的dayId属性和我们这里的自己的weekday排序，这里我们都用变量weekdayId做weekday的id
 * 我们在这里保存的dayItems中的weekdayId和weekday对应关系以及dayItem顺序是: 0-Sun, 1-Mon, 2-Tue, 3-Wed, 4-Thu, 5-Fri, 6-Sat。
 */
// 下面函数作用是取得每个半小时对应的mode的modeId所构成的数组，数组元素是48个
- (NSMutableArray *) modeIdArrayForWeekdayId:(NSUInteger)weekdayId;

// 下面函数作用是取得给定weekdayId那一天的由MyETodayPeriodData对象构成的时段数组
- (NSMutableArray *) periodsForWeekdayId:(NSUInteger)weekdayId;

// 给定一个modeId，返回MyEScheduleModeData对象。
-(MyEScheduleModeData *)getModeDataByModeId:(NSInteger)modeId;
// 根据metaModeArray取得每个mode到颜色的映射词典。创建这个词典的目的是只把modeId及其对应的UIColor对象传递到MyEDoughnutView对象，而不直接把MyEScheduleModeData对象传入，从而保持model和view的尽量分离
- (NSMutableDictionary *)modeIdColorDictionary;

// 判定给定的名字或颜色是否已经被其他mode使用
- (BOOL) isModeNameInUse:(NSString *)name exceptCurrentModeId:(NSInteger)modeId;
- (BOOL) isModeColorInUse:(UIColor *)color exceptCurrentModeId:(NSInteger)modeId;
@end
