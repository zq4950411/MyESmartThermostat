//
//  MyEScheduleModeData.h
//  MyE
//
//  Created by Ye Yuan on 2/24/12.
//  Copyright (c) 2012 MyEnergy Domain. All rights reserved.
//  本类可以用于Weekly模块，也可以用于Today得到时段数据后构造其模式元数据用

#import <Foundation/Foundation.h>

@interface MyEScheduleModeData : NSObject <NSCopying> 
{
    UIColor *_color;
    float _cooling;
    float _heating;
    NSInteger _modeId; 
    NSString *_modeName; 
    NSString *_hold;//仅用于在Today模块生成临时mode时记录hold情况
}
@property (retain, nonatomic) UIColor *color;
@property (nonatomic) float cooling;
@property (nonatomic) float heating;
@property (nonatomic) NSInteger modeId; 
@property (copy, nonatomic) NSString *modeName; 
@property (copy, nonatomic) NSString *hold; 



- (MyEScheduleModeData *)initWithDictionary:(NSDictionary *)dictionary;
- (NSDictionary *)JSONDictionary;

@end
