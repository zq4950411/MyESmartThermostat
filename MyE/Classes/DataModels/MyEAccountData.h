//
//  AccountData.h
//  MyE
//  这个类用于管理用户账户信息，当用户在界面上输入登录信息后，就把userName、
//  password、remember记录下来，然后ajax请求登录，登录成功后的信息返回后，
//  就把userId，houseList等信息都记录到这个类。
//  这个类还可以作为HouseData类的Controller，类似于
//  Created by Ye Yuan on 1/19/12.
//  Copyright (c) 2012 MyEnergy Domain. All rights reserved.
//

#import <Foundation/Foundation.h>
@class MyEHouseData;

@interface MyEAccountData : NSObject <NSCopying> 
@property (nonatomic, copy) NSString *userName;
@property (nonatomic, copy) NSString *userId;
@property (nonatomic) BOOL rememberMe;
@property (nonatomic) BOOL loginSuccess;

//这里不需要动态房屋列表，而是在从服务器获得数据后一次性生成一个房屋列表并传进来
//今后如果需要动态增加房屋，就需要像BirdWatching示例那样生成一个动态数组。
@property (nonatomic, copy) NSMutableArray *houseList;

- (MyEAccountData *)initWithDictionary:(NSDictionary *)dictionary;
- (MyEAccountData *)initWithJSONString:(NSString *)jsonString;
- (NSDictionary *)JSONDictionary;

- (unsigned)countOfHouseList;
- (MyEHouseData *)objectInHouseListAtIndex:(unsigned)theIndex;
- (MyEHouseData *)houseDataByHouseId:(NSInteger)houseId;

/* 当用户在HouseList View面板手动刷新时，会从服务器传来houseList的JSON字符串，用这个函数进行更新House List。
 * 参数str就是服务器穿了的JSON String
 * 返回值表示是否解析正确了。如果JSON解析正确，返回YES，否则返回NO
 */
- (BOOL)updateHouseListByJSONString:(NSString *)jsonString;

- (NSString *)getHouseNameByHouseId:(NSInteger)houseId;

@end
