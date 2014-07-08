//
//  MyECamera.m
//  MyEHomeCN2
//
//  Created by Ye Yuan on 4/27/14.
//  Copyright (c) 2014 My Energy Domain Inc. All rights reserved.
//

#import "MyECamera.h"

@implementation MyECamera
#pragma mark
#pragma mark JSON methods
- (id)init {
    if (self = [super init]) {
        _UID = @"";
        _name = @"IPCAM";
        _username = @"admin";
        _password = @"888888";
        _imagePath = @"";
        _isOnline = NO;
        _status = @"Unknown";
        return self;
    }
    return nil;
}

- (MyECamera *)initWithDictionary:(NSDictionary *)dictionary {
    if (self = [self init]) {
        self.UID = [dictionary objectForKey:@"UID"];
        self.name = [dictionary objectForKey:@"name"];
        self.username = [dictionary objectForKey:@"username"];
        self.password = [dictionary objectForKey:@"password"];
        self.imagePath = dictionary[@"imagePath"];
        self.isOnline = dictionary[@"isOnline"]?[dictionary[@"isOnline"] boolValue]:NO;
        self.status = dictionary[@"status"]?dictionary[@"status"]:@"Unknown";
        return self;
    }
    return nil;
}

- (MyECamera *)initWithJSONString:(NSString *)jsonString {
    // Create new SBJSON parser object
    SBJsonParser *parser = [[SBJsonParser alloc] init];
    // 把JSON转为字典
    NSDictionary *dict = [parser objectWithString:jsonString];
    
    MyECamera *camera = [[MyECamera alloc] initWithDictionary:dict];
    return camera;
}
- (NSDictionary *)JSONDictionary {
    return @{@"UID": self.UID,
             @"name": self.name,
             @"username": self.username,
             @"password": self.password,
             @"imagePath":self.imagePath==nil?@"":self.imagePath};
}
#pragma mark - NSCopying delegate methods
-(id)copyWithZone:(NSZone *)zone {
    return [[MyECamera alloc] initWithDictionary:[self JSONDictionary]];
}
#pragma mark - NSLog methods
-(NSString *)description{
    return [NSString stringWithFormat:@"name:%@  UID:%@  userName:%@  password:%@",self.name,self.UID,self.username,self.password];
}
@end


@implementation MyEMainCamera

- (MyEMainCamera *)initWithDictionary:(NSDictionary *)dic{
    if (self = [super init]) {
        self.cameras = [NSMutableArray array];
        for (NSDictionary *d in dic[@"cameras"]) {
            [self.cameras addObject:[[MyECamera alloc] initWithDictionary:d]];
        }
        return self;
    }
    return nil;
}
-(MyEMainCamera *)initWithArray:(NSArray *)array{
    if (self = [super init]) {
        NSMutableArray *array = [NSMutableArray array];
        for (NSDictionary *d in array) {
            [array addObject:[[MyECamera alloc] initWithDictionary:d]];
        }
        self.cameras = array;
        return self;
    }
    return nil;
}
- (MyEMainCamera *)initWithJSONString:(NSString *)jsonString{
    NSArray *array = [jsonString JSONValue];
    MyEMainCamera *main = [[MyEMainCamera alloc] initWithArray:array];
    return main;
}
- (NSString *)JSONDictionary{
    NSMutableArray *cameras = [NSMutableArray array];
    for (MyECamera *c in self.cameras) {
        [cameras addObject:[c JSONDictionary]];
    }
    SBJsonWriter *write = [[SBJsonWriter alloc] init];
    NSString *string = [write stringWithObject:cameras];
    return string;
}

@end

@implementation MyECameraWifi

-(id)init{
    if (self = [super init]) {
        self.UID = @"";
        self.name = @"";
        self.security = 0;
        self.signal = 0;
    }
    return self;
}
-(UIImage *)changeSignalToImage{
    NSString *imageName = nil;
    if (self.signal < 20) {
        imageName = @"signal0";
    }else if (self.signal < 40){
        imageName = @"signal1";
    }else if (self.signal < 60){
        imageName = @"signal2";
    }else if (self.signal < 80){
        imageName = @"signal3";
    }else
        imageName = @"signal4";
    return [UIImage imageNamed:imageName];
}
@end