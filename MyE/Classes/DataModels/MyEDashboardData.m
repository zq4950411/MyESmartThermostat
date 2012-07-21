//
//  DashboardData.m
//  MyE
//
//  Created by Ye Yuan on 1/19/12.
//  Copyright (c) 2012 MyEnergy Domain. All rights reserved.
//

#import "MyEDashboardData.h"
#import "SBJson.h"

@implementation MyEDashboardData
@synthesize locWeb = _locWeb, isheatcool = _isheatcool, setpoint = _setpoint, stageLevel = _stageLevel, controlMode = _controlMode, realControlMode = _realControlMode, temperature = _temperature, isOvrried = _isOvrried, fan_control = _fan_control, fan_status = _fan_status, currentProgram = _currentProgram, weather = _weather, weatherTemp = _weatherTemp, highTemp = _highTemp, lowTemp = _lowTemp, humidity = _humidity;

//测试用，用默认值构造一个MyEDashboardData对象
- (id)init {
    if (self = [super init]) {
        _locWeb = @"Disabled";
        _isheatcool = 1;
        _setpoint = 78;
        _stageLevel = 1;
        _controlMode = 3;
        _realControlMode = @"Heating";
        _temperature = 78.66;
        _isOvrried = 1;
        _fan_control = 1;
        _fan_status = @"ON";
        _currentProgram = @"Weekly Program";
        _weather = @"snow";
        _weatherTemp = 68.88;
        _highTemp = 73.33;
        _lowTemp = 55.55;
        _humidity = 70;
        return self;
    }
    return nil;
}

- (MyEDashboardData *)initWithDictionary:(NSDictionary *)dictionary {
    if (self = [super init]) {
        self.locWeb = [dictionary objectForKey:@"locWeb"];
        self.isheatcool = [[dictionary objectForKey:@"isheatcool"] intValue];
        self.setpoint = [[dictionary objectForKey:@"setpoint"] intValue];
        self.stageLevel = [[dictionary objectForKey:@"stageLevel"] intValue];
        self.controlMode = [[dictionary objectForKey:@"controlMode"] intValue]; 
        self.realControlMode = [dictionary objectForKey:@"realControlMode"];
        self.temperature = [[dictionary objectForKey:@"temperature"] floatValue];
        self.isOvrried = [[dictionary objectForKey:@"isOvrried"] intValue];
        self.fan_control = [[dictionary objectForKey:@"fan_control"] intValue];
        self.fan_status = [dictionary objectForKey:@"fan_status"];
        self.currentProgram = [dictionary objectForKey:@"currentProgram"];
        self.weather = [dictionary objectForKey:@"weather"];
        self.weatherTemp = [[dictionary objectForKey:@"weatherTemp"] floatValue];
        self.highTemp = [[dictionary objectForKey:@"highTemp"] floatValue];
        self.lowTemp = [[dictionary objectForKey:@"lowTemp"] floatValue];
        self.humidity = [[dictionary objectForKey:@"humidity"] intValue];
        return self;
    }
    return nil;
}

- (MyEDashboardData *)initWithJSONString:(NSString *)jsonString {
    // Create new SBJSON parser object
    SBJsonParser *parser = [[SBJsonParser alloc] init];
    // 把JSON转为字典 ， 如果解析错误，就会返回一个空对象   
    NSDictionary *dict = [parser objectWithString:jsonString error:nil];
    if (dict && [dict isKindOfClass:[NSDictionary class]]) {
        MyEDashboardData *dashboardData = [[MyEDashboardData alloc] initWithDictionary:dict];
        return dashboardData;
    }
    else return nil;
}

- (NSDictionary *)JSONDictionary
{
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                          self.locWeb, @"locWeb",
                          [NSNumber numberWithInt:self.isheatcool], @"isheatcool",
                          [NSNumber numberWithInt:self.setpoint], @"setpoint",
                          [NSNumber numberWithInt:self.stageLevel], @"stageLevel",
                          [NSNumber numberWithInt:self.controlMode], @"controlMode",
                          self.realControlMode, @"realControlMode",
                          [NSNumber numberWithFloat:self.temperature], @"temperature",
                          [NSNumber numberWithInt:self.isOvrried], @"isOvrried",
                          [NSNumber numberWithInt:self.fan_control], @"fan_control",
                          self.fan_status, @"fan_status",
                          self.currentProgram, @"currentProgram",
                          self.weather, @"weather",
                          [NSNumber numberWithFloat:self.weatherTemp], @"weatherTemp",
                          [NSNumber numberWithFloat:self.highTemp], @"highTemp",
                          [NSNumber numberWithFloat:self.lowTemp], @"lowTemp",
                          [NSNumber numberWithInt:self.humidity], @"humidity",
                          nil ];
    return dict;
}
-(id)copyWithZone:(NSZone *)zone {
    return [[MyEDashboardData alloc] initWithDictionary:[self JSONDictionary]];
}
@end
