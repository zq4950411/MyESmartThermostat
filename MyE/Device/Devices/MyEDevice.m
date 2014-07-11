//
//  SmartUp.m
//  MyE
//
//  Created by space on 13-8-8.
//  Copyright (c) 2013年 MyEnergy Domain. All rights reserved.
//

#import "MyEDevice.h"

@implementation MyEDevice

@synthesize deviceId;
@synthesize deviceName;
@synthesize switchStatus;

@synthesize typeId;
@synthesize tid;
@synthesize rfStatus;
@synthesize sortId;

@synthesize locationId;
@synthesize locationName;

@synthesize isExpand;
-(id)init{
    if (self = [super init]) {
        self.deviceId = @"";
        self.deviceName = @"";
        self.locationId = 0;
        self.locationName = @"";
        self.typeId = 0;
        self.tid = @"";
        self.point = 0;
        self.instructionName = @"";
        self.switchStatus = @"";
        self.sortId = @"";
        self.rfStatus = 0;
        self.maxCurrent = 0;
        return self;
    }
    return nil;
}
+(NSMutableArray *) devices:(id) json
{
    NSArray *array = (NSArray *)[(NSString *)json JSONValue];
    if ([array isKindOfClass:[NSArray class]])
    {
        NSMutableArray *retArray = [NSMutableArray arrayWithCapacity:0];
        for (int i = 0; i < array.count;i++)
        {
            NSDictionary *tempDic = (NSDictionary *)[array objectAtIndex:i];
            
            MyEDevice *temp = [[MyEDevice alloc] init];
            
            temp.deviceId = [tempDic valueToStringForKey:@"deviceId"];
            temp.deviceName = [tempDic valueToStringForKey:@"deviceName"];
            temp.switchStatus = [tempDic valueToStringForKey:@"switchStatus"];
            temp.typeId = [NSString stringWithFormat:@"%d",[[tempDic valueToStringForKey:@"typeId"] intValue]];
            temp.tid = [NSString stringWithFormat:@"%@",[tempDic valueToStringForKey:@"tid"]];
            temp.rfStatus = [tempDic valueToStringForKey:@"rfStatus"];
            temp.sortId = [NSString stringWithFormat:@"%d",[[tempDic valueToStringForKey:@"sortId"] intValue]];
            temp.locationName = [tempDic valueToStringForKey:@"locationName"];
            
            [retArray addObject:temp];
        }
        return retArray;
    }
    else
    {
        return nil;
    }
}
-(MyEDevice *)initWithDic:(NSDictionary *)dic{
    if (self = [super init]) {
        self.deviceId = dic[@"deviceId"];
        self.deviceName = dic[@"deviceName"];
        self.typeId = dic[@"typeId"];
        self.tid = dic[@"tid"];
        if (dic[@"switchStatus"]) {
            self.switchStatus = dic[@"switchStatus"];
        }
        if (dic[@"rfStatus"]) {
            self.rfStatus = dic[@"rfStatus"];
        }
        if (dic[@"sortId"]) {
            self.sortId = dic[@"sortId"];
        }
        if (dic[@"locationName"]) {   //这里的这个判断尤为重要
            if (dic[@"locationName"] == [NSNull null]) {
                self.locationName = @"";
            }else
                self.locationName = dic[@"locationName"];
        }
        if (dic[@"locationId"]) {
            self.locationId = dic[@"locationId"]==[NSNull null]?@"0":dic[@"locationId"];
        }
        //这里需要注意
        self.point = dic[@"point"]==[NSNull null]?0:[dic[@"point"] intValue];
        self.instructionName = dic[@"instructionName"]?dic[@"instructionName"]:@"";
        self.showSpecialDays = dic[@"showSpecialDays"]!=[NSNull null]?[dic[@"showSpecialDays"] boolValue]:NO;
        return self;
    }
    return nil;
}
-(NSDictionary *)jsonDevice:(MyEDevice *)device{
    
    NSDictionary *dic = @{@"deviceId": @([device.deviceId intValue]),
                          @"deviceName":device.deviceName,
                          @"typeId":@(device.typeId.intValue),
                          @"tid":device.tid,
                          @"locationId":@(device.locationId.intValue)};
    NSLog(@"dic is %@",dic);
    return dic;
}
-(NSString *)description{
    return [NSString stringWithFormat:@"deviceId:%@ name:%@ typeId:%@ tid:%@ locationId:%@ locationName:%@ %@ %@",self.deviceId,self.deviceName,self.typeId,self.tid,self.locationId,self.locationName,self.sortId,self.rfStatus];
}
@end

//@implementation MyERoom
//-(MyERoom *)initWithJSONString:(NSString *)string{
//    return self;
//}
//-(MyERoom *)initWithDic:(NSDictionary *)dic{
//    if (self = [super init]) {
//        self.roomId = [dic[@"locationId"] intValue];
//        self.name = dic[@"locationName"];
//        return self;
//    }
//    return nil;
//}
//@end

@implementation MyEMainDevice
-(id)init{
    if (self = [super init]) {
        self.devices = [NSMutableArray array];
        self.rooms = [NSMutableArray array];
        return self;
    }
    return nil;
}
-(MyEMainDevice *)initWithJSONString:(NSString *)string{
    NSDictionary *dic = [string JSONValue];
    MyEMainDevice *mainDevice = [[MyEMainDevice alloc] initWithDic:dic];
    return mainDevice;
}
-(MyEMainDevice *)initWithDic:(NSDictionary *)dic{
    if (self = [super init]) {
        self.devices = [NSMutableArray array];
        self.rooms = [NSMutableArray array];
        for (NSDictionary *d in dic[@"deviceList"]) {
            MyEDevice *device = [[MyEDevice alloc] initWithDic:d];
            [self.devices addObject:device];
        }
        for (NSDictionary *d in dic[@"locationList"]) {
            MyERoom *room = [[MyERoom alloc] initWithDic:d];
            [self.rooms addObject:room];
        }
        return self;
    }
    return nil;
}
-(MyEMainDevice *)initWithJSONString:(NSString *)string andTag:(NSInteger)tag{
    NSArray *array = [string JSONValue];
    MyEMainDevice *mainDevice = [[MyEMainDevice alloc] initWithArray:array andTag:tag];
    return mainDevice;
}
-(MyEMainDevice *)initWithArray:(NSArray *)array andTag:(NSInteger)tag{
    if (self = [super init]) {
        self.devices = [NSMutableArray array];
        self.rooms = [NSMutableArray array];
        if (tag == 1) {
            for (NSDictionary *d in array) {
                MyEDevice *device = [[MyEDevice alloc] initWithDic:d];
                [self.devices addObject:device];
            }
        }else{
            for (NSDictionary *d in array) {
                MyERoom *room = [[MyERoom alloc] initWithDic:d];
                [self.rooms addObject:room];
            }
        }
        return self;
    }
    return nil;
}

@end
