//
//  MyEVacationItemData.m
//  MyE
//
//  Created by Ye Yuan on 3/13/12.
//  Copyright (c) 2012 MyEnergy Domain. All rights reserved.
//

#import "MyEVacationItemData.h"
#import "SBJson.h"

@implementation MyEVacationItemData
@synthesize name = _name, old_end_date = _old_end_date;
@synthesize cooling = _cooling, heating = _heating;
@synthesize leaveDateTime = _leaveDateTime, returnDateTime = _returnDateTime;

- (id)init {
    if (self = [super init]) {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"MM/dd/yyyy"];
        [dateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"] ];
        
        NSDateFormatter *dateTimeFormatter = [[NSDateFormatter alloc] init];
        [dateTimeFormatter setDateFormat:@"MM/dd/yyyy HH:mm"];
        [dateTimeFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"] ];
        
        NSDate *currentTime = [NSDate date];
        _old_end_date = @"";
        
        _name = @"new";
        
        _cooling = 85;
        _heating = 55;
        
        
        NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];

        // now build a NSDate object for the next day
        NSDateComponents *offsetComponents = [[NSDateComponents alloc] init];
        [offsetComponents setDay:1];
        NSDate *tomorrow = [calendar dateByAddingComponents:offsetComponents toDate: currentTime options:0];

        
        NSString *dateString = [dateFormatter stringFromDate:tomorrow];
        tomorrow = [dateTimeFormatter dateFromString:[NSString stringWithFormat:@"%@ 08:00", dateString]];
        _leaveDateTime = tomorrow;
        
        [offsetComponents setDay:2];
        NSDate *thirdDay = [calendar dateByAddingComponents:offsetComponents toDate: currentTime options:0];
        
        dateString = [dateFormatter stringFromDate:thirdDay];
        thirdDay = [dateTimeFormatter dateFromString:[NSString stringWithFormat:@"%@ 22:00", dateString]];
        _returnDateTime = thirdDay;
        
        return self;
    }
    return nil;
}



- (MyEVacationItemData *)initWithDictionary:(NSDictionary *)dictionary
{
    if (self = [super init]) {
        _name = [dictionary objectForKey:@"name"];
        _old_end_date = [dictionary objectForKey:@"old_end_date"];
        
        _cooling = [[dictionary objectForKey:@"cooling"] intValue];
        _heating = [[dictionary objectForKey:@"heating"] intValue];
        
        NSString *dateStr = [dictionary objectForKey:@"leaveDate"];
        NSString *timeStr = [dictionary objectForKey:@"leaveTime"];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"MM/dd/yyyy HH:mm"];
        [dateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"] ];
        _leaveDateTime = [dateFormatter dateFromString:[NSString stringWithFormat:@"%@ %@", dateStr, timeStr]];
        
        dateStr = [dictionary objectForKey:@"returnDate"];
        timeStr = [dictionary objectForKey:@"returnTime"];
        _returnDateTime = [dateFormatter dateFromString:[NSString stringWithFormat:@"%@ %@", dateStr, timeStr]];
        
        return self;
    }
    return nil;

}

- (MyEVacationItemData *)initWithJSONString:(NSString *)jsonString
{
    // Create new SBJSON parser object
    SBJsonParser *parser = [[SBJsonParser alloc] init];
    // 把JSON转为字典    
    NSDictionary *dict = [parser objectWithString:jsonString error:nil];
    
    MyEVacationItemData *vacationItem = [[MyEVacationItemData alloc] initWithDictionary:dict];
    return vacationItem;
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
                          [NSNumber numberWithInt:0],@"type",
                          self.name, @"name",
                          self.old_end_date, @"old_end_date",
                          [NSNumber numberWithInt:self.heating], @"heating",
                          [NSNumber numberWithInt:self.cooling], @"cooling",
                          [dateFormatter stringFromDate:self.leaveDateTime], @"leaveDate",
                          [timeFormatter stringFromDate:self.leaveDateTime], @"leaveTime",
                          [dateFormatter stringFromDate:self.returnDateTime], @"returnDate",
                          [timeFormatter stringFromDate:self.returnDateTime], @"returnTime",
                          nil ];
    return dict;
}
-(id)copyWithZone:(NSZone *)zone {
    return [[MyEVacationItemData alloc] initWithDictionary:[self JSONDictionary]];
}
@end
