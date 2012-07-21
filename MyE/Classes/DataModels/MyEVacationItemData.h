//
//  MyEVacationItemData.h
//  MyE
//
//  Created by Ye Yuan on 3/13/12.
//  Copyright (c) 2012 MyEnergy Domain. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MyEVacationItemData : NSObject {
    // common
    NSString *_name;
    NSString *_old_end_date;

    NSInteger _cooling;
    NSInteger _heating;
    
    NSDate *_leaveDateTime;
    NSDate *_returnDateTime;
}
@property (copy, nonatomic) NSString *name;
@property (copy, nonatomic) NSString *old_end_date;

@property (nonatomic) NSInteger cooling;
@property (nonatomic) NSInteger heating;

@property (retain, nonatomic) NSDate *leaveDateTime;
@property (retain, nonatomic) NSDate *returnDateTime;


- (MyEVacationItemData *)initWithDictionary:(NSDictionary *)dictionary;
- (MyEVacationItemData *)initWithJSONString:(NSString *)jsonString;

- (NSDictionary *)JSONDictionary;
@end
