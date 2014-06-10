//
//  MyEHomePanelData.m
//  MyE
//
//  Created by Ye Yuan on 6/9/14.
//  Copyright (c) 2014 MyEnergy Domain. All rights reserved.
//

#import "MyEHomePanelData.h"
#import "SBJson.h"

@implementation MyEHomePanelData
//测试用，用默认值构造一个MyEHomePanelData对象
- (id)init {
    if (self = [super init]) {
        _temperature = 78.66;
        _weather = @"cond001";
        _weatherTemp = 68.88;
        _highTemp = 73.33;
        _lowTemp = 55.55;
        _humidity = 70;
        _indoorHumidity = 0;
        _numDetected = 0;
        return self;
    }
    return nil;
}

- (MyEHomePanelData *)initWithDictionary:(NSDictionary *)dictionary {
    if (self = [super init]) {
        self.weather = [dictionary objectForKey:@"weather"];
        self.temperature = [[dictionary objectForKey:@"temperature"] floatValue];
        self.weatherTemp = [[dictionary objectForKey:@"weatherTemp"] floatValue];
        self.highTemp = [[dictionary objectForKey:@"highTemp"] floatValue];
        self.lowTemp = [[dictionary objectForKey:@"lowTemp"] floatValue];
        self.humidity = [[dictionary objectForKey:@"humidity"] floatValue];
        self.indoorHumidity = [[dictionary objectForKey:@"indoorHumidity"] floatValue];
        self.numDetected = [[dictionary objectForKey:@"numDetected"] intValue];
        return self;
    }
    return nil;
}

- (MyEHomePanelData *)initWithJSONString:(NSString *)jsonString {
    // Create new SBJSON parser object
    SBJsonParser *parser = [[SBJsonParser alloc] init];
    // 把JSON转为字典 ， 如果解析错误，就会返回一个空对象
    NSDictionary *dict = [parser objectWithString:jsonString error:nil];
    if (dict && [dict isKindOfClass:[NSDictionary class]]) {
        MyEHomePanelData *dashboardData = [[MyEHomePanelData alloc] initWithDictionary:dict];
        return dashboardData;
    }
    else return nil;
}

- (NSDictionary *)JSONDictionary
{
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                          [NSNumber numberWithFloat:self.temperature], @"temperature",
                          self.weather, @"weather",
                          [NSNumber numberWithFloat:self.weatherTemp], @"weatherTemp",
                          [NSNumber numberWithFloat:self.highTemp], @"highTemp",
                          [NSNumber numberWithFloat:self.lowTemp], @"lowTemp",
                          [NSNumber numberWithFloat:self.humidity], @"humidity",
                          [NSNumber numberWithFloat:self.indoorHumidity], @"indoorHumidity",
                          [NSNumber numberWithInteger:self.numDetected], @"numDetected",
                          nil ];
    return dict;
}
-(id)copyWithZone:(NSZone *)zone {
    return [[MyEHomePanelData alloc] initWithDictionary:[self JSONDictionary]];
}

@end
