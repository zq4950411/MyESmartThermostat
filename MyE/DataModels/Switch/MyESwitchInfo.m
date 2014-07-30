//
//  MyESwitchInfo.m
//  MyEHomeCN2
//
//  Created by 翟强 on 14-3-3.
//  Copyright (c) 2014年 My Energy Domain Inc. All rights reserved.
//

#import "MyESwitchInfo.h"

@implementation MyESwitchInfo
-(MyESwitchInfo *)initWithString:(NSString *)string{
    SBJsonParser *parser = [[SBJsonParser alloc] init];
    NSDictionary *dic = [parser objectWithString:string];
    MyESwitchInfo *info = [[MyESwitchInfo alloc] initWithDic:dic];
    return info;
}
-(MyESwitchInfo *)initWithDic:(NSDictionary *)dic{
    if (self = [super init]) {
        self.name = dic[@"name"];
        self.roomId = [dic[@"roomId"] intValue];
        self.powerType = [dic[@"powerType"] intValue];
        self.reportTime = [dic[@"reporteTime"] intValue];
        NSArray *array = dic[@"locationList"];
        self.rooms = [NSMutableArray array];
        for (NSDictionary *d in array) {
            [self.rooms addObject:[[MyERoom alloc] initWithDic:d]];
        }
//        self.type = [dic[@"loadType"] intValue];
//        self.powerFactor = [self trimright0:[NSString stringWithFormat:@"%f",[dic[@"powerFactor"] floatValue]]];
        return self;
    }
    return nil;
}
//-(NSString *) trimright0:(CLLocationDegrees )param
//{
//    NSString *str = [NSString stringWithFormat:@"%f",param];
-(NSString *) trimright0:(NSString *)str
{
    int len = str.length;
    for (int i = 0; i < len; i++)
    {
        if (![str  hasSuffix:@"0"])
            break;
        else
            str = [str substringToIndex:[str length]-1];
    }
    if ([str hasSuffix:@"."])//避免像2.0000这样的被解析成2.
    {
        return [str substringToIndex:[str length]-1];//s.substring(0, len - i - 1);
    }
    else
    {
        return str;
    }
}
-(NSArray *)typeArray{
    return @[@"FL/CFL Lamp",@"Incandescent Lamp"];
}
-(NSString *)changeTypeToString{
    return [self typeArray][self.type];
}
@end


@implementation MyERoom
-(id)init{
    if (self = [super init]) {
        self.roomId = 0;
        self.roomName = @"";
    }
    return self;
}
-(MyERoom *)initWithJSONString:(NSString *)string{
    NSDictionary *dic = [string JSONValue];
    MyERoom *room = [[MyERoom alloc] initWithDic:dic];
    return room;
}
-(MyERoom *)initWithDic:(NSDictionary *)dic{
    if (self = [super init]) {
        if (dic[@"locationId"]) {
            self.roomId = [dic[@"locationId"] integerValue];
        }
        if (dic[@"locationName"]) {
            self.roomName = dic[@"locationName"];
        }
    }
    return self;
}

@end