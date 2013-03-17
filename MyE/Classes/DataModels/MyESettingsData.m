//
//  MyESettingsData.m
//  MyE
//
//  Created by Ye Yuan on 3/29/12.
//  Copyright (c) 2012 MyEnergy Domain. All rights reserved.
//

#import "MyESettingsData.h"
#import "SBJson.h"
#import "MyEHouseData.h"
//可以删除，此类现在完全用MyEHouseData类代替
@implementation MyESettingsData
@synthesize userId = _userId, username = _username, mediator = _mediator, house=_house;
#pragma mark
#pragma mark JSON methods
- (MyESettingsData *)initWithDictionary:(NSDictionary *)dictionary {
    if (self = [super init]) {
        _userId = [dictionary objectForKey:@"userId"];
        _username = [dictionary objectForKey:@"username"];
        _mediator = [dictionary objectForKey:@"mediator"];
        _house = [[MyEHouseData alloc] initWithDictionary:[dictionary objectForKey:@"house"]];
        return self;
    }
    return nil;
    
}
- (MyESettingsData *)initWithJSONString:(NSString *)jsonString {
    // Create new SBJSON parser object
    SBJsonParser *parser = [[SBJsonParser alloc] init];
    // 把JSON转为字典  
    NSError *error = [[NSError alloc] init];
    NSDictionary *dict = [parser objectWithString:jsonString error:&error];
    
    if (dict && [dict isKindOfClass:[NSDictionary class]]) {
        MyESettingsData *settings = [[MyESettingsData alloc] initWithDictionary:dict];
        return settings;
    }else 
        return nil;
}
- (NSDictionary *)JSONDictionary {
    
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                          self.userId, @"userId",
                          self.username, @"username",                        
                          self.mediator, @"mediator",
                          [self.house JSONDictionary], @"house",
                          nil ];
    return dict;
}

-(id)copyWithZone:(NSZone *)zone {
    return [[MyESettingsData alloc] initWithDictionary:[self JSONDictionary]];
}
@end
