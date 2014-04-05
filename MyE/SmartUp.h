//
//  SmartUp.h
//  MyE
//
//  Created by space on 13-8-8.
//  Copyright (c) 2013年 MyEnergy Domain. All rights reserved.
//

#import "BaseObject.h"

@interface SmartUp : BaseObject
{
    NSString *deviceId;
    NSString *deviceName;
    NSString *switchStatus;
    
    NSString *typeId;//2:TV,  3: Audio, 4:Automated Curtain, 5: Other,  6 智能插座,7:通用控制器, 8:智能开关
    NSString *typeName;
    
    NSString *tid;
    NSString *tidName;
    
    NSString *rfStatus;
    NSString *sortId;
    
    NSString *locationId;
    NSString *locationName;
    
    BOOL isExpand;
}

@property (nonatomic,strong) NSString *deviceId;
@property (nonatomic,strong) NSString *deviceName;
@property (nonatomic,strong) NSString *switchStatus;

@property (nonatomic,strong) NSString *typeId;
@property (nonatomic,strong) NSString *typeName;

@property (nonatomic,strong) NSString *tid;
@property (nonatomic,strong) NSString *tidName;

@property (nonatomic,strong) NSString *rfStatus;
@property (nonatomic,strong) NSString *sortId;

@property (nonatomic,strong) NSString *locationId;
@property (nonatomic,strong) NSString *locationName;

@property (nonatomic,assign) BOOL isExpand;

+(NSMutableArray *) devices:(id) json;

@end
