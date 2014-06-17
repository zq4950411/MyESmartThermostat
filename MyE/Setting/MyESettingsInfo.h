//
//  MyESettingsInfo.h
//  MyE
//
//  Created by 翟强 on 14-6-16.
//  Copyright (c) 2014年 MyEnergy Domain. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MyESettingsInfo : NSObject
@property (nonatomic, strong) NSString *mid;
@property (nonatomic, strong) NSString *houseName;
@property (nonatomic, assign) NSInteger timeZone;
@property (nonatomic, strong) NSMutableArray *terminals;
-(MyESettingsInfo *)initWithJsonString:(NSString *)string;
-(MyESettingsInfo *)initWithDictionary:(NSDictionary *)dic;
-(NSArray *)timeZoneArray;
@end

@interface MyESettingsTerminal : NSObject
@property (nonatomic, strong) NSString *tid;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, assign) NSInteger signal;
@property (nonatomic, assign) NSInteger type;
@property (nonatomic, assign) NSInteger controlState;
-(MyESettingsTerminal *)initWithDictionary:(NSDictionary *)dic;
-(UIImage *)changeSignalToImage;
-(NSString *)changeTypeToString;
@end

@interface MyESettingsHouse : NSObject
@property (nonatomic, strong) NSString *houseName;
@property (nonatomic, assign) NSInteger houseId;
-(MyESettingsHouse*)initWithDictionary:(NSDictionary *)dic;
@end