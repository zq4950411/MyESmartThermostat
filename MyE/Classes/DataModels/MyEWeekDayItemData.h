//
//  MyEWeekDayItemData.h
//  MyE
//
//  Created by Ye Yuan on 2/29/12.
//  Copyright (c) 2012 MyEnergy Domain. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MyEWeekDayItemData : NSObject <NSCopying> 
{
    NSInteger _dayId;
    NSMutableArray *_periods;

}


@property (nonatomic) NSInteger dayId;
@property (retain, nonatomic) NSMutableArray *periods;


- (MyEWeekDayItemData *)initWithDictionary:(NSDictionary *)dictionary;
- (MyEWeekDayItemData *)initWithJSONString:(NSString *)jsonString;

- (NSDictionary *)JSONDictionary;

-(void)updatePeriodWithAnother:(MyEWeekDayItemData *)another;
@end
