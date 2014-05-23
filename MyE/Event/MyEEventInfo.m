//
//  MyEEventInfo.m
//  MyE
//
//  Created by 翟强 on 14-5-23.
//  Copyright (c) 2014年 MyEnergy Domain. All rights reserved.
//

#import "MyEEventInfo.h"

@implementation MyEEventInfo
-(id)init{
    if (self = [super init]) {
        self.sceneName = @"";
        self.sceneId = 0;
        self.type = 0;
        self.timeTriggerFlag = 0;
        self.conditionTriggerFlag = 0;
    }
    return self;
}
-(MyEEventInfo *)initWithDictionary:(NSDictionary *)dic{
    if (self = [super init]) {
        self.sceneName = dic[@"sceneName"];
        self.sceneId = [dic[@"sceneId"] intValue];
        self.type = [dic[@"type"] intValue];
        self.timeTriggerFlag = [dic[@""] intValue];
        self.conditionTriggerFlag = [dic[@""] intValue];
        return self;
    }
    return nil;
}
@end
@implementation MyEEvents

-(MyEEvents *)initWithJsonString:(NSString *)string{
    NSArray *array = [string JSONValue];
    MyEEvents *events = [[MyEEvents alloc] initWithArray:array];
    return events;
}
-(MyEEvents *)initWithArray:(NSArray *)array{
    if (self = [super init]) {
        self.scenes = [NSMutableArray array];
        for (NSDictionary *d in array) {
            [self.scenes addObject:[[MyEEventInfo alloc] initWithDictionary:d]];
        }
    }
    return self;
}
@end