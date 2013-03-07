//
//  HouseData.h
//  MyE
//
//  Created by Ye Yuan on 1/19/12.
//  Copyright (c) 2012 MyEnergy Domain. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MyEHouseData : NSObject <NSCopying> 
@property (nonatomic, copy) NSString *houseName;
@property (nonatomic) NSInteger houseId;
@property (nonatomic) NSInteger mId;
@property (nonatomic) NSInteger connection;//只有mid不为空时才用。标识m是否断开连接。0表示连接正常，1表示断开连接。
@property (nonatomic, copy) NSMutableArray *thermostats;

- (MyEHouseData *)initWithDictionary:(NSDictionary *)dictionary;
- (NSDictionary *)JSONDictionary;

@end
