//
//  MyEStaycationItemData.m
//  MyE
//
//  Created by Ye Yuan on 3/13/12.
//  Copyright (c) 2012 MyEnergy Domain. All rights reserved.
//

#import "MyEStaycationItemData.h"
#import "SBJson.h"

@implementation MyEStaycationItemData
@synthesize name = _name, old_end_date = _old_end_date;
@synthesize nightCooling = _nightCooling, nightHeating = _nightHeating, dayCooling = _dayCooling, dayHeating = _dayHeating;
@synthesize startDate = _startDate, endDate = _endDate, riseTime = _riseTime, sleepTime = _sleepTime;

- (id)init {
    if (self = [super init]) {        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"MM/dd/yyyy"];
        [dateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"] ];
        
        NSDateFormatter *timeFormatter = [[NSDateFormatter alloc] init];
        [timeFormatter setDateFormat:@"HH:mm"];
        [timeFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"] ];
        
        NSDate *currentTime = [NSDate date];
        _old_end_date = @"";
        
        _name = [NSString stringWithFormat:@"S-%@",_old_end_date];
        
        _nightCooling = 78;
        _nightHeating = 65;
        
        _dayCooling = 74;
        _dayHeating = 70;
        
        NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
        
        // now build a NSDate object for the next day
        NSDateComponents *offsetComponents = [[NSDateComponents alloc] init];
        [offsetComponents setDay:1];
        NSDate *tomorrow = [calendar dateByAddingComponents:offsetComponents toDate: currentTime options:0];

        [offsetComponents setDay:2];
        NSDate *thirdDay = [calendar dateByAddingComponents:offsetComponents toDate: currentTime options:0];
        
        _startDate = tomorrow;
        _endDate = thirdDay;
        
        _riseTime = [timeFormatter dateFromString:@"08:00"];
        _sleepTime = [timeFormatter dateFromString:@"22:00"];
        
        return self;
    }
    return nil;
}



- (MyEStaycationItemData *)initWithDictionary:(NSDictionary *)dictionary
{
    if (self = [super init]) {
        _name = [dictionary objectForKey:@"name"];
        _old_end_date = [dictionary objectForKey:@"old_end_date"];
        
        _nightCooling = [[dictionary objectForKey:@"nightCooling"] intValue];
        _nightHeating = [[dictionary objectForKey:@"nightHeating"] intValue];
        
        _dayCooling = [[dictionary objectForKey:@"dayCooling"] intValue];
        _dayHeating = [[dictionary objectForKey:@"dayHeating"] intValue];
        
        
       
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"MM/dd/yyyy"];
        [dateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"] ];
        
        NSString *dateStr = [dictionary objectForKey:@"startDate"];
        _startDate = [dateFormatter dateFromString:[NSString stringWithFormat:@"%@", dateStr]];
        
        dateStr = [dictionary objectForKey:@"endDate"];
        _endDate = [dateFormatter dateFromString:[NSString stringWithFormat:@"%@", dateStr]];
        

        
        
        NSDateFormatter *timeFormatter = [[NSDateFormatter alloc] init];
        [timeFormatter setDateFormat:@"HH:mm"];
        [timeFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"] ];
        
         NSString *timeStr = [dictionary objectForKey:@"dayTime"];
        _riseTime = [timeFormatter dateFromString:[NSString stringWithFormat:@"%@", timeStr]];
        
        timeStr = [dictionary objectForKey:@"nightTime"];
        _sleepTime = [timeFormatter dateFromString:[NSString stringWithFormat:@"%@", timeStr]];
        
        return self;
    }
    return nil;
    
}

- (MyEStaycationItemData *)initWithJSONString:(NSString *)jsonString
{
    // Create new SBJSON parser object
    SBJsonParser *parser = [[SBJsonParser alloc] init];
    // 把JSON转为字典    
    NSDictionary *dict = [parser objectWithString:jsonString error:nil];
    
    MyEStaycationItemData *staycationItem = [[MyEStaycationItemData alloc] initWithDictionary:dict];
    return staycationItem;
}

- (NSDictionary *)JSONDictionary
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MM/dd/yyyy"];
    [dateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"] ];
    
    NSDateFormatter *timeFormatter = [[NSDateFormatter alloc] init];
    [timeFormatter setDateFormat:@"HH:mm"];
    [timeFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"] ];
    
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                          [NSNumber numberWithInt:1],@"type",
                          self.name, @"name",
                          self.old_end_date, @"old_end_date",
                          [NSNumber numberWithInt:self.nightHeating], @"nightHeating",
                          [NSNumber numberWithInt:self.nightCooling], @"nightCooling",
                          [NSNumber numberWithInt:self.dayHeating], @"dayHeating",
                          [NSNumber numberWithInt:self.dayCooling], @"dayCooling",
                          [dateFormatter stringFromDate:self.startDate], @"startDate",
                          [dateFormatter stringFromDate:self.endDate], @"endDate",
                          [timeFormatter stringFromDate:self.riseTime], @"dayTime",
                          [timeFormatter stringFromDate:self.sleepTime], @"nightTime",
                          nil ];
    return dict;
}
-(id)copyWithZone:(NSZone *)zone {
    return [[MyEStaycationItemData alloc] initWithDictionary:[self JSONDictionary]];
}
@end
