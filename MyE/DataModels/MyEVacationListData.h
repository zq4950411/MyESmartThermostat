//
//  MyEVacationData.h
//  MyE
//
//  Created by Ye Yuan on 3/13/12.
//  Copyright (c) 2012 MyEnergy Domain. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MyEVacationListData : NSObject  <NSCopying> {
    NSString *_useId;
    NSString *_houseId;
    NSMutableArray *_vacationList;
}
@property (copy, nonatomic) NSString *userId;
@property (copy, nonatomic) NSString *houseId;
@property (nonatomic, copy) NSString *locWeb;
@property (retain, nonatomic) NSMutableArray *vacationList;

- (MyEVacationListData *)initWithDictionary:(NSDictionary *)dictionary;
- (MyEVacationListData *)initWithJSONString:(NSString *)jsonString;

- (NSDictionary *)JSONDictionary;


- (NSInteger)countOfList;
- (NSObject *)objectInListAtIndex:(NSInteger)theIndex;
- (void)removeObjectAtIndex:(NSInteger)theIndex;
- (void)addVacation:(id)vacation;
@end
