//
//  MyETerminalData.h
//  MyE
//
//  Created by Ye Yuan on 3/6/13.
//  Copyright (c) 2013 MyEnergy Domain. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MyETerminalData : NSObject

@property (nonatomic, copy) NSString *tName;
@property (nonatomic, copy) NSString *tId;
@property (nonatomic) NSInteger connection;//0表示温控器正常连接，1表示有温控器但没正常连接，2表示用户根本没有为这个房子购买温控器
@property (nonatomic) NSInteger remote;//0表示禁止远程控制，1表示允许远程控制。（只有当thermostat=0 和1时才有remote的值,thermostat=2是没有硬件，就没有返回remote的值了）

//硬件类型由服务器提供0表示美国温度控制器1  红外转发器, 2 智能插座, 3  通用控制器, 4 安防设备, 6 智能开关
@property (nonatomic) NSInteger deviceType;
@property (nonatomic) NSInteger keypad;

- (MyETerminalData *)initWithDictionary:(NSDictionary *)dictionary;
- (NSDictionary *)JSONDictionary;

@end
