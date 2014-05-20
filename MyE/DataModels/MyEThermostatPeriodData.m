//
//  MyEThermostatPeriodData.m
//  MyE
//
//  Created by Ye Yuan on 2/29/12.
//  Copyright (c) 2012 MyEnergy Domain. All rights reserved.
//

#import "MyEThermostatPeriodData.h"
#import "MyEScheduleModeData.h"
#import "SBJson.h"
#import "MyEUtil.h"

@implementation MyEThermostatPeriodData

@synthesize stid = _stid, etid = _etid;
@synthesize modeId = _modeId;


- (id)init {
    if (self = [super init]) {
        _stid = 0;
        _etid = 10;
        _modeId = 0;
        return self;
    }
    return nil;
}
- (MyEThermostatPeriodData *)initWithDictionary:(NSDictionary *)dictionary
{
    if (self = [super init]) {
        self.stid = [[dictionary objectForKey:@"stid"] intValue];
        self.etid = [[dictionary objectForKey:@"etid"] intValue];
        self.modeId = [[dictionary objectForKey:@"modeid"] intValue];
        
        return self;
    }
    return nil;
}

- (NSDictionary *)JSONDictionary
{
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                          [NSNumber numberWithInt:self.stid], @"stid",
                          [NSNumber numberWithInt:self.etid], @"etid",
                          [NSNumber numberWithInt:self.modeId], @"modeid",
                          nil ];
    return dict;
}
-(id)copyWithZone:(NSZone *)zone {
    return [[MyEThermostatPeriodData alloc] initWithDictionary:[self JSONDictionary]];
}
-(NSString *)description
{
    return [NSString stringWithFormat:@"stid = %i, etid = %i, modeId = %i", self.stid, self.etid, self.modeId];
}

@end
