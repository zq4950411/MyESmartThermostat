//
//  MyETodayPeriodData.h.m
//  MyE
//
//  Created by Ye Yuan on 2/21/12.
//  Copyright (c) 2012 MyEnergy Domain. All rights reserved.
//

#import "MyETodayPeriodData.h"
#import "MyEScheduleModeData.h"
#import "SBJson.h"
#import "MyEUtil.h"

@implementation MyETodayPeriodData

@synthesize  color = _color, stid = _stid, etid = _etid, cooling = _cooling, heating = _heating;
@synthesize hold = _hold, title = _title, modeId = _modeId;
//@synthesize indexInPeriods = _indexInPeriods, indexInDayItems = _indexInDayItems;

- (id)init {
    if (self = [super init]) {
        _color = [UIColor blueColor];
        _stid = 0;
        _etid = 10;
        _cooling = 77;
        _heating = 66;
        _hold = @"none";
        _title = @"Period1";
        _modeId = 0;
        
//        _indexInDayItems = 0;
//        _indexInPeriods = 0;
        return self;
    }
    return nil;
}
- (MyETodayPeriodData *)initWithDictionary:(NSDictionary *)dictionary
{
    if (self = [super init]) {
        self.color = [MyEUtil colorWithHexString:[dictionary objectForKey:@"color"]];
        self.stid = [[dictionary objectForKey:@"stid"] intValue];
        self.etid = [[dictionary objectForKey:@"etid"] intValue];
        self.heating = [[dictionary objectForKey:@"heating"] floatValue];
        self.cooling = [[dictionary objectForKey:@"cooling"] floatValue];
        self.title = [dictionary objectForKey:@"title"];
        self.hold = [dictionary objectForKey:@"hold"];
        self.modeId = [[dictionary objectForKey:@"modeid"] intValue];        
        return self;
    }
    return nil;
}

- (NSDictionary *)JSONDictionary
{
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
            [MyEUtil hexStringWithUIColor:self.color], @"color",
            [NSNumber numberWithInt:self.stid], @"stid",
            [NSNumber numberWithInt:self.etid], @"etid",
            [NSNumber numberWithFloat:self.heating], @"heating",
            [NSNumber numberWithFloat:self.cooling], @"cooling",
            [NSNumber numberWithFloat:self.modeId], @"modeid",
            self.hold, @"hold",
            self.title, @"title",
            nil ];
    return dict;
}
-(id)copyWithZone:(NSZone *)zone {
    return [[MyETodayPeriodData alloc] initWithDictionary:[self JSONDictionary]];
}
-(NSString *)description
{
    return [NSString stringWithFormat:@"stid = %i, etid = %i, cooling = %i, heating = %i, hold = %@, title = %@, modeId=%i, color = (%@) \n", _stid, _etid, _cooling, _heating, _hold, _title, _modeId,  [_color description]];
}

//从period数据获取由MyEScheduleModeData类对象，它是元模式数据.传入的参数modeId其实是时段的在today数据中的编号，
- (MyEScheduleModeData *)scheduleModeDataWithPeriodIndex:(NSInteger)periodIndex
{
    MyEScheduleModeData *metaMode = [[MyEScheduleModeData alloc] init];
    metaMode.color = self.color;
    metaMode.cooling = self.cooling;
    metaMode.heating = self.heating;
    metaMode.modeName = self.title;
    metaMode.modeId = periodIndex;// 这个地方本来在Today面板的地方，没有modeId，所以用时段序号代替，但Next24hrs面板现在提供了modeId，在这里不做更新，而在此函数外面被调用的地方进行更新真正的modeId
    metaMode.hold = self.hold;
    return  metaMode;
}

@end
