//
//  AccountData.m
//  MyE
//
//  Created by Ye Yuan on 1/19/12.
//  Copyright (c) 2012 MyEnergy Domain. All rights reserved.
//

#import "MyEAccountData.h"
#import "MyEHouseData.h"
#import "SBJson.h"

@interface MyEAccountData ()
//- (void)initializeDefaultHouseList;
@end

@implementation MyEAccountData
@synthesize userId = _userId, userName = _userName, 
            rememberMe = _rememberMe, 
            houseList = _houseList, loginSuccess = _loginSuccess;


- (void)setHouseList:(NSMutableArray *)newList {
    if(_houseList != newList) {
        _houseList = [newList mutableCopy];
    }
}

#pragma mark
#pragma mark JSON methods
- (MyEAccountData *)initWithDictionary:(NSDictionary *)dictionary {
    if (self = [super init]) {
        self.userId = [dictionary objectForKey:@"userId"];
        self.userName = [dictionary objectForKey:@"userName"];
        self.loginSuccess = [[dictionary objectForKey:@"success"] isEqualToString:@"true"];
        
        NSArray *array = [dictionary objectForKey:@"houses"];
        NSMutableArray *houses = [NSMutableArray array];
        
        if ([array isKindOfClass:[NSArray class]]){
            for (NSDictionary *house in array) {
                [houses addObject:[[MyEHouseData alloc] initWithDictionary:house]];
            }
        }
        // 这里必须调用 - (void) setPeriods:(NSArray *)periods，在其中由根据periods生成新的metaModeArray的代码。
        self.houseList = houses;
        
        return self;
    }
    return nil;
}

- (MyEAccountData *)initWithJSONString:(NSString *)jsonString {
    // Create new SBJSON parser object
    SBJsonParser *parser = [[SBJsonParser alloc] init];
    // 把JSON转为字典  
    NSError *error = [[NSError alloc] init];
    NSDictionary *dict = [parser objectWithString:jsonString error:&error];
    
    MyEAccountData *account = [[MyEAccountData alloc] initWithDictionary:dict];
    return account;
}
- (NSDictionary *)JSONDictionary {
    // 这里把self.periods里面的每个时段对象进行json序列化后放入数组houses。这样才能把数组houses进行正确的JSON序列化
    NSMutableArray *houses = [NSMutableArray array];
    for (MyEHouseData *house in self.houseList)
        [houses addObject:[house JSONDictionary]];
    
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                          self.userId, @"userId",
                          self.userName, @"userName",                        
                          houses, @"houses",//这里不能把self.houseList直接放在值的位置，因为其中数组的每个元素没有正确地进行JSON字符串序列化                    
                          nil ];
    return dict;
}
-(id)copyWithZone:(NSZone *)zone {
    return [[MyEAccountData alloc] initWithDictionary:[self JSONDictionary]];
}

#pragma mark
#pragma mark tableview datasource methods
- (unsigned)countOfHouseList {
    return [self.houseList count];
}

//房子的M状态必须为0表示M正常链接，T列表不能为空，这样的房子才算有效
- (unsigned)countOfValidHouseList {
    NSInteger count =0;
    for (MyEHouseData *h  in self.houseList) {
        if ( [h isValid] ) {
            count ++;
        }
    }
    return count;
}

// 把所有有效房子按照顺序取出来作为一个数组，取得该数组的位于theIndex处的house。
- (MyEHouseData *)validHouseInListAtIndex:(unsigned int)theIndex {
    NSInteger validCount = 0; // 已经统计过的有效房子的数目。
    NSInteger total= [self.houseList count];
    for (NSInteger i = 0; i < total; i++) {
        MyEHouseData *house = [self.houseList objectAtIndex:i];
        if([house isValid]){
            validCount ++;
            if(theIndex == validCount - 1){
                return house;
            }
        }
    }
    return [self.houseList objectAtIndex:theIndex];
}
- (MyEHouseData *)houseDataByHouseId:(NSInteger)houseId {
    for (int i = 0; i < [self.houseList count]; i++) {
        MyEHouseData *house = [self.houseList objectAtIndex:i];
        if (houseId == house.houseId) {
            return house;
        }
    }
    return nil;
}

/* 当用户在HouseList View面板手动刷新时，会从服务器传来houseList的JSON字符串，用这个函数进行更新House List。
 * 参数str就是服务器传来的JSON String
 * 返回值表示是否解析正确了。如果JSON解析正确，返回YES，否则返回NO
 */
- (BOOL)updateHouseListByJSONString:(NSString *)jsonString {
    // Create new SBJSON parser object
    SBJsonParser *parser = [[SBJsonParser alloc] init];
    // 把JSON转为字典  
    NSError *error = [[NSError alloc] init];
    NSArray *array = [parser objectWithString:jsonString error:&error];
    
    if ([array isKindOfClass:[NSArray class]]){
        [self.houseList removeAllObjects];
        for (NSDictionary *houseDict in array) {
            MyEHouseData *houseData = (MyEHouseData *)[[MyEHouseData alloc] initWithDictionary:houseDict];
//            NSString *mId = houseData.mId;
//            if([mId length] == 0)// 只统计有mId的房屋。去掉这句就会统计所有房屋
                [self.houseList addObject:houseData];
        }
        return YES;
    } else
        return NO;
}

- (NSString *)getHouseNameByHouseId:(NSInteger)houseId {
    NSString *name = nil;
    for (MyEHouseData *house in self.houseList) {
        if (house.houseId == houseId) {
            name = [NSString stringWithFormat:@"%@",house.houseName];
        }
    }
return name;
}


@end
