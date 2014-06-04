//
//  MyEAlert.m
//  MyE
//
//  Created by Ye Yuan on 5/28/14.
//  Copyright (c) 2014 MyEnergy Domain. All rights reserved.
//

#import "MyEAlert.h"

@implementation MyEAlert
-(MyEAlert *)initWithString:(NSString *)string{
    // Create new SBJSON parser object
    SBJsonParser *parser = [[SBJsonParser alloc] init];
    // 把JSON转为字典
    NSError *error = [[NSError alloc] init];
    NSDictionary *dict = [parser objectWithString:string error:&error];
    
    if (dict && [dict isKindOfClass:[NSDictionary class]]) {
        MyEAlert *alert = [[MyEAlert alloc] initWithDictionary:dict];
        return alert;
    }else
        return nil;
}
-(MyEAlert *)initWithDictionary:(NSDictionary *)dic{
    if (self = [super init]) {
        self.title = dic[@"title"];
        self.content = dic[@"content"];
        self.ID = [dic[@"id"] integerValue];
        self.new_flag = [dic[@"new_flag"] integerValue];
        self.publish_date = dic[@"publish_date"];
        return self;
    }
    return nil;
}
- (NSDictionary *)JSONDictionary {
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                          self.title, @"title",
                          self.content, @"content",
                          self.publish_date, @"publish_date",
                          @(self.ID), @"id",
                          @(self.new_flag), @"new_flag",
                          nil ];
    return dict;
}
-(id)copyWithZone:(NSZone *)zone {
    return [[MyEAlert alloc] initWithDictionary:[self JSONDictionary]];
}

@end
