//
//  HouseData.h
//  MyE
//
//  Created by Ye Yuan on 1/19/12.
//  Copyright (c) 2012 MyEnergy Domain. All rights reserved.
//

#import <Foundation/Foundation.h>
@class MyETerminalData;

@interface MyEHouseData : NSObject <NSCopying> 
@property (nonatomic, copy) NSString *houseName;
@property (nonatomic) NSInteger houseId;
@property (nonatomic, copy) NSString *mId;
@property (nonatomic) NSInteger connection;//只有mid不为空时才用。标识m是否断开连接。0表示连接正常，1表示断开连接。
@property (nonatomic, retain) NSMutableArray *terminals;

- (MyEHouseData *)initWithDictionary:(NSDictionary *)dictionary;
- (MyEHouseData *)initWithJSONString:(NSString *)jsonString;
- (NSDictionary *)JSONDictionary;

- (BOOL)isValid;// 判定房子是否有效，标准是房子的M状态必须为0表示M正常链接，T列表不能为空，这样的房子才算有效
- (BOOL)isConnected;//判定房子是否连接, 标准是房子是否有M，并且至少有一个T在连接工作，才能键入房子，因为我们的目标是点击进入一个房子后必须有一个T的信息。
- (MyETerminalData *)firstConnectedThermostat;
- (NSInteger)countOfConnectedThermostat;// 房子有连接的T的数目。
@end
