//
//  MyENext24HrsPeriodData.h
//  MyE
//
//  Created by Ye Yuan on 7/10/12.
//  Copyright (c) 2012 MyEnergy Domain. All rights reserved.
//

#import <Foundation/Foundation.h>
@class MyEScheduleModeData;

@interface MyENext24HrsPeriodData : NSObject <NSCopying> 
{
    UIColor *_color;
    NSInteger _stid;//需要注意，stid的取值范围可能是0到47，0表示今天的凌晨12:00AM
    NSInteger _etid;//需要注意，etid的取值范围可能是1到48，48表示第二天的凌晨12:00AM
    float _cooling;
    float _heating;
    NSString *_hold;
    NSString *_title; 
    //NSInteger _modeId; 
}
@property (retain, nonatomic) UIColor *color;
@property (nonatomic) NSInteger stid;
@property (nonatomic) NSInteger etid;
@property (nonatomic) float cooling;
@property (nonatomic) float heating;
@property (copy, nonatomic) NSString *hold; 
@property (copy, nonatomic) NSString *title; 
//@property (nonatomic) NSInteger modeId; 



- (MyENext24HrsPeriodData *)initWithDictionary:(NSDictionary *)dictionary;
- (NSDictionary *)JSONDictionary;
//从2天的period数据获取由MyEScheduleModeData类对象，它是元模式数据.传入的参数modeId其实是时段的在2天数据中的编号，
- (MyEScheduleModeData *)scheduleModeDataWithModeId:(NSInteger)modeId;
@end
