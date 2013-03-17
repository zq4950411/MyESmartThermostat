//
//  MyESettingsData.h
//  MyE
//
//  Created by Ye Yuan on 3/29/12.
//  Copyright (c) 2012 MyEnergy Domain. All rights reserved.
//
//可以删除，此类现在完全用MyEHouseData类代替
#import <Foundation/Foundation.h>
@class MyEHouseData;

@interface MyESettingsData : NSObject <NSCopying> 
@property (nonatomic, copy) NSString *username;
@property (nonatomic, copy) NSString *userId;
@property (nonatomic, copy) NSString *mediator;
@property (nonatomic, strong) MyEHouseData *house;

- (MyESettingsData *)initWithDictionary:(NSDictionary *)dictionary;
- (MyESettingsData *)initWithJSONString:(NSString *)jsonString;
- (NSDictionary *)JSONDictionary;
@end
