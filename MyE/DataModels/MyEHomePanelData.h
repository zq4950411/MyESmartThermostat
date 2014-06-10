//
//  MyEHomePanelData.h
//  MyE
//
//  Created by Ye Yuan on 6/9/14.
//  Copyright (c) 2014 MyEnergy Domain. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MyEHomePanelData : NSObject<NSCopying>
@property (nonatomic, copy) NSString *weather;
@property (nonatomic) float weatherTemp;
@property (nonatomic) float highTemp;
@property (nonatomic) float lowTemp;
@property (nonatomic) float humidity;
@property (nonatomic) float indoorHumidity;
@property (nonatomic) NSInteger numDetected;//故障信息数量 	0表示没有，其他正数表示故障数量
@property (nonatomic) float temperature;//当前时间的室内温度	温度的华氏度，显示为整数


- (MyEHomePanelData *)initWithDictionary:(NSDictionary *)dictionary;
- (MyEHomePanelData *)initWithJSONString:(NSString *)jsonString;
- (NSDictionary *)JSONDictionary;


@end
