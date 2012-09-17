//
//  MyESettingsData.h
//  MyE
//
//  Created by Ye Yuan on 3/29/12.
//  Copyright (c) 2012 MyEnergy Domain. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MyESettingsData : NSObject <NSCopying> 
@property (nonatomic, copy) NSString *username;
@property (nonatomic, copy) NSString *userId;
@property (nonatomic, copy) NSString *locWeb;
@property (nonatomic, copy) NSString *mediator;
@property (nonatomic, copy) NSString * thermostat;
@property (nonatomic) NSInteger keyPad;//拨动开关(0:Unlock  1:Lock).

- (MyESettingsData *)initWithDictionary:(NSDictionary *)dictionary;
- (MyESettingsData *)initWithJSONString:(NSString *)jsonString;
- (NSDictionary *)JSONDictionary;
@end
