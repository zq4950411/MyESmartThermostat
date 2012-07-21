//
//  MyEScheduleModeData.m
//  MyE
//
//  Created by Ye Yuan on 2/24/12.
//  Copyright (c) 2012 MyEnergy Domain. All rights reserved.
//

#import "MyEScheduleModeData.h"
#import "SBJson.h"
#import "MyEUtil.h"

@implementation MyEScheduleModeData

@synthesize  color = _color, cooling = _cooling, heating = _heating;
@synthesize modeId = _modeId, modeName = _modeName, hold = _hold;


- (id)init {
    if (self = [super init]) {
        _color = [UIColor blueColor];
        _cooling = 77;
        _heating = 66;
        _modeId = 0;
        _hold = @"none";//暂时也没有在today模块里面使用
        _modeName = @"Mode1";
        return self;
    }
    return nil;
}
- (MyEScheduleModeData *)initWithDictionary:(NSDictionary *)dictionary
{
    if (self = [self init]) {
        self.color = [MyEUtil colorWithHexString:[dictionary objectForKey:@"color"]];
        self.heating = [[dictionary objectForKey:@"heating"] floatValue];
        self.cooling = [[dictionary objectForKey:@"cooling"] floatValue];
        self.modeName = [dictionary objectForKey:@"modeName"];
        self.modeId = [[dictionary objectForKey:@"modeid"] intValue];
        
        return self;
    }
    return nil;
}

- (NSDictionary *)JSONDictionary
{
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                          [MyEUtil hexStringWithUIColor:self.color], @"color",
                          [NSNumber numberWithFloat:self.heating], @"heating",
                          [NSNumber numberWithFloat:self.cooling], @"cooling",
                          [NSNumber numberWithInt:self.modeId], @"modeid",
                          self.modeName, @"modeName",
                          nil ];
    return dict;
}
-(id)copyWithZone:(NSZone *)zone {
    return [[MyEScheduleModeData alloc] initWithDictionary:[self JSONDictionary]];
}
-(NSString *)description
{
    return [NSString stringWithFormat:@"color = (%@), cooling = %f, heating = %f, modeId = %i, modeName = %@\n", [_color description], _cooling, _heating, _modeId, self.modeName];
}

@end
