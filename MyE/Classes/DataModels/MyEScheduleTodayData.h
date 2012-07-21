//
//  MyEScheduleTodayData.h
//  MyE
//
//  Created by Ye Yuan on 2/21/12.
//  Copyright (c) 2012 MyEnergy Domain. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MyEScheduleTodayData : NSObject <NSCopying> 
{
    NSString *_useId;
    NSString *_houseId;
    NSString *_currentTime;
    NSInteger _weeklyId;
    NSInteger _setpoint;
    NSInteger _hold;
    NSMutableArray *_periods;
    
    //根据periods数据为today模块创建的mode元数据数组，
    //数组的元素就是根据period生成的一个MyEScheduleModeData对象。
    //此数组可以看成是一个词典，词典的键就是mode在数组中的序号字符串，值就是这个mode对象
    //根据此数组可以获得模式到颜色的映射词典,此词典的键可以取做mode在mode元数据数组中的序号，值就是该模式中给出的颜色。
    NSMutableArray *_metaModeArray;
}

@property (copy, nonatomic) NSString *userId;
@property (copy, nonatomic) NSString *houseId;
@property (copy, nonatomic) NSString *currentTime;
@property (nonatomic) NSInteger weeklyId;
@property (nonatomic) NSInteger setpoint;
@property (nonatomic) NSInteger hold;
@property (retain, nonatomic) NSMutableArray *periods;
@property (retain, nonatomic) NSMutableArray *metaModeArray;

- (MyEScheduleTodayData *)initWithDictionary:(NSDictionary *)dictionary;
- (MyEScheduleTodayData *)initWithJSONString:(NSString *)jsonString;
- (NSString *)JSONDictionary;

// 根据更新的时段数组，来更新对应的元模式数组
- (void)refreshMetaModeArrayByPeriods;
// 因为today的时段数据和Weekly的数据情况不同。Today的时段数据没有mode的概念，而MyEDoughnutView类需要用到mode数组和mode到颜色的映射词典。
// 下面两个函数的功能就是从today的periods数据中计算取得需要的mode数组和mode到颜色的映射词典
- (NSMutableArray *) modeIdArray;
// 根据metaModeArray取得每个mode到颜色的映射词典。创建这个词典的目的是只把modeId及其对应的UIColor对象传递到MyEDoughnutView对象，而不直接把MyEScheduleModeData对象传入，从而保持model和view的尽量分离
- (NSMutableDictionary *)modeIdColorDictionary;
- (NSMutableArray *) holdArray;

// 用户可能通过界面修改了48个半点所对应的modeId，这里就用新的modeIdArray了更新periods数据。此处的mode就对应一个period
- (void)updateWithModeIdArray:(NSArray *)modeIdArray;

// 用户双击某个sector后，对其heating/cooling进行编辑，这里就用新的数据更新periods数据。
// 注意传入的已经是时段period的序号，而不是sector的序号
- (void)updateWithSectorIndex:(NSUInteger)periodIndex heating:(float)heating cooling:(float)cooling;
@end
