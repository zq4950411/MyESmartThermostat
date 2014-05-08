//
//  MyESwitchInfo.h
//  MyEHomeCN2
//
//  Created by 翟强 on 14-3-3.
//  Copyright (c) 2014年 My Energy Domain Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MyESwitchInfo : NSObject

@property(nonatomic, strong) NSString *name;
@property(nonatomic) NSInteger roomId;
@property(nonatomic) NSInteger powerType;
@property(nonatomic) NSInteger reportTime;
@property(nonatomic, strong) NSMutableArray *rooms;

-(MyESwitchInfo *)initWithString:(NSString *)string;
-(MyESwitchInfo *)initWithDic:(NSDictionary *)dic;

@end

@interface MyERoom : NSObject

@property (nonatomic) NSInteger roomId;
@property (nonatomic, strong) NSString *roomName;

-(MyERoom *)initWithJSONString:(NSString *)string;
-(MyERoom *)initWithDic:(NSDictionary *)dic;
@end