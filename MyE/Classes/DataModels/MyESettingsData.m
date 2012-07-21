//
//  MyESettingsData.m
//  MyE
//
//  Created by Ye Yuan on 3/29/12.
//  Copyright (c) 2012 MyEnergy Domain. All rights reserved.
//

#import "MyESettingsData.h"
#import "SBJson.h"

@implementation MyESettingsData
@synthesize userId = _userId, username = _username, mediator = _mediator, thermostat = _thermostat, keyPad = _keyPad;
#pragma mark
#pragma mark JSON methods
- (MyESettingsData *)init:(NSDictionary *)dictionary {
    if (self = [super init]) {
        _userId = @"1234567";
        _username = @"demo";
        _keyPad = 0;
        _mediator = @"00-00-00-00-00-01";
        _thermostat = @"023456789";
        return self;
    }
    return nil;
    
}

- (MyESettingsData *)initWithDictionary:(NSDictionary *)dictionary {
    if (self = [super init]) {
        _userId = [dictionary objectForKey:@"userId"];
        _username = [dictionary objectForKey:@"username"];
        _keyPad = [[dictionary objectForKey:@"keyPad"] intValue];
        _mediator = [dictionary objectForKey:@"mediator"];
        _thermostat = [dictionary objectForKey:@"thermostat"];
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
                          [NSNumber numberWithInt:self.keyPad], @"keyPad",
                          self.mediator, @"mediator",
                          self.thermostat, @"thermostat",
                          nil ];
    return dict;
}

-(id)copyWithZone:(NSZone *)zone {
    return [[MyESettingsData alloc] initWithDictionary:[self JSONDictionary]];
}
@end
