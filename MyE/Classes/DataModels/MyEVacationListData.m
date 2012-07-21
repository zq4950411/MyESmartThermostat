//
//  MyEVacationvacationListData.m
//  MyE
//
//  Created by Ye Yuan on 3/13/12.
//  Copyright (c) 2012 MyEnergy Domain. All rights reserved.
//

#import "MyEVacationListData.h"
#import "MyEVacationItemData.h"
#import "MyEStaycationItemData.h"
#import "SBJson.h"

@implementation MyEVacationListData
@synthesize vacationList = _vacationList, userId = _useId, houseId = _houseId;
- (id)init {
    if (self = [super init]) {
        _vacationList = [NSMutableArray arrayWithObjects:[[MyEVacationItemData alloc] init], [[MyEStaycationItemData alloc] init],nil];
        
        return self;
    }
    return nil;
}

- (void)setvacationList:(NSMutableArray *)newList {
    if (_vacationList != newList) {
        _vacationList = [newList mutableCopy];
    }
}

- (MyEVacationListData *)initWithDictionary:(NSDictionary *)dictionary
{
    if (self = [super init]) {
        self.userId = [dictionary objectForKey:@"userId"];
        self.houseId = [dictionary objectForKey:@"houseId"];
        
        NSArray *listInDict = [dictionary objectForKey:@"vacations"];
        NSMutableArray *vacations = [NSMutableArray array];
        for (NSDictionary *item in listInDict) {
            if ([[item objectForKey:@"type"] intValue] == 0) {
                [vacations addObject:[[MyEVacationItemData alloc] initWithDictionary:item]];
            } else
            [vacations addObject:[[MyEStaycationItemData alloc] initWithDictionary:item]];
        }
        self.vacationList = vacations;        
        return self;
    }
    return nil;
    
}

- (MyEVacationListData *)initWithJSONString:(NSString *)jsonString
{
    // Create new SBJSON parser object
    SBJsonParser *parser = [[SBJsonParser alloc] init];
    // 把JSON转为字典    
    NSDictionary *dict = [parser objectWithString:jsonString error:nil];
    if (dict && [dict isKindOfClass:[NSDictionary class]]) {
        MyEVacationListData *vacationItem = [[MyEVacationListData alloc] initWithDictionary:dict];
        return vacationItem;
    } else return nil;
}

- (NSDictionary *)JSONDictionary
{
    NSMutableArray *vacations = [[NSMutableArray alloc] init];
    for (NSObject *item in self.vacationList) {
        if ([item isKindOfClass:[MyEVacationItemData class]]) {
            [vacations addObject:[(MyEVacationItemData *)item JSONDictionary]];
        }
        if ([item isKindOfClass:[MyEStaycationItemData class]]) {
            [vacations addObject:[(MyEStaycationItemData *)item JSONDictionary]];
        }
    }
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                          self.userId,@"userId",
                          self.houseId, @"houseId",
                          vacations, @"vacations",
                          nil ];
    return dict;
}
-(id)copyWithZone:(NSZone *)zone {
    return [[MyEVacationListData alloc] initWithDictionary:[self JSONDictionary]];
}

#pragma mark table view related methods
- (NSInteger)countOfList {
    return [self.vacationList count];
}

- (NSObject *)objectInListAtIndex:(NSInteger)theIndex {
    return [self.vacationList objectAtIndex:theIndex];
}
- (void)removeObjectAtIndex:(NSInteger)theIndex {
    [self.vacationList removeObjectAtIndex:theIndex];
}
- (void)addVacation:(id)vacation {
    
    [self.vacationList addObject:vacation];
}
@end
